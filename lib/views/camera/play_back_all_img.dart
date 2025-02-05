// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, curly_braces_in_flow_control_structures, unnecessary_null_comparison, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';

class PlayBackAllImg extends StatefulWidget {
  const PlayBackAllImg({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<PlayBackAllImg> createState() => _PlayBackAllImgState();
}

class _PlayBackAllImgState extends State<PlayBackAllImg> {
  final box = GetStorage();
  final loginControler = Get.put(LoginController());
  final cloudRecordControllessr = Get.put(CloudRecordPathController());
  Timer? _debounce;

  String convertTsToDatetime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Map<String, List<dynamic>> groupVideosByDateHuman(List<dynamic> videos) {
    Map<String, List<dynamic>> groupedVideosHuman = {};

    for (var video in videos) {
      // Chuyển đổi video.value thành ngày tháng năm giờ phút
      String formattedDate =
          convertTsToDatetime(video.ts); // Astssuming video.value is a string

      if (!groupedVideosHuman.containsKey(_extractTimeDay(formattedDate))) {
        groupedVideosHuman[_extractTimeDay(formattedDate)] = [];
      }
      // Thêm video vào nhóm ngày tương ứng
      groupedVideosHuman[_extractTimeDay(formattedDate)]?.add(video);
    }

    return groupedVideosHuman;
  }

  Map<String, List<dynamic>> groupVideosByDateMotion(List<dynamic> videos) {
    Map<String, List<dynamic>> groupedVideosMotion = {};

    for (var video in videos) {
      // Chuyển đổi video.value thành ngày tháng năm giờ phút
      String formattedDate =
          convertTsToDatetime(video.ts); // Astssuming video.value is a string

      if (!groupedVideosMotion.containsKey(_extractTimeDay(formattedDate))) {
        groupedVideosMotion[_extractTimeDay(formattedDate)] = [];
      }
      // Thêm video vào nhóm ngày tương ứng
      groupedVideosMotion[_extractTimeDay(formattedDate)]?.add(video);
    }

    return groupedVideosMotion;
  }

  int getVisibleCount(List<dynamic> videos, String formattedDate) {
    if (videos == null || videos.isEmpty) return 0;
    if (videos.length >= 4) {
      if (cloudRecordControllessr.isShowMore(formattedDate)) {
        return videos.length;
      } else {
        return 4;
      }
    }
    return videos.length;
  }

  Future<void> htmimgPlaybackPreviewFile(String cloudPath) async {
    cloudRecordControllessr.setLoadingHuman = true;
    cloudRecordControllessr.setPathHtmImage = cloudPath;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getHmdImgFileUrl";
    print("url htmimgPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": widget.idcamera,
          "cloud_hmd_img_path": cloudPath,
        }),
      );

      if (response.statusCode == 200) {
        print(
            "linkvideo htmimgPlaybackPreviewFile: ${cloudRecordControllessr.pathHtmImage}");

        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        cloudRecordControllessr.setPathHtmImageUrl = presignedUrl;
        print(
            "Link url htmimgPlaybackPreviewFile: ${cloudRecordControllessr.pathHtmImageUrl}");
        cloudRecordControllessr.setLoadingHuman = false;
        // Khởi tạo controller và phát video
      } else if (response.statusCode == 401) {
        cloudRecordControllessr.setLoadingHuman = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        cloudRecordControllessr.setLoadingHuman = false;
        ToastComponent.showToast(message: "Load Image Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      cloudRecordControllessr.setLoadingHuman = false;
      print("Error htmimgPlaybackPreviewFile: $e");
    }
  }

  String _extractTime(String formattedDate) {
    List<String> dateParts = formattedDate.split(' ');
    if (dateParts.length > 1) {
      return dateParts[1];
    } else {
      return '';
    }
  }

  String _extractTimeDay(String formattedDate) {
    List<String> dateParts = formattedDate.split(' ');
    if (dateParts.length > 1) {
      return dateParts[0];
    } else {
      return '';
    }
  }

  Future<void> mtdimgPlaybackPreviewFile(String cloudPath) async {
    cloudRecordControllessr.setLoadingMotion = true;
    cloudRecordControllessr.setPathMtdImage = cloudPath;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getMtdImgFileUrl";
    print("url mtdimgPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": widget.idcamera,
          "cloud_mtd_img_path": cloudPath,
        }),
      );

