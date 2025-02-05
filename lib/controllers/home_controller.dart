// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, prefer_final_fields, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'dart:convert';
import '../models/camera.dart';

class HomeController extends GetxController {
  final loginControler = Get.put(LoginController());
  final box = GetStorage();
  var cameras = <Camera>[].obs;
  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  RxBool _isCheckInternet = false.obs;
  bool get isCheckInternet => _isCheckInternet.value;
  set setCheckInternet(bool newValue) {
    _isCheckInternet.value = newValue;
  }

  Future<void> fetchCameras({int page = 0, int? pageSize}) async {
    setLoading = true;
    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    cameras.clear();

    final String url =
        "${Environment.appBaseUrl}/api/customer/${box.read("userId")}"
        "/deviceInfos?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC";
    print("url" + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        setLoading = false;
        final data = json.decode(response.body);
        final cameraResponse = CameraResponse.fromJson(data);
        if (page == 0) {
          cameras.value = cameraResponse.cameras;
        } else {
          cameras.addAll(cameraResponse.cameras);
        }
        currentPage.value = page;
        totalPages.value = cameraResponse.totalPages;
        totalItems.value = cameraResponse.totalElements;
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        print("fetchCameras: ${response.statusCode}" + data['message']);
        // Get.snackbar("Error", "${data['message']}");
      }
      update();
    } catch (e) {
      print("Error fetchCameras: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
      update();
    }
  }

  Future<void> fetchCamerasLoad({int page = 0, int? pageSize}) async {
    setLoading = true;
    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    //cameras.clear();

    final String url =
        "${Environment.appBaseUrl}/api/customer/${box.read("userId")}"
        "/deviceInfos?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC";
    print("url" + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        setLoading = false;
        final data = json.decode(response.body);
        final cameraResponse = CameraResponse.fromJson(data);
        if (page == 0) {
          cameras.value = cameraResponse.cameras;
        } else {
          cameras.addAll(cameraResponse.cameras);
        }
        currentPage.value = page;
        totalPages.value = cameraResponse.totalPages;
        totalItems.value = cameraResponse.totalElements;
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        print("fetchCameras: ${response.statusCode}" + data['message']);
        // Get.snackbar("Error", "${data['message']}");
      }
      update();
    } catch (e) {
      print("Error fetchCameras: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
      update();
    }
  }

  Future<Map<String, dynamic>?> getDetailCamera(String id) async {
    try {
      final response = await http.get(
        Uri.parse("${Environment.appBaseUrl}/api/device/$id"),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data; // Trả về dữ liệu JSON
      } else {
        final data = jsonDecode(response.body);

        print("getDetailCamera: ${response.statusCode}" + data['message']);

        Get.snackbar(
          "Get user failed",
          "${data['message']}",
          colorText: kLightWhite,
          backgroundColor: kRed,
          icon: const Icon(Icons.error),
        );
        return null;
      }
    } catch (e) {
      // Get.snackbar("Error", e.toString());
      print("Error getDetailCamera: $e");
      return null;
    }
  }

  Future<void> editCamera(String id, String newLabel) async {
    try {
      // Lấy dữ liệu chi tiết camera
      final data = await getDetailCamera(id);
      if (data == null) return;

      // Chỉ thay đổi giá trị label
      data['label'] = newLabel;
      print("datacamera: " + json.encode(data));

      // Gửi request cập nhật
      final response = await http.post(
        Uri.parse("${Environment.appBaseUrl}/api/device"),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
        body: json.encode(data), // Chuyển đổi object thành JSON
      );

      if (response.statusCode == 200) {
        await fetchCameras();
        Get.snackbar(
          "Success",
          "Camera updated successfully",
          colorText: Colors.black,
          icon: const Icon(Icons.check),
        );
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        print("editCamera: ${response.statusCode}" + data['message']);
        Get.snackbar(
          "Error",
          "${data['message']}",
          colorText: Colors.black,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      print("Error editCamera: $e");
      //Get.snackbar("Error", e.toString());
    }
  }
}
