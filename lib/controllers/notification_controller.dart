// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, prefer_final_fields, prefer_const_constructors, unnecessary_import

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/models/notication_model.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'login_controller.dart';

class NotificationController extends GetxController {
  final loginControler = Get.put(LoginController());
  var notifications = <NotificationData>[].obs;
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

  RxBool _isCheckRead = false.obs;
  bool get isCheckRead => _isCheckRead.value;
  set setCheckRead(bool newValue) {
    _isCheckRead.value = newValue;
  }

  RxBool _isCheckSocketConnect = false.obs;
  bool get isCheckSocketConnect => _isCheckSocketConnect.value;
  set setCheckSocketConnect(bool newValue) {
    _isCheckSocketConnect.value = newValue;
  }

  RxInt _unread = 0.obs;
  int get unread => _unread.value;
  set setUnread(int newValue) {
    _unread.value = newValue;
  }

  RxString _textData = "".obs;
  String get textData => _textData.value;
  set setTextData(String newValue) {
    _textData.value = newValue;
  }

  RxString _textChannel = "".obs;
  String get textChannel => _textChannel.value;
  set setTextChannel(String newValue) {
    _textChannel.value = newValue;
  }

  RxBool _isLoadingNotification = false.obs;
  bool get isLoadingNotification => _isLoadingNotification.value;
  set setLoadingNotification(bool newValue) {
    _isLoadingNotification.value = newValue;
  }

  RxBool _isSearchVisible = false.obs;
  bool get isSearchVisible => _isSearchVisible.value;
  set setSearchVisible(bool newValue) {
    _isSearchVisible.value = newValue;
  }

  RxBool _isReadSelected = true.obs;
  bool get isReadSelected => _isReadSelected.value;
  set setReadSelected(bool newValue) {
    _isReadSelected.value = newValue;
  }

  RxBool _checkSelectionRead = false.obs;
  bool get checkSelectionRead => _checkSelectionRead.value;
  set setCheckSelectionRead(bool newValue) {
    _checkSelectionRead.value = newValue;
  }

  RxBool _isReadSelectedIcon = true.obs;
  bool get isReadSelectedIcon => _isReadSelectedIcon.value;
  set setReadSelectedIcon(bool newValue) {
    _isReadSelectedIcon.value = newValue;
  }

