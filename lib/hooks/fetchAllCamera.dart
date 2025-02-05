// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vivoo_camera_cty/controllers/home_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/camera.dart';
import 'package:vivoo_camera_cty/models/hook_models.dart/hook_result.dart';
import '../models/environment.dart';

FetchHook fetchAllCameras() {
  final cameras = useState<List<Camera>?>(null);
  final isLoading = useState(false);
  final error = useState<Exception?>(null);
  final box = GetStorage();
  final loginController = Get.put(LoginController());
  final homeController = Get.put(HomeController());

  Future<void> fetchCameras({int page = 0, int? pageSize}) async {
    isLoading.value = true;
    cameras.value = null;
    final String url =
        "${Environment.appBaseUrl}/api/customer/${box.read("userId")}/deviceInfos?pageSize=${pageSize ?? 10}&page=$page&sortProperty=createdTime&sortOrder=DESC";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginController.token}',
        },
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        final data = json.decode(response.body);
        final cameraResponse = CameraResponse.fromJson(data);

        if (page == 0) {
          cameras.value = cameraResponse.cameras;
        } else {
          cameras.value?.addAll(cameraResponse.cameras);
        }

        homeController.currentPage.value = page;
        homeController.totalPages.value = cameraResponse.totalPages;
        homeController.totalItems.value = cameraResponse.totalElements;
      } else {
        isLoading.value = false;
        // Handle error, e.g., using Get.snackbar
      }
    } catch (e) {
      isLoading.value = false;
      error.value = Exception(e.toString());
      // Handle error, e.g., using Get.snackbar
    }
  }

  useEffect(() {
    fetchCameras(); // Automatically fetch cameras when the hook is used
    return null;
  }, []); // Empty dependency array means the effect runs only once, similar to `componentDidMount`

  void refetch() {
    isLoading.value = true;
    fetchCameras();
  }

  return FetchHook(
    data: cameras.value,
    isLoading: isLoading.value,
    error: error.value,
    refetch: refetch,
  );
}
