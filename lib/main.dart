// ignore_for_file: prefer_const_constructors, unused_shown_name, unused_import, prefer_const_literals_to_create_immutables, avoid_print, deprecated_member_use

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/dependency_injection.dart';
import 'package:vivoo_camera_cty/controllers/home_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/controllers/tab_controller.dart';
import 'package:vivoo_camera_cty/firebase_options.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/models/login_request.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, kReleaseMode;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:vivoo_camera_cty/services/notification_service.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'package:vivoo_camera_cty/views/camera/camera_page.dart';
import 'package:vivoo_camera_cty/views/check_internet.dart/no_connect_page.dart';
import 'package:vivoo_camera_cty/views/main/main_page.dart';
import 'package:vivoo_camera_cty/views/profile/notification_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print(
      "onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Widget defaultHome = MainScreen();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  await dotenv.load(fileName: Environment.fileName);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  await NotificationService().initialize(flutterLocalNotificationsPlugin);

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => MyApp(), // Wrap your app
  //   ),
  // );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp()));
  DependencyInjection.init();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermissions(); // Yêu cầu quyền khi ứng dụng khởi chạy
    //  _checkConnectivity(); // Kiểm tra kết nối mạng
    // Lắng nghe sự thay đổi kết nối mạng
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Dọc thông thường
      DeviceOrientation.portraitDown, // Dọc ngược
    ]);
  }

  @override
  void dispose() {
    // Khôi phục chế độ quay màn hình khi thoát khỏi ứng dụng
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> requestPermissions() async {
    if (await Permission.camera.isDenied ||
        await Permission.camera.isPermanentlyDenied) {
      await Permission.camera.request();
    }

    if (await Permission.microphone.isDenied ||
        await Permission.microphone.isPermanentlyDenied) {
      await Permission.microphone.request();
    }

    if (await Permission.storage.isDenied ||
        await Permission.storage.isPermanentlyDenied) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    final box = GetStorage();
    final controller = Get.put(LoginController());

    String? username = box.read('username');
    String? password = box.read('password');
    if (username == null || password == null) {
      // defaultHome = LoginPage();
    } else {
      LoginRequest model = LoginRequest(username: username, password: password);

      String authData = loginRequestToJson(model);

      controller.loginFuncStart(authData);
      //  defaultHome = MainScreen();
    }

    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(375, 825),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          title: 'Vivoo',
          theme: ThemeData(
            scaffoldBackgroundColor: Color(kOffWhite.value),
            iconTheme: IconThemeData(color: Color(kDark.value)),
            primarySwatch: Colors.grey,
          ),
          home:
              username != null && password != null ? MainScreen() : LoginPage(),
          navigatorKey: navigatorKey,
          routes: {
            '/order_details_page': (context) => CameraPage(
                  idcamera: '',
                  label: '',
                ),
          },
        );
      },
    );
  }
}
