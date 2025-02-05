// ignore_for_file: prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, prefer_const_constructors, prefer_const_declarations

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/asset_profile_info_model.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';

class AssetsController extends GetxController {
  final loginControler = Get.put(LoginController());
  var assets = <Asset>[].obs;
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

  // Future<void> fetchAllAssets({int page = 0, int? pageSize}) async {
  //   setLoading = true;

  //   print("itemsPerPage" + itemsPerPage.value.toString());
  //   print("currentPage" + currentPage.value.toString());
  //   print("customId" + loginControler.idUser);

  //   final String url =
  //       "${Environment.appBaseUrl}/api/customer/${box.read("userId")}/assetInfos?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&assetProfileId=${box.read("userId")}";
  //   print("url" + url);
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'x-authorization': 'Bearer ${loginControler.token}',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       setLoading = false;
  //       final data = json.decode(response.body);
  //       final assetResponse = AssetResponse.fromJson(data);

  //       if (page == 0) {
  //         assets.value = assetResponse.data!;
  //       } else {
  //         assets.addAll(assetResponse.data!);
  //       }

  //       currentPage.value = page;
  //       totalPages.value = assetResponse.totalPages!;
  //       totalItems.value = assetResponse.totalElements!;
  //     } else if (response.statusCode == 401) {
  //       box.erase();
  //       Get.offAll(() => LoginPage(),
  //           transition: Transition.fade, duration: const Duration(seconds: 2));
  //     } else {
  //       setLoading = false;
  //       final data = jsonDecode(response.body);
  //       Get.snackbar("Error fetch All Assets", "${data['message']}");

  //       print("fetchAllAssets: ${response.statusCode}" + data['message']);
  //     }
  //   } catch (e) {
  //     print("Error fetchCameras: $e");
  //     setLoading = false;
  //   } finally {
  //     setLoading = false;
  //   }
  // }

  Future<void> fetchAllAssetsSearch({int page = 0, int? pageSize}) async {
    setLoading = true;

    print("itemsPerPage: ${itemsPerPage.value}");
    print("currentPage: ${currentPage.value}");
    print("customId: ${loginControler.idUser}");

    final String url =
        "https://demo.espitek.com/api/assetProfileInfos?pageSize=${itemsPerPage.value}&page=$page&sortProperty=name&sortOrder=ASC";
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

        final assetResponse = DeviceResponse.fromJson(data);

        // Cập nhật assets
        if (page == 0) {
          assets.value = assetResponse.data;
        } else {
          assets.addAll(assetResponse.data);
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
        Get.snackbar("Error fetching all assets", "${data['message']}");
        print(
            "fetchAllAssetsSearch: ${response.statusCode} ${data['message']}");
      }
    } catch (e) {
      print("Error fetchAllAssetsSearch: $e");
      setLoading = false;
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      setLoading = false;
    }
  }

  Future<void> fetchTextSearchAssetsSearch(
      {int page = 0, int? pageSize, String? textsearch}) async {
    setLoading = true;

    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    final String url =
        "${Environment.appBaseUrl}/api/assetProfileInfos?pageSize=${itemsPerPage.value}&page=$page&textSearch=$textsearch&sortProperty=name&sortOrder=ASC";
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
        final assetResponse = DeviceResponse.fromJson(data);

        if (page == 0) {
          assets.value = assetResponse.data;
        } else {
          assets.addAll(assetResponse.data);
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
        Get.snackbar("Error fetch Text Search Assets", "${data['message']}");

        print("fetchTextSearchAssetsSearch: ${response.statusCode}" +
            data['message']);
      }
    } catch (e) {
      print("Error fetchTextSearchAssetsSearch: $e");
      setLoading = false;
    } finally {
      setLoading = false;
    }
  }
}
