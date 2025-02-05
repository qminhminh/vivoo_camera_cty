// ignore_for_file: prefer_final_fields, use_build_context_synchronously, avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';

class CheckconnectWifiController extends GetxController {
  RxBool _isConnected = false.obs;
  bool get isConnected => _isConnected.value;
  set setIsConnected(bool value) {
    _isConnected.value = value;
  }

  Future<void> checkConnectivity(BuildContext context) async {
    // Kiểm tra kết nối và đảm bảo không gọi setState() nếu widget đã bị dispose
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    // Removed mounted check as it is not applicable in GetxController

    if (results.contains(ConnectivityResult.none)) {
      setIsConnected = false;

      showDeleteConfirmationDialog(context, () {
        Get.back();
      },
          "No internet connection",
          const Icon(
            Icons.wifi_off,
            size: 50,
            color: Colors.black,
          ),
          'Connect ',
          'Connect');
    } else {
      setIsConnected = true;

      // Get.to(() => MainScreen()); // Trở lại giao diện chính khi kết nối lại
    }

    print("Check connectivity: $_isConnected");
  }
}
