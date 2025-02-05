// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, await_only_futures, avoid_print, unused_field, unnecessary_null_comparison, prefer_const_declarations, prefer_final_fields, prefer_const_constructors, unnecessary_string_interpolations, avoid_unnecessary_containers, unused_element, sized_box_for_whitespace

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart'; // Quay màn hình
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'package:vivoo_camera_cty/views/camera/full_screen_palyback.dart';
import 'package:vivoo_camera_cty/views/camera/fullscreen_video.dart';
import 'package:vivoo_camera_cty/views/camera/play_back_all_img.dart';
import 'package:vivoo_camera_cty/views/camera/play_back_hdm_img.dart';
import 'package:vivoo_camera_cty/views/camera/play_back_image_motion.dart';
import 'package:vivoo_camera_cty/views/camera/play_back_video_sdcard.dart';
import 'package:vivoo_camera_cty/views/camera/widget/list_icon_imag.dart';
import 'package:vivoo_camera_cty/views/camera/widget/load_down_all.dart';
import 'package:vivoo_camera_cty/views/camera/widget/load_down_motion.dart';
import 'package:vivoo_camera_cty/views/camera/widget/load_download_human.dart';
import 'package:vivoo_camera_cty/views/camera/widget/load_download_sdcard.dart';
import 'package:vivoo_camera_cty/views/camera/widget/ptz_camera.dart';
import 'package:vivoo_camera_cty/views/camera/widget/ptz_camera_control.dart';
import 'package:vivoo_camera_cty/views/camera/widget/timer_camera.dart';
import 'package:vivoo_camera_cty/views/main/main_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:screenshot/screenshot.dart'; // Chụp màn hình
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.idcamera, required this.label});
  final String idcamera;
  final String label;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  ScreenshotController screenshotController = ScreenshotController();
  ScreenRecorderController controller = ScreenRecorderController();
  bool get canExport => controller.exporter.hasFrames;
  final webrtcServices = Get.put(WebRTCServiceController());
  GlobalKey _regionKey = GlobalKey();
  bool _isRecording = false;
  late AnimationController _controlleranimation;
  late Animation<double> _animation;
  final cloudRecordControllers = Get.put(CloudRecordPathController());
  final notifiControllerssss = Get.put(NotificationController());
  final loginControler = Get.put(LoginController());
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _controlleranimation = AnimationController(
      duration: Duration(milliseconds: 500), // Thời gian nhấp nháy
      vsync: this,
    )..repeat(reverse: true); // Lặp lại animation

    // Animation thay đổi kích thước cho vòng tròn viền đỏ
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controlleranimation, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      // WidgetsBinding.instance.addPostFrameCallback((_) {

      requestPermissions();

      if (webrtcServices.isPTZConnect == true) {
        webrtcServices.setIsPTZConnect = false;
      }
      webrtcServices.setIsDropdownOpen = false;
      webrtcServices.setidCamera = widget.idcamera;

      //  cloudRecordControllers.fetchListImageAllPlayback(widget.idcamera);

      // webrtcServices.setIsClickSdcard = true; // Thay đổi trạng thái khi nhấn

      webrtcServices.setIsClickHuman = false;

      webrtcServices.setIsClickMotion = false;
      //  webrtcServices.setIsClickAll = false;

      // });

      Future.delayed(Duration(milliseconds: 500), () {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args != null && args is RemoteMessage) {
          final messageOutApp = args;
          print("messageOutApp: $messageOutApp");

          // Kiểm tra dữ liệu có đầy đủ để gọi hàm htmimgPlaybackPreviewFile
          if (messageOutApp.data.containsKey('type') &&
              messageOutApp.data.containsKey('idcamera') &&
              messageOutApp.data.containsKey('ts')) {
            final orderData = messageOutApp.data;
            htmimgPlaybackPreviewFile(
              orderData['type'],
              orderData['idcamera'],
              int.parse(orderData['ts']),
            );

            webrtcServices.setIsClickAll = true;
            webrtcServices.setIsClickSdcard = false;
            cloudRecordControllers
                .fetchListImageAllPlayback(orderData['idcamera']);
          } else {
            print("⚠️ Dữ liệu thông báo không đầy đủ.");
          }
        } else {
          print("⚠️ Không tìm thấy dữ liệu từ thông báo!");
        }
      });

      final message = ModalRoute.of(context)?.settings.arguments;
      if (message != null && message is NotificationResponse) {
        print("message: $message");
        var orderData = jsonDecode(message.payload.toString());
        htmimgPlaybackPreviewFile(orderData['type'], orderData['idcamera'],
            int.parse(orderData['ts']));

        webrtcServices.setIsClickAll = true;
        webrtcServices.setIsClickSdcard = false;
        cloudRecordControllers.fetchListImageAllPlayback(orderData['idcamera']);
      } else {
        print("⚠️ Không có dữ liệu NotificationResponse!");
      }
    });
  }

  Future<void> htmimgPlaybackPreviewFile(
      String data, String idcamera, int ts) async {
    notifiControllerssss.setLoadingNotification = true;
    String resultdata = data.split(':')[0];
    String resultdata1 = data.split(':')[1];
    if (resultdata == "cloud_mtd_img_path") {
      notifiControllerssss.setTextData = "getMtdImgFileUrl";
      cloudRecordControllers.setTsMotion = ts;
    }

    if (resultdata == "cloud_hmd_img_path") {
      notifiControllerssss.setTextData = "getHmdImgFileUrl";
      cloudRecordControllers.setTsHuman = ts;
    }

    print("resultdata: " + data);
    print("resultdata1: " + resultdata1);

    print("textData: " + notifiControllerssss.textData);
    cloudRecordControllers.setPathHtmImage = resultdata1;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/${notifiControllerssss.textData}";
    print("url htmimgPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idcamera,
          resultdata: resultdata1,
        }),
      );

      if (response.statusCode == 200) {
        print(
            "linkvideo htmimgPlaybackPreviewFile notifi: ${cloudRecordControllers.pathHtmImage}");

        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        cloudRecordControllers.setPathHtmImageUrl = presignedUrl;
        print(
            "Link url htmimgPlaybackPreviewFile: ${cloudRecordControllers.pathHtmImageUrl}");
        notifiControllerssss.setLoadingNotification = false;
        // Khởi tạo controller và phát video
      } else if (response.statusCode == 401) {
        notifiControllerssss.setLoadingNotification = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        notifiControllerssss.setLoadingNotification = false;
        ToastComponent.showToast(message: "Load Image Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      notifiControllerssss.setLoadingNotification = false;
      print("Error htmimgPlaybackPreviewFile: $e");
    }
  }

  @override
  void dispose() {
    if (webrtcServices.isRecording) {
      _stopRecording();
    }
    if (webrtcServices.gatheringCompleter != null &&
        !webrtcServices.gatheringCompleter!.isCompleted) {
      webrtcServices.gatheringCompleter
          ?.completeError("Disposed before completion");
    }
    cloudRecordControllers.currentItemIndex.value = 0;
    cloudRecordControllers.setbuttonListSDCard = 0;
    webrtcServices.disconnect();
    webrtcServices.setIsSounding = false;
    webrtcServices.setVolume = 1.0;
    webrtcServices.fileList.clear();
    _controlleranimation.dispose();
    //   cloudRecordControllers.dispose();
    super.dispose();
  }

  Future<void> _pickTime(Map<String, dynamic> schedule, String key) async {
    final context = Get.context!;
    final initialTime = webrtcServices.millisecondsToTime(schedule[key]);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      schedule[key] = webrtcServices.timeToMilliseconds(pickedTime);
      webrtcServices.scheduleData.refresh();
    }
  }

  // Bắt đầu ghi màn hình
  Future<void> _startRecording() async {}

  Future<void> _stopRecording() async {}

  // Future<void> _requestPermissions() async {
  //   await Permission.camera.request();
  //   await Permission.microphone.request();
  // }

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
    final webrtcService = Get.put(WebRTCServiceController());
    final notifiControllerssss = Get.put(NotificationController());
    final cloudRecordController = Get.put(CloudRecordPathController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () async {
              await webrtcServices.disconnect();
              cloudRecordController.setPathHtmImageUrl = '';
              cloudRecordController.setTsHuman = -1;
              cloudRecordController.setTsMotion = -1;
              webrtcService.setIsSounding = false; // T
              Get.to(() => MainScreen(),
                  transition: Transition.fade,
                  duration: const Duration(seconds: 1));
            },
          ),
          title: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Tooltip(
                message: "${widget.label}",
                child: Text(
                  "${widget.label}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cloudRecordController.pathHtmImageUrl != ''
                          ? AspectRatio(
                              aspectRatio: 16 / 9,
                              child: GestureDetector(
                                onHorizontalDragEnd: cloudRecordController
                                        .isLoadNextandPrevious
                                    ? null
                                    : (details) {
                                        // Kiểm tra hướng vuốt
                                        if (details.primaryVelocity != null) {
                                          if (details.primaryVelocity! < 0) {
                                            // Vuốt sang trái
                                            cloudRecordController
                                                .loadNextImage(widget.idcamera);
                                          } else if (details.primaryVelocity! >
                                              0) {
                                            // Vuốt sang phải
                                            cloudRecordController
                                                .loadPreviousImage(
                                                    widget.idcamera);
                                          }
                                        }
                                      },
                                child: CachedNetworkImage(
                                  imageUrl:
                                      cloudRecordController.pathHtmImageUrl,
                                  placeholder: (context, url) => Center(
                                      child: LoadingAnimationWidget
                                          .fourRotatingDots(
                                    color: Colors.black,
                                    size: 30,
                                  )),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            )
                          : AspectRatio(
                              aspectRatio: 16 / 9,
                              child: webrtcService.isConnecting
                                  ? Stack(
                                      children: [
                                        RepaintBoundary(
                                          key: _regionKey,
                                          child: Screenshot(
                                            controller: screenshotController,
                                            child: InkWell(
                                              onDoubleTap: () => Get.to(
                                                  () => FullscreenVideoPage(
                                                        webrtcService:
                                                            webrtcService,
                                                        idcamera:
                                                            widget.idcamera,
                                                      ),
                                                  transition: Transition.native,
                                                  duration: const Duration(
                                                      seconds: 1)),
                                              child: webrtcService
                                                          .remoteRenderer
                                                          .srcObject ==
                                                      null
                                                  ? Center(
                                                      child: Text(
                                                        "Error",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )
                                                  : RTCVideoView(
                                                      webrtcService
                                                          .remoteRenderer,
                                                      mirror: false,
                                                      objectFit:
                                                          RTCVideoViewObjectFit
                                                              .RTCVideoViewObjectFitContain,
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            child: Center(
                                              child: webrtcServices
                                                      .isLoadingSDCard
                                                  ? Center(
                                                      child:
                                                          LoadingAnimationWidget
                                                              .fourRotatingDots(
                                                      color: Colors.white,
                                                      size: 30,
                                                    ))
                                                  : SizedBox(),
                                            ))
                                      ],
                                    )
                                  : Container(
                                      color: Colors.black,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () async {
                                            print(
                                                "ipcUuid: ${widget.idcamera}");
                                            await requestPermissions();

                                            if (webrtcService.isConnecting) {
                                              await webrtcService.disconnect();
                                              webrtcService.setIsSounding =
                                                  false;

                                              ToastComponent.showToast(
                                                  message: "Stop play");
                                            } else {
                                              await webrtcService.connect(
                                                  ipcUuid: widget.idcamera);
                                              cloudRecordController
                                                  .setPathHtmImageUrl = '';
                                            }
                                          },
                                          child: webrtcService.isConnecting
                                              ? Container()
                                              : webrtcService.isLoading
                                                  ? Center(
                                                      child:
                                                          LoadingAnimationWidget
                                                              .fourRotatingDots(
                                                      color: Colors.white,
                                                      size: 30,
                                                    ))
                                                  : const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 70,
                                                    ),
                                        ),
                                      ),
                                    ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // Điều chỉnh âm lượng
                  if (webrtcService.isSounding)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: Row(
                        children: [
                          !webrtcService.isConnecting
                              ? InkWell(
                                  onTap: () {
                                    ToastComponent.showToast(
                                        message:
                                            "You need to connect the camera before mute");
                                  },
                                  child: Icon(
                                    Icons.volume_up_outlined,
                                    color: Colors.grey,
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    await webrtcService
                                        .initializeStream(); // Lấy MediaStream
                                    webrtcService.toggleMute();
                                  },
                                  child: Icon(webrtcService.isAudioEnabled
                                      ? Icons.volume_up_outlined
                                      : Icons.volume_off)),
                          !webrtcServices.isConnecting
                              ? Expanded(
                                  child: Slider(
                                    value: webrtcService.volume,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    label:
                                        "${(webrtcService.volume * 100).toStringAsFixed(0)}%",
                                    onChanged: (double value) async {
                                      ToastComponent.showToast(
                                          message:
                                              "You need to connect the camera before mute");
                                    },
                                  ),
                                )
                              : Expanded(
                                  child: Slider(
                                    value: webrtcService.volume,
                                    min: 0.0,
                                    max: 1.0,
                                    divisions: 10,
                                    label:
                                        "${(webrtcService.volume * 100).toStringAsFixed(0)}%",
                                    onChanged: (double value) async {
                                      webrtcService.setVolume = value;

                                      await webrtcService.initializeStream();
                                      webrtcService
                                          .adjustVolume(webrtcService.volume);
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),

                  // Các nút điều khiển
                  if (cloudRecordController.pathHtmImageUrl == '')
                    PtzCamera(
                      idcamera: widget.idcamera,
                    ),

                  if (cloudRecordController.pathHtmImageUrl != '')
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  cloudRecordController.setPathHtmImageUrl = '';
                                  cloudRecordController.setbuttonListSDCard = 0;
                                  webrtcService.setIsClickSdcard = true;
                                  webrtcService.setIsClickHuman = false;
                                  webrtcService.setIsClickMotion = false;
                                  webrtcService.setIsClickAll = false;

                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    webrtcService.connect(
                                        ipcUuid: widget.idcamera);
                                  });
                                },
                                child: Card(
                                  color: Colors.grey.shade100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.arrow_left,
                                          color: Colors.black,
                                          size: 30.sp,
                                        ),
                                      ),
                                      // Sử dụng Transform để chỉ thay đổi kích thước của vòng tròn mà không ảnh hưởng đến giao diện
                                      AnimatedBuilder(
                                        animation: _controlleranimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 +
                                                (_animation.value *
                                                    0.5), // Tăng tỷ lệ để làm cho vòng tròn phóng to
                                            child: Container(
                                              height: 10.0,
                                              width: 10.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      Colors.red, // Viền màu đỏ
                                                  width: 3.0,
                                                ),
                                              ),
                                              child: Container(
                                                height: 5.0,
                                                width: 5.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors
                                                      .red, // Màu đỏ bên trong
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Live',
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                          if (notifiControllerssss.textData ==
                              'getHmdImgFileUrl')
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDeleteConfirmationDialog(context, () {
                                      cloudRecordController.downloadImageHtm(
                                          cloudRecordController.pathHtmImage,
                                          widget.idcamera);
                                    },
                                        "Are you sure you want to download this? This action cannot be undone.",
                                        const Icon(
                                          Icons.download,
                                          size: 50,
                                          color: Colors.black,
                                        ),
                                        'Download',
                                        'Download');
                                  },
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.black,
                                    size: 20.sp,
                                  ),
                                ),
                                Text(
                                  "Download",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          if (notifiControllerssss.textData ==
                              'getMtdImgFileUrl')
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDeleteConfirmationDialog(context, () {
                                      cloudRecordController.downloadImageMtd(
                                          cloudRecordController.pathMtdImage,
                                          widget.idcamera);
                                    },
                                        "Are you sure you want to download this? This action cannot be undone.",
                                        const Icon(
                                          Icons.download,
                                          size: 50,
                                          color: Colors.black,
                                        ),
                                        'Download',
                                        'Download');
                                  },
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.black,
                                    size: 20.sp,
                                  ),
                                ),
                                Text(
                                  "Download",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            width: 16.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Get.to(
                                      () => FullScreenPlayback(
                                            idcamera: widget.idcamera,
                                          ),
                                      transition: Transition.native,
                                      duration: const Duration(seconds: 1));
                                },
                                icon: Icon(
                                  Icons.fullscreen,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                              ),
                              Text(
                                "Fullscreen",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: cloudRecordController
                                        .isLoadNextandPrevious
                                    ? null
                                    : () {
                                        cloudRecordController
                                            .loadPreviousImage(widget.idcamera);
                                      },
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                              ),
                              Text(
                                "Previous",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed:
                                    cloudRecordController.isLoadNextandPrevious
                                        ? null
                                        : () {
                                            cloudRecordController
                                                .loadNextImage(widget.idcamera);
                                          },
                                icon: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                              ),
                              Text(
                                "Next",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 16.w,
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16.h),

                  Divider(
                    color: Colors.grey[200],
                    thickness: 16,
                  ),

                  SizedBox(height: 16.h),
                  // chuc naang quay trai, phai, tren, duoi

                  if (webrtcService.isPTZConnect)
                    PtzCameraControl(
                      idcamera: widget.idcamera,
                    ),

                  if (!webrtcService.isTimer)
                    Obx(() => webrtcService.scheduleData.isEmpty
                        ? Center(
                            child: Text(
                              'No schedule data',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : TimerCamera(
                            idcamera: widget.idcamera,
                          )),

                  if (!webrtcService.isPTZConnect && webrtcService.isTimer)
                    ListIconImag(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isClickHuman)
                    LoadDownloadHuman(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isClickMotion)
                    LoadDownMotion(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isClickAll)
                    LoadDownAll(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isConnecting && webrtcService.isClickSdcard)
                    LoadDownloadSdcard(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isClickHuman)
                    PlayBackHdmImg(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isClickMotion)
                    PlayBackImageMotion(
                      idcamera: widget.idcamera,
                    ),

                  if (webrtcService.isClickAll)
                    PlayBackAllImg(
                      idcamera: widget.idcamera,
                    ),

                  // if (webrtcService.isClickSdcard)
                  //   PlayBackVideoSdcard(
                  //     idcamera: widget.idcamera,
                  //   ),

                  if (webrtcService.isConnecting && webrtcService.isClickSdcard)
                    PlayBackVideoSdcard(
                      idcamera: widget.idcamera,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