  Future<void> fetchNotificationUnread({int page = 0, int? pageSize}) async {
    notifications.clear();
    setLoadingNotification = true;
    box.remove("unread");

    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    final String url =
        "${Environment.appBaseUrl}/api/notifications?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&unreadOnly=true";
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
        final notificationResponse = NotificationResponse.fromJson(data);

        notifications.addAll(notificationResponse.data);

        currentPage.value = page;
        totalPages.value = notificationResponse.totalPages;
        totalItems.value = notificationResponse.totalElements;
        setLoadingNotification = false;
      } else if (response.statusCode == 401) {
        setLoadingNotification = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadingNotification = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error Fetch Unread", "${data['message']}");

        print("fetchNotificationUnread: ${response.statusCode}" +
            data['message']);
      }
      update();
    } catch (e) {
      print("Error fetchNotificationUnread: $e");
      setLoadingNotification = false;
      update();
    } finally {
      setLoadingNotification = false;
    }
  }

  Future<void> fetchNotificationUnreadHome(
      {int page = 0, int? pageSize}) async {
    setLoadingNotification = true;
    notifications.clear();
    box.remove("unread");

    final String url =
        "${Environment.appBaseUrl}/api/notifications?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&unreadOnly=true";
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
        box.write("unread", notifications.length.toInt());
      } else {
        final data = jsonDecode(response.body);
        // Get.snackbar("Error", "${data['message']}");
        print("fetchNotificationUnreadHome: ${response.statusCode}" +
            data['message']);
      }
    } catch (e) {
      print("Error fetchNotificationUnreadHome: $e");
    } finally {}
  }

  Future<void> fetchNotification(
      {int page = 0, int? pageSize, required bool checkreadOnly}) async {
    //  notifications.clear();
    setLoading = true;
    box.remove("unread");

    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    final String url =
        "${Environment.appBaseUrl}/api/notifications?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&unreadOnly=$checkreadOnly";
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
        final notificationResponse = NotificationResponse.fromJson(data);

        notifications.addAll(notificationResponse.data);

        currentPage.value = page;
        totalPages.value = notificationResponse.totalPages;
        totalItems.value = notificationResponse.totalElements;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error Fetch Unread", "${data['message']}");

        print("fetchNotificationUnread: ${response.statusCode}" +
            data['message']);
      }
      update();
    } catch (e) {
      print("Error fetchNotificationUnread: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
    }
  }

  Future<void> fetchNotificationRead({int page = 0, int? pageSize}) async {
    notifications.clear();
    setLoadingNotification = true;
    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    final String url =
        "${Environment.appBaseUrl}/api/notifications?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&unreadOnly=false";
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
        final notificationResponse = NotificationResponse.fromJson(data);

        notifications.addAll(notificationResponse.data);

        currentPage.value = page;
        totalPages.value = notificationResponse.totalPages;
        totalItems.value = notificationResponse.totalElements;
        setLoadingNotification = false;
      } else if (response.statusCode == 401) {
        setLoadingNotification = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadingNotification = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error", "${data['message']}");
        print("fetchNotificationUnread: ${response.statusCode}" +
            data['message']);
      }
    } catch (e) {
      setLoadingNotification = false;
      print("fetchNotificationUnreadHome catch: " + e.toString());
    } finally {
      setLoadingNotification = false;
    }
  }

  Future<void> maskAllAsRead() async {
    setLoadingNotification = true;
    final String url = "${Environment.appBaseUrl}/api/notifications/read";
    print("url" + url);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        setLoadingNotification = false;
        Get.snackbar("Mask all As Read", "Enjoy your wonderful experience",
            colorText: Colors.black, icon: const Icon(Icons.check));
      } else if (response.statusCode == 401) {
        setLoadingNotification = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadingNotification = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error", "${data['message']}");
        print("maskAllAsRead: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error maskAllAsRead catch: $e");
      setLoadingNotification = false;
    } finally {
      setLoadingNotification = false;
    }
  }

  Future<void> refreshNotification(
      {int page = 0, int? pageSize, required bool checkreadOnly}) async {
    notifications.clear();
    setLoadingNotification = true;
    print("itemsPerPage" + itemsPerPage.value.toString());
    print("currentPage" + currentPage.value.toString());
    print("customId" + loginControler.idUser);

    final String url =
        "${Environment.appBaseUrl}/api/notifications?pageSize=${itemsPerPage.value}&page=$page&sortProperty=createdTime&sortOrder=DESC&unreadOnly=$checkreadOnly";
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
        final data = json.decode(response.body);
        final notificationResponse = NotificationResponse.fromJson(data);

        notifications.addAll(notificationResponse.data);

        currentPage.value = page;
        totalPages.value = notificationResponse.totalPages;
        totalItems.value = notificationResponse.totalElements;
        setLoadingNotification = false;
      } else if (response.statusCode == 401) {
        setLoadingNotification = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadingNotification = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error", "${data['message']}");
        print("refreshNotification: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error fetchCameras catch: $e");
      setLoadingNotification = false;
    } finally {
      setLoadingNotification = false;
    }
  }

  Future<void> searchNotification(
      {int page = 0,
      int? pageSize,
      required bool checkreadOnly,
      required String text}) async {
    notifications.clear();
    final String url =
        "${Environment.appBaseUrl}/api/notifications?pageSize=${itemsPerPage.value}&page=$page&textSearch=$text&sortProperty=createdTime&sortOrder=DESC&unreadOnly=$checkreadOnly";
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
        final notificationResponse = NotificationResponse.fromJson(data);

        notifications.addAll(notificationResponse.data);

        currentPage.value = page;
        totalPages.value = notificationResponse.totalPages;
        totalItems.value = notificationResponse.totalElements;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error", "${data['message']}");
        print("searchNotification: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error fetchCameras catch: $e");
      setLoading = false;
    } finally {
      setLoading = false;
    }
  }

  Future<void> deleteNotification(String id) async {
    final String url = "${Environment.appBaseUrl}/api/notification/$id";
    print("url" + url);
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar("Delete Notification", "Enjoy your wonderful experience",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error", "${data['message']}");
        print("deleteNotification: ${response.statusCode}" + data['message']);
      }
    } catch (e) {
      print("Error deleteNotification catch: $e");
    } finally {}
  }
}
