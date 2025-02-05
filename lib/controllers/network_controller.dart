import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/services/notifi_socket_services.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final loginController = Get.put(LoginController());
  final notificationService = NotificationServiceSocket();

  @override
  void onInit() {
    super.onInit();
    // Listen for connectivity changes and handle the connectivity list
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResults) {
      // Assuming you need to handle the first result
      _updateConnectionStatus(connectivityResults.first);
    });
  }

  // Update the connection status
  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      // If no connection, show Snackbar
      if (!Get.isSnackbarOpen) {
        Get.rawSnackbar(
          messageText: const Text(
            'PLEASE CONNECT TO THE INTERNET',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.red[400]!,
          icon: const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 35,
          ),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED,
        );
      }
    } else {
      // If there is an internet connection, close the Snackbar
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        notificationService.connect(loginController.token);
      }
    }
  }
}
