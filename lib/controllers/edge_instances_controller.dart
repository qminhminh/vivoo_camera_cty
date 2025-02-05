// ignore_for_file: avoid_print, prefer_final_fields, prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/edge_instance_model.dart';
import '../models/environment.dart';
import '../views/auth/login_page.dart';

class EdgeInstanceController extends GetxController {
  final loginControler = Get.put(LoginController());
  var edgeintances = <EdgeData>[].obs;
  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;
  final box = GetStorage();

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  Future<void> fetchAllEdgeInstances({int page = 0, int? pageSize}) async {
    setLoading = true;

    print("itemsPerPage: ${itemsPerPage.value}");
    print("currentPage: ${currentPage.value}");
    print("customId: ${loginControler.idUser}");
//https://demo.espitek.com/api/customer/46644520-6ac6-11ef-b026-a95007aa89ee/edgeInfos?pageSize=10&page=0&sortProperty=createdTime&sortOrder=DESC&type=
    final String url =
        "${Environment.appBaseUrl}/api/customer/${box.read("userId")}/edgeInfos?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&type=";
    print("url: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );
      print("response: ${response.body}");

      if (response.statusCode == 200) {
        setLoading = false;

        // Giải mã dữ liệu
        final data = json.decode(response.body);

        final assetResponse = EdgeModel.fromJson(data);

        // Cập nhật assets
        if (page == 0) {
          edgeintances.value = assetResponse.data;
        } else {
          edgeintances.addAll(assetResponse.data);
        }

        currentPage.value = page;
        totalPages.value = assetResponse.totalPages;
        totalItems.value = assetResponse.totalElements;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error fetch All Edge Instances", "${data['message']}");
        print(
            "fetchAllEdgeInstances: ${response.statusCode} ${data['message']}");
      }
    } catch (e) {
      print("Error fetchAllEdgeInstances: $e");
      setLoading = false;
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      setLoading = false;
    }
  }
}
