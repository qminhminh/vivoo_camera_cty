// ignore_for_file: avoid_print, avoid_function_literals_in_foreach_calls, unnecessary_import, prefer_interpolation_to_compose_strings, prefer_final_fields

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';

class NotificationSettingController extends GetxController {
  var notificationSettings = {}.obs;
  var deliveryMethods = <String>[].obs;
  var notificationTypes = {}.obs;
  var isLoading = true.obs;
  final box = GetStorage();
  RxBool _isLoadingSave = false.obs;
  bool get isLoadingSave => _isLoadingSave.value;
  set setisLoadingSave(bool value) => _isLoadingSave.value = value;

  @override
  void onInit() {
    super.onInit();
    fetchNotificationSettings();
    fetchDeliveryMethods();
  }

  Future<void> fetchNotificationSettings() async {
    notificationSettings.value = {};
    final url =
        Uri.parse('https://demo.espitek.com/api/notification/settings/user');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'x-authorization': 'Bearer ${Get.find<LoginController>().token}',
      });
      if (response.statusCode == 200) {
        final prefs = json.decode(response.body)['prefs'];
        notificationSettings.value = prefs;
        notificationTypes.value = {
          for (var key in prefs.keys) key: prefs[key]['enabled']
        };
        isLoading.value = false;
      } else if (response.statusCode == 401) {
        box.erase();

        Get.offAll(() => const LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("fetchNotificationSettings: ${response.statusCode}" +
            data['message']);
      }
    } catch (e) {
      print('Error fetching notification settings: $e');
    }
  }

  Future<void> fetchDeliveryMethods() async {
    deliveryMethods.value = [];
    final url =
        Uri.parse('${Environment.appBaseUrl}/api/notification/deliveryMethods');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'x-authorization': 'Bearer ${Get.find<LoginController>().token}',
      });
      if (response.statusCode == 200) {
        final methods = List<String>.from(json.decode(response.body));
        deliveryMethods.value =
            methods.where((method) => method != "MICROSOFT_TEAMS").toList();
      } else if (response.statusCode == 401) {
        box.erase();

        Get.offAll(() => const LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("fetchDeliveryMethods: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print('Error fetching delivery methods: $e');
    }
  }

  void updateDeliveryMethod(String key, String method, bool value) {
    notificationSettings[key]['enabledDeliveryMethods'][method] = value;
    notificationSettings.refresh();
  }

  void updateEnabledSetting(String key, bool value) {
    notificationSettings[key]['enabled'] = value;
    notificationSettings.refresh();
  }

  void updateNotificationType(String key, bool value) {
    notificationTypes[key] = value;
    if (!value) {
      deliveryMethods.forEach((method) {
        notificationSettings[key]['enabledDeliveryMethods'][method] = false;
      });
      notificationSettings[key]['enabled'] = false;
    }
    notificationSettings.refresh();
  }

  Future<void> saveSettings() async {
    setisLoadingSave = true;
    final url =
        Uri.parse('${Environment.appBaseUrl}/api/notification/settings/user');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${Get.find<LoginController>().token}',
        },
        body: json.encode({'prefs': notificationSettings}),
      );
      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Notification updated successfully",
          colorText: Colors.black,
          icon: const Icon(Icons.check),
        );
        setisLoadingSave = false;
      } else if (response.statusCode == 401) {
        box.erase();

        Get.offAll(() => const LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("saveSettings: ${response.statusCode}" + data['message']);
        Get.snackbar(
          "Get user failed",
          "${data['message']}",
          colorText: kLightWhite,
          icon: const Icon(Icons.error),
        );
        setisLoadingSave = false;
      }
    } catch (e) {
      print('Error saving settings: $e');
      setisLoadingSave = false;
      Get.snackbar(
        "Error",
        "Error saving settings",
        colorText: kLightWhite,
        backgroundColor: kRed,
        icon: const Icon(Icons.error),
      );
    }
  }
}
