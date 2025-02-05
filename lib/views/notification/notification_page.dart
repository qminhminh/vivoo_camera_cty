// ignore_for_file: prefer_const_constructors, unnecessary_import, prefer_const_literals_to_create_immutables, avoid_print, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, unrelated_type_equality_checks, sort_child_properties_last

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/checkconnect_wifi_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'package:vivoo_camera_cty/views/camera/camera_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  TextEditingController textSearchController = TextEditingController();
  final checkinternetController = Get.put(CheckconnectWifiController());

  final notifiControllerssss = Get.put(NotificationController());
  final box = GetStorage();
  final loginControler = Get.put(LoginController());
  final cloudRecordControllessr = Get.put(CloudRecordPathController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // final loginCtronller = Get.put(LoginController());
    // // final notificationService = NotificationServiceSocket();
    // // notificationService.connect(loginCtronller.token);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          notifiControllerssss.currentPage.value + 1 <
              notifiControllerssss.totalPages.value) {
        notifiControllerssss.fetchNotification(
          page: notifiControllerssss.currentPage.value + 1,
          checkreadOnly: notifiControllerssss.isCheckRead,
        );
      }
    });

    Future.delayed(Duration(milliseconds: 500), () {
      notifiControllerssss.setReadSelected = true;
      notifiControllerssss.fetchNotificationUnread(page: 0);
    });
  }

  @override
  void dispose() {
    // final notificationService = NotificationServiceSocket();

    // if (notificationService.channel != null) {
    //   notificationService.disconnect();
    // }
    _scrollController.dispose();
    textSearchController.dispose();
    super.dispose();
  }

  Future<void> htmimgPlaybackPreviewFile(
      String data, String idcamera, int ts) async {
    notifiControllerssss.setLoadingNotification = true;
    String resultdata = data.split(':')[0];
    String resultdata1 = data.split(':')[1];
    if (resultdata == "cloud_mtd_img_path") {
      notifiControllerssss.setTextData = "getMtdImgFileUrl";
      cloudRecordControllessr.setTsMotion = ts;
    }

    if (resultdata == "cloud_hmd_img_path") {
      notifiControllerssss.setTextData = "getHmdImgFileUrl";
      cloudRecordControllessr.setTsHuman = ts;
    }

    print("resultdata: " + data);
    print("resultdata1: " + resultdata1);

    print("textData: " + notifiControllerssss.textData);
    cloudRecordControllessr.setPathHtmImage = resultdata1;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/${notifiControllerssss.textData}";
    print("url htmimgPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idcamera,
          resultdata: resultdata1,
        }),
      );

      if (response.statusCode == 200) {
        print(
            "linkvideo htmimgPlaybackPreviewFile notifi: ${cloudRecordControllessr.pathHtmImage}");

        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        cloudRecordControllessr.setPathHtmImageUrl = presignedUrl;
        print(
            "Link url htmimgPlaybackPreviewFile: ${cloudRecordControllessr.pathHtmImageUrl}");
        notifiControllerssss.setLoadingNotification = false;
        // Khởi tạo controller và phát video
      } else if (response.statusCode == 401) {
        notifiControllerssss.setLoadingNotification = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        notifiControllerssss.setLoadingNotification = false;
        ToastComponent.showToast(message: "Load Image Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      notifiControllerssss.setLoadingNotification = false;
      print("Error htmimgPlaybackPreviewFile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifiControllers = Get.put(NotificationController());
    final cloudRecordController = Get.put(CloudRecordPathController());
    final webrtcService = Get.put(WebRTCServiceController());
    return Obx(
      () => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.blueGrey.shade900,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: AppBar(
            // flexibleSpace: Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Colors.black,
            //         Colors.grey.shade800,
            //         Colors.white,
            //       ],
            //       stops: const [0.0, 0.5, 1.0],
            //     ),
            //   ),
            // ),
            elevation: 0,
            backgroundColor: Colors.blueGrey.shade900,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: const Text(
                "Notification",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  notifiControllers.setSearchVisible =
                      !notifiControllers.isSearchVisible;
                },
              ),
            ],
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r)),
            child: Container(
              height: ScreenUtil().screenHeight,
              color: kOffWhite,
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  // Toggle between Read/Unread
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(20),
                              isSelected: [
                                notifiControllers.isReadSelected,
                                !notifiControllers.isReadSelected
                              ],
                              selectedColor: Colors.white,
                              fillColor: Colors.black,
                              color: Colors.black,
                              borderWidth: 2,
                              borderColor: Colors.grey.shade300,
                              selectedBorderColor: Colors.black,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  child: Text("Unread"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  child: Text("All"),
                                ),
                              ],
                              onPressed: notifiControllers.isLoadingNotification
                                  ? null
                                  : (index) {
                                      notifiControllers.setReadSelected =
                                          index == 0;
                                      notifiControllers.setCheckSelectionRead =
                                          !notifiControllers.checkSelectionRead;

                                      if (notifiControllers.isReadSelected) {
                                        notifiControllers.setCheckRead = true;
                                        notifiControllers
                                            .fetchNotificationUnread(page: 0);
                                      } else {
                                        notifiControllers.setCheckRead = false;
                                        notifiControllers.fetchNotificationRead(
                                            page: 0);
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(20),
                              isSelected: [
                                notifiControllers.isReadSelectedIcon,
                                !notifiControllers.isReadSelectedIcon
                              ],
                              selectedColor: Colors.white,
                              fillColor: Colors.black,
                              color: Colors.black,
                              borderWidth: 2,
                              borderColor: Colors.grey.shade300,
                              selectedBorderColor: Colors.black,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  child: Icon(Icons.checklist_rounded),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  child: Icon(Icons.refresh_outlined),
                                ),
                              ],
                              onPressed: notifiControllers.isLoadingNotification
                                  ? null
                                  : (index) {
                                      notifiControllers.setReadSelectedIcon =
                                          index == 0;

                                      if (notifiControllers
                                          .isReadSelectedIcon) {
                                        notifiControllers
                                            .maskAllAsRead()
                                            .then((value) {
                                          notifiControllers.setReadSelected =
                                              index == 1;
                                          notifiControllers.refreshNotification(
                                            page: 0,
                                            pageSize: notifiControllers
                                                .itemsPerPage.value,
                                            checkreadOnly:
                                                notifiControllers.isCheckRead,
                                          );
                                        });
                                      } else {
                                        notifiControllers.refreshNotification(
                                          page: 0,
                                          pageSize: notifiControllers
                                              .itemsPerPage.value,
                                          checkreadOnly:
                                              notifiControllers.isCheckRead,
                                        );
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),
                  // Toggle between Read/Unread

                  // Search Field
                  notifiControllers.isSearchVisible
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: TextField(
                            controller: textSearchController,
                            decoration: InputDecoration(
                              labelText: 'Search',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  notifiControllers.setSearchVisible = false;
                                },
                              ),
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                notifiControllers.searchNotification(
                                  text: text,
                                  page: 0,
                                  checkreadOnly: notifiControllers.isCheckRead,
                                );
                              }
                            },
                          ),
                        )
                      : SizedBox
                          .shrink(), // Trả về widget trống nếu không hiển thị

                  SizedBox(height: 10.h),

                  // Notification List

                  notifiControllers.notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 200,
                              ),

                              SizedBox(
                                  height:
                                      16), // Khoảng cách giữa ảnh và văn bản
                              Text(
                                'Notification in here',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: notifiControllers.notifications.length,
                            itemBuilder: (context, index) {
                              var notification =
                                  notifiControllers.notifications[index];
                              return InkWell(
                                onTap: notifiControllerssss
                                        .isLoadingNotification
                                    ? null
                                    : () {
                                        htmimgPlaybackPreviewFile(
                                            notification.info.msgData['data'],
                                            notification.info.msgOriginator.id,
                                            int.parse(notification
                                                .info.msgMetadata['ts']));

                                        print(
                                            "idcamera2: ${notification.info.msgOriginator.id}");
                                        print(
                                            "msgData: ${notification.info.msgOriginator.id}");

                                        print(
                                            "ts: ${int.parse(notification.info.msgMetadata['ts'])}");
                                        print("label: ${notification.text}");

                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          webrtcService.setIsClickAll = true;
                                          webrtcService.setIsClickSdcard =
                                              false;
                                          cloudRecordController
                                              .fetchListImageAllPlayback(
                                                  notification
                                                      .info.msgOriginator.id);
                                          Get.to(
                                              () => CameraPage(
                                                    idcamera: notification
                                                        .info.msgOriginator.id,
                                                    label: notification.text,
                                                  ),
                                              transition: Transition.native,
                                              duration:
                                                  const Duration(seconds: 1));
                                        });
                                      },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      // Hiển thị icon theo loại thông báo
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          notification.type == 'RULE_NODE'
                                              ? Icons.rule
                                              : Icons.notifications,
                                          color: notification.status == 'READ'
                                              ? Colors.grey
                                              : Colors.blue,
                                          size: 30,
                                        ),
                                      ),

                                      // Nội dung thông báo
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification.subject,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              notification.text,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: notification.status ==
                                                        'READ'
                                                    ? Colors.grey
                                                    : Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            // Hiển thị ngày tạo thông báo
                                            Text(
                                              'Created: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(notification.createdTime))}',
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Colors.grey),
                                            ),
                                            Divider(
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // // Hiển thị trạng thái
                                      // Icon(
                                      //   notification.status == 'READ'
                                      //       ? Icons.check_box
                                      //       : Icons.check_box_outline_blank,
                                      //   color: notification.status == 'READ'
                                      //       ? Colors.green
                                      //       : Colors.red,
                                      // ),

                                      PopupMenuButton<int>(
                                        icon: Icon(
                                            Icons.more_vert), // Dấu ba chấm dọc
                                        onSelected: (value) {
                                          // Xử lý các hành động khi chọn menu
                                          if (value == 1) {
                                            htmimgPlaybackPreviewFile(
                                                notification
                                                    .info.msgData['data'],
                                                notification
                                                    .info.msgOriginator.id,
                                                int.parse(notification
                                                    .info.msgMetadata['ts']));
                                            print(
                                                "idcamera2: ${notification.info.msgOriginator.id}");
                                            Get.to(
                                                () => CameraPage(
                                                      idcamera: notification
                                                          .info
                                                          .msgOriginator
                                                          .id,
                                                      label: notification.text,
                                                    ),
                                                transition: Transition.native,
                                                duration:
                                                    const Duration(seconds: 1));
                                          } else if (value == 2) {
                                            showDeleteConfirmationDialog(
                                                context, () {
                                              notifiControllers
                                                  .deleteNotification(
                                                      notification.id.id)
                                                  .then((value) {
                                                notifiControllers
                                                    .refreshNotification(
                                                  page: 0,
                                                  pageSize: notifiControllers
                                                      .itemsPerPage.value,
                                                  checkreadOnly:
                                                      notifiControllers
                                                          .isCheckRead,
                                                );
                                              });
                                            },
                                                "Are you sure you want to Delete? This action cannot be undone.",
                                                const Icon(
                                                  Icons.delete,
                                                  size: 50,
                                                  color: Colors.black,
                                                ),
                                                'Delete',
                                                'Delete');
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          // Mục View
                                          PopupMenuItem<int>(
                                            value: 1,
                                            child: Row(
                                              children: [
                                                Icon(Icons
                                                    .visibility), // Icon xem
                                                SizedBox(width: 8),
                                                Text("View"),
                                              ],
                                            ),
                                          ),
                                          // Mục Delete
                                          PopupMenuItem<int>(
                                            value: 2,
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete), // Icon xóa
                                                SizedBox(width: 8),
                                                Text("Delete"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 40.h),
                  // Hiển thị đếm số thông báo đã đ��c
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
