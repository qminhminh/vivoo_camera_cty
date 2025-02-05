// ignore_for_file: prefer_final_fields, empty_catches, prefer_interpolation_to_compose_strings, avoid_print, prefer_const_constructors, body_might_complete_normally_nullable, unnecessary_null_in_if_null_operators

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'package:vivoo_camera_cty/views/camera/camera_page.dart';
import 'package:vivoo_camera_cty/views/main/main_page.dart';
import 'package:vivoo_camera_cty/views/profile/notification_settings.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  RxBool _isLoadingUpdate = false.obs;

  bool get isLoadingUpdate => _isLoadingUpdate.value;

  set setLoadingUpdate(bool newValue) {
    _isLoadingUpdate.value = newValue;
  }

  RxString _token = ''.obs;
  String get token => _token.value;
  set setToken(String newValue) {
    _token.value = newValue;
  }

  RxString _idUser = ''.obs;
  String get idUser => _idUser.value;
  set setidUser(String newValue) {
    _idUser.value = newValue;
  }

  RxBool _isLoadChangePass = false.obs;
  bool get isLoadChangePass => _isLoadChangePass.value;
  set setLoadChangePass(bool newValue) {
    _isLoadChangePass.value = newValue;
  }

  void loginFunc(String model) async {
    setLoading = true;

    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/login');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: model,
      );

      if (response.statusCode == 200) {
        setLoading = false;
        final data = jsonDecode(response.body);
        setToken = data['token'];

        final datauser = jsonDecode(model);

        box.write("username", datauser['username']);
        box.write("password", datauser['password']);

        print("username" + datauser['username']);
        print("token" + data['token']);

        await getProfileUser();

        Get.offAll(() => MainScreen(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
        Get.snackbar("Log in successfully", "Enjoy your wonderful experience",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("loginFunc: ${response.statusCode}" + data['message']);
        Get.snackbar(
          "Log in failed",
          data['message'],
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      setLoading = false;
      print("Error loginFunc: $e");
      Get.snackbar(
        "Log in failed",
        "Unknown error",
        colorText: kLightWhite,
        backgroundColor: kRed,
        icon: const Icon(Icons.error),
      );
    } finally {
      setLoading = false;
    }
  }

  void loginFuncStart(String model) async {
    setLoading = true;

    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/login');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: model,
      );

      if (response.statusCode == 200) {
        setLoading = false;
        final data = jsonDecode(response.body);
        setToken = data['token'];

        final datauser = jsonDecode(model);

        box.write("username", datauser['username']);
        box.write("password", datauser['password']);

        print("username" + datauser['username']);
        print("token" + data['token']);
        await getProfileUser();

        FirebaseMessaging.instance.getInitialMessage().then((message) {
          if (message == null) {
            Get.offAll(() => MainScreen(),
                transition: Transition.fade,
                duration: const Duration(seconds: 2));
          } else {
            navigateToScreen(message);
          }
        });
      } else if (response.statusCode == 401) {
        Get.snackbar(
          "Log in failed",
          "Invalid username or password",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
        box.erase();

        Get.offAll(() => const LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("loginFuncStart: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      setLoading = false;

      print("Error loginFuncStart: $e");
    } finally {
      setLoading = false;
    }
  }

  void navigateToScreen(RemoteMessage message) {
    if (message.data.containsKey('screen')) {
      print('message.data: ${message.data}');
      String screen =
          message.data['screen']; // Lấy dữ liệu màn hình từ thông báo
      if (screen == 'order_details_page') {
        // final entryController = Get.put(MainScreenController());
        // entryController.setTabIndex = 1;
        // Get.toNamed('/order_details_page',arguments: message); // Điều hướng đến màn hình chat
        // navigatorKey.currentState
        //     ?.pushNamed('/order_details_page', arguments: message);
        try {
          // Giải mã dữ liệu từ message.data
          final payloadData = message.data;

          // Chuyển đến CameraPage với dữ liệu từ thông báo
          Get.to(
            () => CameraPage(
              idcamera: payloadData['idcamera'] ?? '',
              label: payloadData['label'] ?? '',
            ),
            arguments: message,
          );
        } catch (e) {
          print("Error decoding message data: $e");
        }
      }
    }
  }

  void loginFuncStartClickNotifi(String model) async {
    setLoading = true;

    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/login');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: model,
      );

      if (response.statusCode == 200) {
        setLoading = false;
        final data = jsonDecode(response.body);
        setToken = data['token'];

        final datauser = jsonDecode(model);

        box.write("username", datauser['username']);
        box.write("password", datauser['password']);

        print("username" + datauser['username']);
        print("token" + data['token']);
        await getProfileUser();

        Get.offAll(() => NotificationSettingPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else if (response.statusCode == 401) {
        Get.snackbar(
          "Log in failed",
          "Invalid username or password",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
        box.erase();

        Get.offAll(() => const LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("loginFuncStart: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      setLoading = false;

      print("Error loginFuncStart: $e");
    } finally {
      setLoading = false;
    }
  }

  Future<void> getProfileUser() async {
    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/user');

    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'x-authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        box.write('userId', data["customerId"]["id"]);
        print("userId" + box.read("userId").toString());
        setidUser = data["customerId"]["id"].toString();
      } else {
        final data = jsonDecode(response.body);
        print("getProfileUser: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error getProfileUser: $e");
    } finally {}
  }

  Future<void> getProfileUserEdit() async {
    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/user');

    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'x-authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("email: " + data["email"]);

        // Gán dữ liệu vào các biến Rx của LoginController

        print("First Name: ${data['firstName']}");
        print("Last Name: ${data['lastName']}");
        print("Phone: ${data['phone']}");
        print("Email: ${data['email']}");

        print("phone: " + data["phone"]);
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Get user failed", data['message'],
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
        print("getProfileUserEdit: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error getProfileUserEdit: $e");
    } finally {}
  }

  Future<Map<String, dynamic>?> getProfileUserEditController() async {
    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/user');

    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'x-authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Get user failed", data['message'],
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
        print("getProfileUserEditController: ${response.statusCode}" +
            data['message']);
        return null;
      }
    } catch (e) {
      print("Error getProfileUserEditController: $e");
      return null;
    } finally {}
  }

  Future<void> updateProfileUserEdit(
      String phone, String firstname, String lastname, String email) async {
    setLoadingUpdate = true;
    var url = Uri.parse(
        '${Environment.appBaseUrl}/api/user?sendActivationMail=false');

    try {
      final data = await getProfileUserEditController();
      if (data == null) return;

      int? phoneInt = int.tryParse(phone);

      data["firstName"] = firstname == "" ? null : firstname;
      data["lastName"] = lastname == "" ? null : lastname;
      data["phone"] = phoneInt ?? null;
      data["email"] = email == "" ? null : email;

      print("data: " + jsonEncode(data));

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      print("response.statusCode" + response.statusCode.toString());
      if (response.statusCode == 200) {
        setLoadingUpdate = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Update profile success", "update profile success",
            colorText: Colors.black, icon: const Icon(Icons.check));

        print("phone: " + data["phone"]);
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadingUpdate = false;
        final data = jsonDecode(response.body);
        print(
            "updateProfileUserEdit: ${response.statusCode}" + data['message']);
        Get.snackbar("Get user failed", data['message'],
            colorText: Colors.black, icon: const Icon(Icons.error));
        print("error: " + data['message']);
      }
    } catch (e) {
      setLoadingUpdate = false;
      print("Error updateProfileUserEdit: $e");
    } finally {}
  }

  Future<void> refreshToken() async {
    setLoading = true;

    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/login');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "username": box.read('username'),
          "password": box.read('password')
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setToken = data['token'];
      } else {
        final data = jsonDecode(response.body);
        print("refreshToken: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error refreshToken: $e");
    } finally {}
  }

  bool isTokenExpired(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw ArgumentError('Invalid token');
    }
    final payloadBase64 = base64Url.normalize(parts[1]);
    final payloadString = utf8.decode(base64Url.decode(payloadBase64));
    final Map<String, dynamic> payload = json.decode(payloadString);
    final expiryTime = (payload['exp'] as int) * 1000;
    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }

  void logout() async {
    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/logout');

    try {
      var response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Get.snackbar(
            "Signed out successfully", "See you next time, have a nice day",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
        box.erase();

        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("logout: ${response.statusCode}" + data['message']);
        Get.snackbar("Sign out failed", data['message'],
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
      }
    } catch (e) {
      print("Error logout: $e");
      Get.snackbar("Sign out failed", "Unknown error",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error));
    } finally {}
  }

  Future<void> changePassword(String currentPass, String newPass) async {
    setLoadChangePass = true;
    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/changePassword');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer $token',
        },
        body: jsonEncode(
          {
            "currentPassword": currentPass,
            "newPassword": newPass,
          },
        ),
      );
      if (response.statusCode == 200) {
        setLoadChangePass = false;
        Get.snackbar(
            "Change Password successfully", "Change Password successfully",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else if (response.statusCode == 401) {
        setLoadChangePass = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadChangePass = false;
        final data = jsonDecode(response.body);
        print("changePassword: ${response.statusCode}" + data['message']);
        Get.snackbar("Change Password false", data['message'],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      setLoadChangePass = false;
      print("Error changePassword: $e");
      Get.snackbar("Change Password false", "Unknown error",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    } finally {
      setLoadChangePass = false;
    }
  }
}