      if (response.statusCode == 200) {
        print(
            "linkvideo mtdimgPlaybackPreviewFile: ${cloudRecordControllessr.pathMtdImage}");

        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        cloudRecordControllessr.setPathHtmImageUrl = presignedUrl;
        print(
            "Link url mtdimgPlaybackPreviewFile: ${cloudRecordControllessr.pathMtdImageUrl}");
        // Khởi tạo controller và phát video
        cloudRecordControllessr.setLoadingMotion = false;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
        cloudRecordControllessr.setLoadingMotion = false;
      } else {
        cloudRecordControllessr.setLoadingMotion = false;
        ToastComponent.showToast(message: "Load Image Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      cloudRecordControllessr.setLoadingMotion = false;
      print("Error mtdimgPlaybackPreviewFile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cloudRecordController = Get.put(CloudRecordPathController());
    final webrtcService = Get.put(WebRTCServiceController());
    final notifiControllerssss = Get.put(NotificationController());

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: CustomScrollView(
        slivers: [
          Obx(() {
            return cloudRecordController.cloudrecordshmdimg.isNotEmpty
                ? SliverToBoxAdapter(
                    child: Text(
                      "   Human",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Text(
                    "",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ));
          }),
          Obx(() {
            if (cloudRecordController.cloudrecordshmdimg.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Icon(
                        FontAwesomeIcons.person,
                        size: 150,
                      ),

                      SizedBox(height: 16), // Khoảng cách giữa ảnh và văn bản
                      Text(
                        'Play back Human in here',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final groupedVideoshmd = groupVideosByDateHuman(
                cloudRecordController.cloudrecordshmdimg);
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  String formattedDate = groupedVideoshmd.keys.elementAt(index);
                  List<dynamic> videos = groupedVideoshmd[formattedDate] ?? [];
                  if (videos.isEmpty) {
                    return SizedBox
                        .shrink(); // Không hiển thị gì nếu videos trống
                  }
                  if (videos.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                formattedDate.isNotEmpty ? formattedDate : "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 16.h),
                              Obx(
                                () => Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      cloudRecordController
                                              .isShowMore(formattedDate)
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 30.sp,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      ToastComponent.showToast(
                                          message: "Load Success");
                                      cloudRecordController
                                          .toggleShowMoreAdd4List(
                                              formattedDate, 4);
                                      cloudRecordController
                                          .toggleShowMore(formattedDate);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Obx(() {
                            final visibleCount =
                                cloudRecordController.getVisibleItemCount(
                                    formattedDate, videos.length);

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio:
                                    2.5, // Điều chỉnh tỷ lệ để giảm chiều cao
                              ),
                              itemCount: visibleCount,
                              itemBuilder: (context, videoIndex) {
                                var video = videos[videoIndex];
                                if (video == null ||
                                    (video.value == null ||
                                        video.value.isEmpty) ||
                                    video.ts == null) {
                                  return SizedBox
                                      .shrink(); // Nếu không có dữ liệu thì không hiển thị gì
                                }

                                return GestureDetector(
                                  onTap: cloudRecordControllessr.isLoadingHuman
                                      ? null
                                      : () async {
                                          if (webrtcService.isConnecting) {
                                            await webrtcService.disconnect();
                                          }
                                          cloudRecordControllessr.setTsHuman =
                                              video.ts;

                                          int foundIndex = cloudRecordController
                                              .cloudrecordshmdimg
                                              .indexWhere((record) =>
                                                  record.ts ==
                                                  cloudRecordController
                                                      .currentTsHuman);
                                          cloudRecordController
                                                  .currentItemIndex.value =
                                              (foundIndex != -1)
                                                  ? foundIndex
                                                  : 0;
                                          if (_debounce?.isActive ?? false)
                                            _debounce?.cancel();
                                          _debounce = Timer(
                                              const Duration(milliseconds: 500),
                                              () {
                                            htmimgPlaybackPreviewFile(
                                                video.value);
                                          });

                                          notifiControllerssss.setTextData =
                                              "getHmdImgFileUrl";
                                        },
                                  child: Card(
                                    color: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        color: cloudRecordController
                                                    .cloudrecordshmdimg[
                                                        cloudRecordController
                                                            .currentItemIndex
                                                            .value]
                                                    .ts ==
                                                video.ts
                                            ? Colors.black
                                            : Colors
                                                .white, // Black border color
                                        width: 2.0, // Border width
                                      ),
                                    ),
                                    elevation: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Căn chỉnh Card và IconButton gần nhau
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: SizedBox(
                                              width: 70.w,
                                              child: Tooltip(
                                                message: _extractTime(
                                                    convertTsToDatetime(
                                                        video.ts)),
                                                child: Text(
                                                  _extractTime(
                                                      convertTsToDatetime(
                                                          video.ts)),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //
                                        Obx(() {
                                          return !cloudRecordController
                                                  .isDownloading
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons.download),
                                                  onPressed: () {
                                                    showDeleteConfirmationDialog(
                                                        context, () {
                                                      cloudRecordController
                                                          .downloadImageHtm(
                                                              video.value,
                                                              widget.idcamera);
                                                    },
                                                        "Are you sure you want to download ${_extractTime(formattedDate)} this? This action cannot be undone.",
                                                        const Icon(
                                                          Icons.download,
                                                          size: 50,
                                                          color: Colors.black,
                                                        ),
                                                        'Download',
                                                        'Download');
                                                  },
                                                )
                                              : Container();
                                        })
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          if (videos.length > 4)
                            Obx(
                              () => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 30.sp,
                                        color: Colors.grey[500],
                                      ),
                                      label: Text(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? 'Collapse'
                                            : 'Show 4 items',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      onPressed: () {
                                        ToastComponent.showToast(
                                            message: "Load Success");

                                        cloudRecordController
                                            .toggleShowMoreAdd4List(
                                                formattedDate, videos.length);
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 30.sp,
                                        color: Colors.grey[500],
                                      ),
                                      label: Text(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? 'Collapse'
                                            : 'Show more',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      onPressed: () {
                                        ToastComponent.showToast(
                                            message: "Load Success");

                                        cloudRecordController
                                            .toggleShowMoreAdd4List(
                                                formattedDate, 4);
                                        cloudRecordController
                                            .toggleShowMore(formattedDate);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 10.h),
                          Divider(color: Colors.grey.shade300, height: 1.0),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text("No image found"));
                  }
                },
                childCount: groupedVideoshmd.keys.isNotEmpty
                    ? groupedVideoshmd.keys.length
                    : 0,
              ),
            );
          }),
          SliverToBoxAdapter(
            child: SizedBox(
              width: 10.w,
            ),
          ),
          Obx(() {
            return cloudRecordController.cloudrecordMtdimg.isNotEmpty
                ? SliverToBoxAdapter(
                    child: Text(
                      "   Motion",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Text(
                      "",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  );
          }),
          Obx(() {
            if (cloudRecordController.cloudrecordMtdimg.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Icon(
                        FontAwesomeIcons.exchangeAlt,
                        size: 150,
                      ),

                      SizedBox(height: 16), // Khoảng cách giữa ảnh và văn bản
                      Text(
                        'Play back Motion in here',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            final groupedVideos = groupVideosByDateMotion(
                cloudRecordController.cloudrecordMtdimg);
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  String formattedDate = groupedVideos.keys.elementAt(index);
                  List<dynamic> videos = groupedVideos[formattedDate] ?? [];
                  if (videos.isEmpty) {
                    return SizedBox
                        .shrink(); // Không hiển thị gì nếu videos trống
                  }

                  if (videos.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                formattedDate.isNotEmpty ? formattedDate : "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 16.h),
                              Obx(
                                () => Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      cloudRecordController
                                              .isShowMore(formattedDate)
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 30.sp,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      ToastComponent.showToast(
                                          message: "Load Success");
                                      cloudRecordController
                                          .toggleShowMoreAdd4List(
                                              formattedDate, 4);
                                      cloudRecordController
                                          .toggleShowMore(formattedDate);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Obx(() {
                            final visibleCount =
                                cloudRecordController.getVisibleItemCount(
                                    formattedDate, videos.length);

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio:
                                    2.5, // Điều chỉnh tỷ lệ để giảm chiều cao
                              ),
                              itemCount: visibleCount,
                              itemBuilder: (context, videoIndex) {
                                var video = videos[videoIndex];
                                if (video == null ||
                                    (video.value == null ||
                                        video.value.isEmpty) ||
                                    video.ts == null) {
                                  return SizedBox
                                      .shrink(); // Nếu không có dữ liệu thì không hiển thị gì
                                }
                                return GestureDetector(
                                  onTap: cloudRecordControllessr.isLoadingMotion
                                      ? null
                                      : () async {
                                          if (webrtcService.isConnecting) {
                                            await webrtcService.disconnect();
                                          }
                                          cloudRecordControllessr.setTsMotion =
                                              video.ts;
                                          int foundIndex =
                                              cloudRecordControllessr
                                                  .cloudrecordMtdimg
                                                  .indexWhere((record) =>
                                                      record.ts ==
                                                      cloudRecordControllessr
                                                          .currentTsMotion);
                                          cloudRecordControllessr
                                                  .currentItemIndexMotion
                                                  .value =
                                              (foundIndex != -1)
                                                  ? foundIndex
                                                  : 0;

                                          if (_debounce?.isActive ?? false)
                                            _debounce?.cancel();
                                          _debounce = Timer(
                                              const Duration(milliseconds: 500),
                                              () {
                                            mtdimgPlaybackPreviewFile(
                                                video.value);
                                          });
                                          notifiControllerssss.setTextData =
                                              "getMtdImgFileUrl";
                                        },
                                  child: Card(
                                    color: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                        color: cloudRecordController
                                                    .cloudrecordMtdimg[
                                                        cloudRecordController
                                                            .currentItemIndexMotion
                                                            .value]
                                                    .ts ==
                                                video.ts
                                            ? Colors.black
                                            : Colors
                                                .white, // Black border color
                                        width: 2.0, // Border width
                                      ),
                                    ),
                                    elevation: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Căn chỉnh Card và IconButton gần nhau
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: SizedBox(
                                              width: 70.w,
                                              child: Tooltip(
                                                message: _extractTime(
                                                    convertTsToDatetime(
                                                        video.ts)),
                                                child: Text(
                                                  _extractTime(
                                                      convertTsToDatetime(
                                                          video.ts)),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        //
                                        Obx(() {
                                          return !cloudRecordController
                                                  .isDownloading
                                              ? IconButton(
                                                  icon: const Icon(
                                                      Icons.download),
                                                  onPressed: () {
                                                    showDeleteConfirmationDialog(
                                                        context, () {
                                                      cloudRecordController
                                                          .downloadImageMtd(
                                                              video.value,
                                                              widget.idcamera);
                                                    },
                                                        "Are you sure you want to download ${_extractTime(formattedDate)} this? This action cannot be undone.",
                                                        const Icon(
                                                          Icons.download,
                                                          size: 50,
                                                          color: Colors.black,
                                                        ),
                                                        'Download',
                                                        'Download');
                                                  },
                                                )
                                              : Container();
                                        })
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          if (videos.length > 4)
                            Obx(
                              () => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 30.sp,
                                        color: Colors.grey[500],
                                      ),
                                      label: Text(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? 'Collapse'
                                            : 'Show 4 items',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      onPressed: () {
                                        ToastComponent.showToast(
                                            message: "Load Success");

                                        cloudRecordController
                                            .toggleShowMoreAdd4List(
                                                formattedDate, videos.length);
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 30.sp,
                                        color: Colors.grey[500],
                                      ),
                                      label: Text(
                                        cloudRecordController
                                                .isShowMore(formattedDate)
                                            ? 'Collapse'
                                            : 'Show more',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      onPressed: () {
                                        ToastComponent.showToast(
                                            message: "Load Success");

                                        cloudRecordController
                                            .toggleShowMoreAdd4List(
                                                formattedDate, 4);
                                        cloudRecordController
                                            .toggleShowMore(formattedDate);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 10.h),
                          Divider(color: Colors.grey.shade300, height: 1.0),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text("No image found"));
                  }
                },
                childCount: groupedVideos.keys.isNotEmpty
                    ? groupedVideos.keys.length
                    : 0,
              ),
            );
          }),
        ],
      ),
    );
  }
}
