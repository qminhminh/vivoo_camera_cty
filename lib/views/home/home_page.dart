// ignore_for_file: prefer_interpolation_to_compose_strings, body_might_complete_normally_nullable, deprecated_member_use, avoid_print, unused_import, no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_local_variable, prefer_const_constructors, unrelated_type_equality_checks, library_private_types_in_public_api

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vivoo_camera_cty/common/shimmer/list_camera_shimmer.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/home_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/services/notifi_socket_services.dart';
import 'package:vivoo_camera_cty/views/camera/camera_page.dart';
import 'package:vivoo_camera_cty/views/camera/play_back_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController homeController;
  late LoginController loginController;
  late WebRTCServiceController webrtcService;
  late NotificationController notifiController;
  late ScrollController _scrollController;

  bool isConnected = true;
  TextEditingController labelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    homeController = Get.put(HomeController());
    loginController = Get.put(LoginController());
    webrtcService = Get.put(WebRTCServiceController());
    notifiController = Get.put(NotificationController());
    _scrollController = ScrollController();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    Future.delayed(const Duration(seconds: 1), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loginController.getProfileUser();
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notificationService = NotificationServiceSocket();
        notificationService.connect(loginController.token);
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homeController.fetchCameras();
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.addListener(() {
          if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent &&
              homeController.currentPage.value + 1 <
                  homeController.totalPages.value) {
            homeController.fetchCamerasLoad(
              page: homeController.currentPage.value + 1,
            );
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          //         Colors.black, // Màu đen
          //         Colors.grey.shade800, // Màu xám
          //         Colors.white, // Màu trắng
          //       ],
          //       stops: const [0.0, 0.5, 1.0], // Điểm dừng của màu
          //     ),
          //   ),
          // ),
          elevation: 0,
          backgroundColor: Colors.blueGrey.shade900,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: 200, // Đặt chiều rộng cho phần leading
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Camera",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r)),
            child: Container(
              height: ScreenUtil().screenHeight,
              color: kOffWhite,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Obx(
                    //   () => Container(
                    //     padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       border: Border(
                    //         top: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             Text(
                    //               "Items: ",
                    //               style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    //             ),
                    //             SizedBox(width: 1.w),
                    //             DropdownButton<int>(
                    //               value: homeController.itemsPerPage.value,
                    //               items: [10, 20, 30]
                    //                   .map((e) => DropdownMenuItem(
                    //                         value: e,
                    //                         child: Text("$e"),
                    //                       ))
                    //                   .toList(),
                    //               onChanged: (value) {
                    //                 if (value != null) {
                    //                   homeController.itemsPerPage.value = value;
                    //                   homeController.fetchCameras(
                    //                       page: 0, pageSize: value);
                    //                 }
                    //               },
                    //             ),
                    //           ],
                    //         ),
                    //         Obx(
                    //           () => Row(
                    //             children: [
                    //               Text(
                    //                 "${homeController.currentPage.value + 1} - ${homeController.totalItems.value} of ${homeController.totalItems.value}",
                    //                 style:
                    //                     TextStyle(fontSize: 14.sp, color: Colors.black),
                    //               ),
                    //               IconButton(
                    //                 icon: const Icon(Icons.chevron_left),
                    //                 onPressed: homeController.currentPage.value > 0
                    //                     ? () => homeController.fetchCameras(
                    //                           page: homeController.currentPage.value - 1,
                    //                         )
                    //                     : null,
                    //               ),
                    //               IconButton(
                    //                 icon: const Icon(Icons.chevron_right),
                    //                 onPressed: homeController.currentPage.value + 1 <
                    //                         homeController.totalPages.value
                    //                     ? () => homeController.fetchCamerasLoad(
                    //                           page: homeController.currentPage.value + 1,
                    //                         )
                    //                     : null,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 10.h),
                    Obx(() {
                      if (homeController.isLoading) {
                        return Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.black,
                          size: 30,
                        ));
                      }

                      return GestureDetector(
                        onVerticalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            // Vuốt xuống
                            print("Vuốt xuống để tải lại dữ liệu");
                            homeController.fetchCameras(); // Tải lại dữ liệu
                          }
                        },
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: homeController.cameras.length,
                            itemBuilder: (context, index) {
                              final camera = homeController.cameras[index];
                              if (homeController.cameras.isNotEmpty) {
                                return InkWell(
                                  onTap: () {
                                    print("idcamera1: ${camera.id}");
                                    webrtcService.setIsClickAll = false;
                                    Get.to(
                                        () => CameraPage(
                                              idcamera: camera.id,
                                              label: camera.label,
                                            ),
                                        transition: Transition.native,
                                        duration: const Duration(seconds: 1));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 5.h, horizontal: 10.w),
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Tooltip(
                                                message: camera
                                                    .label, // Hiển thị đầy đủ nội dung khi hover
                                                child: Text(
                                                  camera.label,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Text(
                                                camera.name,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(height: 5.h),
                                            Text(
                                              camera.active
                                                  ? "Online"
                                                  : "Offline",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: camera.active
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              labelController.text =
                                                  camera.label;

                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor: Colors
                                                        .white, // Màu nền đen cho AlertDialog
                                                    title: const Text(
                                                      "Edit Label",
                                                      style: TextStyle(
                                                        color: Colors
                                                            .black, // Màu chữ trắng cho tiêu đề
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: TextField(
                                                      controller:
                                                          labelController,
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .black), // Màu chữ trắng cho nội dung
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Enter new label",
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey[
                                                                400]), // Màu chữ nhạt cho hint
                                                        enabledBorder:
                                                            const UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .black), // Viền trắng khi không chọn
                                                        ),
                                                        focusedBorder:
                                                            const UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .black), // Viền trắng khi đang chọn
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        labelController.text =
                                                            value;
                                                      },
                                                    ),
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.grey[
                                                                      300],
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Đóng dialog
                                                            },
                                                            child: const Text(
                                                              "Cancle",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.black,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              if (labelController
                                                                  .text
                                                                  .isNotEmpty) {
                                                                print(
                                                                    "label: ${labelController.text}");
                                                                homeController
                                                                    .editCamera(
                                                                        camera
                                                                            .id,
                                                                        labelController
                                                                            .text);
                                                              } else {
                                                                Get.snackbar(
                                                                    "Error",
                                                                    "Label cannot be empty",
                                                                    colorText:
                                                                        kLightWhite,
                                                                    backgroundColor:
                                                                        kDark,
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .check));
                                                              }
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              "Save",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                            if (value == 'cameraview') {
                                              webrtcService.setIsClickAll =
                                                  false;
                                              Get.to(
                                                  () => CameraPage(
                                                        idcamera: camera.id,
                                                        label: camera.label,
                                                      ),
                                                  transition: Transition.native,
                                                  duration: const Duration(
                                                      seconds: 1));
                                              print("idcamera: ${camera.id}");
                                            }
                                            if (value == 'playback') {
                                              Get.to(
                                                  () => PLayBackVideo(
                                                        idcamera: camera.id,
                                                      ),
                                                  transition: Transition.native,
                                                  duration: const Duration(
                                                      seconds: 1));
                                              print("idcamera: ${camera.id}");
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text("Edit Label"),
                                              ),
                                              const PopupMenuItem(
                                                value: 'cameraview',
                                                child: Text("Camera View"),
                                              ),
                                              const PopupMenuItem(
                                                value: 'playback',
                                                child: Text("Playback"),
                                              ),
                                            ];
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera,
                                        size: 200,
                                      ),
                                      SizedBox(
                                          height:
                                              16), // Khoảng cách giữa ảnh và văn bản
                                      Text(
                                        'Camera in here',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
