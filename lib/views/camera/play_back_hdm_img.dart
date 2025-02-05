// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, unnecessary_null_comparison, avoid_print

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

class PlayBackHdmImg extends StatefulWidget {
  const PlayBackHdmImg({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<PlayBackHdmImg> createState() => _PlayBackHdmImgState();
}

class _PlayBackHdmImgState extends State<PlayBackHdmImg> {
  final box = GetStorage();
  final loginControler = Get.put(LoginController());
  final cloudRecordControllessr = Get.put(CloudRecordPathController());
  Timer? _debounce;

  String convertTsToDatetime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Map<String, List<dynamic>> groupVideosByDate(List<dynamic> videos) {
    Map<String, List<dynamic>> groupedVideos = {};

    for (var video in videos) {
      // Chuyển đổi video.value thành ngày tháng năm giờ phút
      String formattedDate =
          convertTsToDatetime(video.ts); // Astssuming video.value is a string

      if (!groupedVideos.containsKey(_extractTimeDay(formattedDate))) {
        groupedVideos[_extractTimeDay(formattedDate)] = [];
      }
      // Thêm video vào nhóm ngày tương ứng
      groupedVideos[_extractTimeDay(formattedDate)]?.add(video);
    }

    return groupedVideos;
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

//
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
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
        cloudRecordControllessr.setLoadingHuman = false;
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

  @override
  Widget build(BuildContext context) {
    final cloudRecordController = Get.put(CloudRecordPathController());
    final webrtcService = Get.put(WebRTCServiceController());
    final notifiControllerssss = Get.put(NotificationController());

    return Obx(() {
      if (cloudRecordController.cloudrecordshmdimg.isEmpty) {
        return Center(
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
        );
      }
      final groupedVideos =
          groupVideosByDate(cloudRecordController.cloudrecordshmdimg);
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  String formattedDate = groupedVideos.keys.elementAt(index);
                  List<dynamic> videos = groupedVideos[formattedDate]!;

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
                              SizedBox(width: 18.h),
                              Obx(
                                () => Tooltip(
                                  message: "Load More...",
                                  child: Align(
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
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Obx(
                            () {
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
                                    onTap: cloudRecordControllessr
                                            .isLoadingHuman
                                        ? null
                                        : () async {
                                            if (webrtcService.isConnecting) {
                                              await webrtcService.disconnect();
                                            }
                                            cloudRecordControllessr.setTsHuman =
                                                video.ts;

                                            int foundIndex =
                                                cloudRecordController
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
                                                const Duration(
                                                    milliseconds: 500), () {
                                              htmimgPlaybackPreviewFile(
                                                  video.value);
                                            });

                                            notifiControllerssss.setTextData =
                                                "getHmdImgFileUrl";
                                          },
                                    child: Obx(
                                      () => Card(
                                        color: Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                                  widget
                                                                      .idcamera);
                                                        },
                                                            "Are you sure you want to download ${_extractTime(formattedDate)} this? This action cannot be undone.",
                                                            const Icon(
                                                              Icons.download,
                                                              size: 50,
                                                              color:
                                                                  Colors.black,
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
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
            ),
          ],
        ),
      );
    });
  }
}


// ListView.builder(
//         shrinkWrap: true,
//         itemCount: webrtcServices.fileList.length,
//         itemBuilder: (context, index) {
//           final file = webrtcServices.fileList[index];
//           return GestureDetector(
//             onTap: () => webrtcServices.replaySdVideo(file['value'], 0),
//             child: ListTile(
//               title: Text(file['value']),
//               subtitle: Text(
//                   'Start: ${file['start_ts']} - End: ${file['end_ts'] ?? 'null'}'),
//               trailing: IconButton(
//                 icon: const Icon(Icons.stop),
//                 onPressed: () => webrtcServices.replaySdVideo(file['value'], 2),
//               ),
//             ),
//           );
//         },
//       );







// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:vivoo_camera_cty/common/flutter_toast.dart';
// import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
// import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';

// class PlayBackVideoSdcard extends StatefulWidget {
//   const PlayBackVideoSdcard({super.key, required this.idcamera});
//   final String idcamera;

//   @override
//   State<PlayBackVideoSdcard> createState() => _PlayBackVideoSdcardState();
// }

// class _PlayBackVideoSdcardState extends State<PlayBackVideoSdcard> {
//   final webrtcServicess = Get.put(WebRTCServiceController());

//   Timer? _debounce;
//   String convertTsToDatetime(int timestamp) {
//     DateTime dateTime =
//         DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
//     return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
//   }

//   Map<String, List<dynamic>> groupVideosByDate(List<dynamic> videos) {
//     Map<String, List<dynamic>> groupedVideos = {};

//     for (var video in videos) {
//       String formattedDate = convertTsToDatetime(video['start_ts']);
//       String dateKey = _extractTimeDay(formattedDate);

//       if (!groupedVideos.containsKey(dateKey)) {
//         groupedVideos[dateKey] = [];
//       }
//       groupedVideos[dateKey]?.add(video);
//     }

//     return groupedVideos;
//   }

//   String _extractTime(String formattedDate) {
//     List<String> dateParts = formattedDate.split(' ');
//     return dateParts.length > 1 ? dateParts[1] : '';
//   }

//   String _extractTimeDay(String formattedDate) {
//     List<String> dateParts = formattedDate.split(' ');
//     return dateParts.length > 0 ? dateParts[0] : '';
//   }

//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(Duration(milliseconds: 500), () {
//       webrtcServicess.getFileList();
//       webrtcServicess.setIsClickSdcard = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final webrtcServices = Get.put(WebRTCServiceController());
//     final cloudRecordController = Get.put(CloudRecordPathController());

//     return Obx(() {
//       if (webrtcServices.fileList.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(FontAwesomeIcons.person, size: 150),
//               const SizedBox(height: 16),
//               Text('Play back SDCard in here',
//                   style:
//                       TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         );
//       }

//       final groupedVideos = groupVideosByDate(webrtcServices.fileList);

//       return SizedBox(
//         height: MediaQuery.of(context).size.height * 0.8,
//         child: CustomScrollView(
//           slivers: [
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   String formattedDate = groupedVideos.keys.elementAt(index);
//                   List<dynamic> videos = groupedVideos[formattedDate]!;

//                   if (videos.isNotEmpty) {
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(formattedDate,
//                                   style: TextStyle(
//                                       fontSize: 18.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey)),
//                               SizedBox(width: 18.h),
//                               Tooltip(
//                                 message: "Load More...",
//                                 child: IconButton(
//                                   icon: Icon(
//                                     cloudRecordController
//                                             .isShowMore(formattedDate)
//                                         ? Icons.keyboard_arrow_up
//                                         : Icons.keyboard_arrow_down,
//                                     size: 30.sp,
//                                     color: Colors.black,
//                                   ),
//                                   onPressed: () {
//                                     ToastComponent.showToast(
//                                         message: "Load Success");
//                                     cloudRecordController
//                                         .toggleShowMoreAdd4List(
//                                             formattedDate, 4);
//                                     cloudRecordController
//                                         .toggleShowMore(formattedDate);
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16.h),
//                           Obx(
//                             () {
//                               final visibleCount =
//                                   cloudRecordController.getVisibleItemCount(
//                                       formattedDate, videos.length);

//                               return GridView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 gridDelegate:
//                                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   crossAxisSpacing: 10.0,
//                                   mainAxisSpacing: 10.0,
//                                   childAspectRatio: 2.5,
//                                 ),
//                                 itemCount: visibleCount,
//                                 itemBuilder: (context, videoIndex) {
//                                   var video = videos[videoIndex];
//                                   if (video == null ||
//                                       video['start_ts'] == null) {
//                                     return const SizedBox.shrink();
//                                   }

//                                   return GestureDetector(
//                                     onTap: () {
//                                       // if (_debounce?.isActive ?? false)
//                                       //   _debounce?.cancel();
//                                       // _debounce = Timer(
//                                       //     const Duration(
//                                       //         milliseconds: 500), () {
//                                       webrtcServices.replaySdVideo(
//                                           video['value'], 0);
//                                       // });
//                                       // Implement your video playback functionality here
//                                     },
//                                     child: Card(
//                                       color: Colors.grey.shade100,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(10.0),
//                                         side: const BorderSide(
//                                             color: Colors.white, width: 2.0),
//                                       ),
//                                       elevation: 2,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Expanded(
//                                             child: Center(
//                                               child: SizedBox(
//                                                 width: 70.w,
//                                                 child: Tooltip(
//                                                   message: _extractTime(
//                                                       convertTsToDatetime(
//                                                           video['start_ts'])),
//                                                   child: Text(
//                                                     _extractTime(
//                                                         convertTsToDatetime(
//                                                             video['start_ts'])),
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: TextStyle(
//                                                         fontSize: 12.sp,
//                                                         fontWeight:
//                                                             FontWeight.bold),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Obx(() {
//                                             return IconButton(
//                                               icon: const Icon(Icons.stop),
//                                               onPressed: () =>
//                                                   webrtcServices.replaySdVideo(
//                                                       video['value'], 2),
//                                             );
//                                           }),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                           if (videos.length > 4)
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 TextButton.icon(
//                                   icon: Icon(
//                                     cloudRecordController
//                                             .isShowMore(formattedDate)
//                                         ? Icons.keyboard_arrow_up
//                                         : Icons.keyboard_arrow_down,
//                                     size: 30.sp,
//                                     color: Colors.grey[500],
//                                   ),
//                                   label: Text(
//                                     cloudRecordController
//                                             .isShowMore(formattedDate)
//                                         ? 'Collapse'
//                                         : 'Show 4 items',
//                                     style: TextStyle(
//                                         fontSize: 14.sp,
//                                         color: Colors.grey[500]),
//                                   ),
//                                   onPressed: () {
//                                     cloudRecordController
//                                         .toggleShowMoreAdd4List(
//                                             formattedDate, videos.length);
//                                   },
//                                 ),
//                                 TextButton.icon(
//                                   icon: Icon(
//                                     cloudRecordController
//                                             .isShowMore(formattedDate)
//                                         ? Icons.keyboard_arrow_up
//                                         : Icons.keyboard_arrow_down,
//                                     size: 30.sp,
//                                     color: Colors.grey[500],
//                                   ),
//                                   label: Text(
//                                     cloudRecordController
//                                             .isShowMore(formattedDate)
//                                         ? 'Collapse'
//                                         : 'Show more',
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: Colors.grey[500],
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     ToastComponent.showToast(
//                                         message: "Load Success");

//                                     cloudRecordController
//                                         .toggleShowMoreAdd4List(
//                                             formattedDate, 4);
//                                     cloudRecordController
//                                         .toggleShowMore(formattedDate);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           SizedBox(height: 10.h),
//                           Divider(color: Colors.grey.shade300, height: 1.0),
//                           SizedBox(height: 20.h),
//                         ],
//                       ),
//                     );
//                   } else {
//                     return const Center(child: Text("No video found"));
//                   }
//                 },
//                 childCount: groupedVideos.keys.isNotEmpty
//                     ? groupedVideos.keys.length
//                     : 0,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }














// //  pc.onSignalingState = (RTCSignalingState state) {
//       print("Signaling state changed: ${state.toString()}");
//     };

//     pc.onDataChannel = (RTCDataChannel channel) {
//       // if (_dc != null) {
//       //   print("Closing existing DataChannel: ${_dc?.label}");
//       //   _dc?.close();
//       //   _dc = null;
//       // }
//       _dc = channel;
//       print("DataChannel opened: ${_dc?.label}");
//       _dc?.onMessage = (RTCDataChannelMessage message) {
//         if (message.isBinary) {
//           print("Can't handle binary messages");
//           return;
//         }
//         try {
//           final response = jsonDecode(message.text);
//           print("Parsed message: $response");
//           _handleDataChannelMessage(response);
//         } catch (e) {
//           print("Error parsing DataChannel message: $e");
//         }
//         setLoadingSDCard = false;
//       };
//     };

//     return pc;
//   }

//   void _handleDataChannelMessage(Map<String, dynamic> message) {
//     print("Handling data channel message: $message");

//     if (message['Type'] == 'Respond') {
//       switch (message['Command']) {
//         case 'GET_PLAYLIST':
//           final content = message['Content'];
//           print("Content received: $content");

//           if (content['Regular'] != null) {
//             final List<Map<String, dynamic>> files =
//                 List<Map<String, dynamic>>.from(content['Regular']);
//             print("Regular files: $files");

//             // Dữ liệu đang được mape thành fileData
//             fileList.value = files.map((file) {
//               final fileData = {
//                 'value': file['Name'],
//                 'start_ts': file['StartTS'],
//                 'end_ts': file['EndTS'],
//               };
//               print("Mapped file data: $fileData");
//               return fileData;
//             }).toList();
//             fileList.value
//                 .sort((a, b) => b['start_ts'].compareTo(a['start_ts']));
//             // Cập nhật danh sách file sau khi mape
//             print("Updated fileList: ${fileList.value}");

//             update(); // Nếu bạn đang sử dụng state management, gọi update để cập nhật UI
//           } else {
//             print("No regular files found.");
//           }
//           break;

//         // case 'REQ_PLAYBACK':
//         //   final content = message['Content'];
//         //   print("Content received: $content");

//         // if (content['Regular'] != null) {
//         //   final List<Map<String, dynamic>> files =
//         //       List<Map<String, dynamic>>.from(content['Regular']);
//         //   print("Regular files: $files");

//         //   // Dữ liệu đang được mape thành fileData
//         //   fileList.value = files.map((file) {
//         //     final fileData = {
//         //       'value': file['Name'],
//         //       'start_ts': file['StartTS'],
//         //       'end_ts': file['EndTS'],
//         //     };
//         //     print("Mapped file data: $fileData");
//         //     return fileData;
//         //   }).toList();
//         //   fileList.value
//         //       .sort((a, b) => b['start_ts'].compareTo(a['start_ts']));
//         //   // Cập nhật danh sách file sau khi mape
//         //   print("Updated fileList: ${fileList.value}");

//         //   update(); // Nếu bạn đang sử dụng state management, gọi update để cập nhật UI
//         // } else {
//         //   print("No regular files found.");
//         // }
//         // break;

//         default:
//           print("Unknown command: ${message['Command']}");
//       }
//     }
//   }

//   void getFileList() {
//     setLoadingSDCard = true;
//     fileList.clear();
//     // int startTs = cloundController.startTimeSdcardImage == 0
//     //     ? DateTime.now().toUtc().millisecondsSinceEpoch - 86400000
//     //     : cloundController.startTimeSdcardImage;
//     // int endTs = cloundController.endTimeSdcardImage == 0
//     //     ? DateTime.now().toUtc().millisecondsSinceEpoch
//     //     : cloundController.endTimeSdcardImage;

//     // int startTsInSeconds = startTs ~/ 1000;
//     // int endTsInSeconds = endTs ~/ 1000;
//     // Giả sử selectedDate, startTime và endTime đã được lấy từ giao diện người dùng (giống JavaScript)

//     DateTime now = DateTime.now();
//     String selectedDate = DateFormat('MM/dd/yyyy').format(now); // Ví dụ
//     String startTime = "00:00"; // Ví dụ
//     String endTime = "23:59"; // Ví dụ

//     // Tách ngày, tháng, năm từ selectedDate
//     final parts = selectedDate.split('/');
//     int month = int.parse(parts[0]);
//     int day = int.parse(parts[1]);
//     int year = int.parse(parts[2]);

//     // Chuyển đổi giờ từ startTime và endTime
//     final startParts = startTime.split(':');
//     final endParts = endTime.split(':');

//     // Tạo đối tượng DateTime với múi giờ UTC
//     final startDate = DateTime.utc(
//         year, month, day, int.parse(startParts[0]), int.parse(startParts[1]));
//     final endDate = DateTime.utc(
//         year, month, day, int.parse(endParts[0]), int.parse(endParts[1]));

//     // Chuyển đổi DateTime thành timestamp (giây)
//     int startTsInSeconds = startDate.millisecondsSinceEpoch ~/ 1000;
//     int endTsInSeconds = endDate.millisecondsSinceEpoch ~/ 1000;

// // cloud================================================
//     int endTimeInMilliseconds = cloundController.endTimeSdcardImage;
//     DateTime endTimeUtc =
//         DateTime.fromMillisecondsSinceEpoch(endTimeInMilliseconds, isUtc: true);
//     int endTimeInSeconds = endTimeUtc.millisecondsSinceEpoch ~/ 1000;
// // cloud================================================
//     int startTimeInMilliseconds = cloundController.startTimeSdcardImage;
//     DateTime startTimeUtc = DateTime.fromMillisecondsSinceEpoch(
//         startTimeInMilliseconds,
//         isUtc: true);
//     int startTimeInSeconds = startTimeUtc.millisecondsSinceEpoch ~/ 1000;

//     print("Start time in UTC (seconds): $startTimeInSeconds");

//     int startTs = cloundController.startTimeSdcardImage == 0
//         ? startTsInSeconds
//         : startTimeInSeconds;
//     int endTs = cloundController.endTimeSdcardImage == 0
//         ? endTsInSeconds
//         : endTimeInSeconds;

//     print(
//         "Start timestamp in seconds: $startTsInSeconds, End timestamp in seconds: $endTsInSeconds");
//     print(
//         "Start timestamp in seconds: $startTsInSeconds, End timestamp in seconds: $endTsInSeconds");
//     // print("Start timestamp: $startTs, End timestamp: $endTs");

//     final msg = jsonEncode({
//       'Id': idCamera,
//       'Command': 'GET_PLAYLIST',
//       'Type': 'Request',
//       'Content': {
//         'Type': 0,
//         'BeginTime': startTs,
//         'EndTime': endTs,
//       },
//     });

//     print("Sending message: $msg");

//     _dc?.send(RTCDataChannelMessage(msg));
//     // setLoadingSDCard = false;
//   }

//   void replaySdVideo(String alias, int state) {
//     print("Replaying video: $alias, state: $state");
//     setLoadingSDCard = true;
//     final msg = jsonEncode({
//       'Id': idCamera,
//       'Command': 'REQ_PLAYBACK',
//       'Type': 'Request',
//       'Content': {
//         'Assign': alias,
//         'Status': state,
//       },
//     });

//     _dc?.send(RTCDataChannelMessage(msg));
//   }