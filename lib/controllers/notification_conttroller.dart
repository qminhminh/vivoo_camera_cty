// ignore_for_file: prefer_final_fields, unnecessary_null_comparison, avoid_return_types_on_setters

// import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:main_camera_cty/models/environment.dart';

class NotificationsController extends GetxController {
  final box = GetStorage();

  RxString _fcmToken = ''.obs;

  String get fcmToken => _fcmToken.value;

  set setFcm(String newValue) {
    _fcmToken.value = newValue;
  }

  // void updateUserToken(String deviceToken) async {
  //   String token = box.read('token');
  //   String accessToken = jsonDecode(token);
  //   var url = Uri.parse(
  //       '${Environment.appBaseUrl}/api/users/updateToken/$deviceToken');

  //   try {
  //     var response = await http.put(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $accessToken'
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       var data = successResponseFromJson(response.body);
  //       debugPrint(data.message);
  //     } else {
  //       var data = apiErrorFromJson(response.body);

  //       Get.snackbar(data.message, "Failed to login, please try again",
  //           colorText: kLightWhite,
  //           backgroundColor: kRed,
  //           icon: const Icon(Icons.error));
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  RxBool _loading = false.obs;

  bool get loading => _loading.value;

  void set setLoader(bool newLoader) {
    _loading.value = newLoader;
  }
}
