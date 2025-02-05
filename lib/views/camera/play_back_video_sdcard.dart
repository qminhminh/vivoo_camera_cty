// ignore_for_file: prefer_is_empty, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';

class PlayBackVideoSdcard extends StatefulWidget {
  const PlayBackVideoSdcard({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<PlayBackVideoSdcard> createState() => _PlayBackVideoSdcardState();
}

class _PlayBackVideoSdcardState extends State<PlayBackVideoSdcard> {
  final webrtcServicess = Get.put(WebRTCServiceController());
  final cloudRecordController = Get.put(CloudRecordPathController());
  String convertTsToDatetime(int timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Map<String, List<dynamic>> groupVideosByDate(List<dynamic> videos) {
    Map<String, List<dynamic>> groupedVideos = {};

    for (var video in videos) {
      String formattedDate = convertTsToDatetime(video['start_ts']);
      String dateKey = _extractTimeDay(formattedDate);

      if (!groupedVideos.containsKey(dateKey)) {
        groupedVideos[dateKey] = [];
      }
      groupedVideos[dateKey]?.add(video);
    }

    return groupedVideos;
  }

  String _extractTime(String formattedDate) {
    List<String> dateParts = formattedDate.split(' ');
    return dateParts.length > 1 ? dateParts[1] : '';
  }

  String _extractTimeDay(String formattedDate) {
    List<String> dateParts = formattedDate.split(' ');
    return dateParts.length > 0 ? dateParts[0] : '';
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      webrtcServicess.setIsClickSdcard = true;
      cloudRecordController.setTsSDcard = 0;
      cloudRecordController.currentItemIndexSDcard.value = 0;
      webrtcServicess.setSelectedTime = "Choose Date:";
      webrtcServicess.getFileList();
    });
  }

  @override
  void dispose() {
    webrtcServicess.setIsClickSdcard = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webrtcServices = Get.put(WebRTCServiceController());
    final cloudRecordController = Get.put(CloudRecordPathController());

    return Obx(() {
      if (webrtcServices.fileList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.sdCard, size: 150),
              const SizedBox(height: 16),
              Text('Play back SDCard in here',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }

      final groupedVideos = groupVideosByDate(webrtcServices.fileList);

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
                              Text(formattedDate,
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                              SizedBox(width: 18.h),
                              Tooltip(
                                message: "Load More...",
                                child: Obx(
                                  () => IconButton(
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
                                  childAspectRatio: 2.5,
                                ),
                                itemCount: visibleCount,
                                itemBuilder: (context, videoIndex) {
                                  var video = videos[videoIndex];
                                  if (video == null ||
                                      video['start_ts'] == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return GestureDetector(
                                    onTap: webrtcServices.isLoadingSDCard
                                        ? null
                                        : () {
                                            // cloudRecordController.setstopSdcard =
                                            //     cloudRecordController.stopSdcard + 1;

                                            cloudRecordController
                                                .setbuttonListSDCard = 1;
                                            cloudRecordController.setTsSDcard =
                                                video['start_ts'];

                                            cloudRecordController
                                                    .settsValueSdcard =
                                                video['value'];

                                            int foundIndex = webrtcServices
                                                .fileList
                                                .indexWhere((record) =>
                                                    record['start_ts'] ==
                                                    cloudRecordController
                                                        .currentTsSDcard);
                                            cloudRecordController
                                                    .currentItemIndexSDcard
                                                    .value =
                                                (foundIndex != -1)
                                                    ? foundIndex
                                                    : 0;

                                            // if (cloudRecordController.stopSdcard ==
                                            //     2) {
                                            //   webrtcServices.replaySdVideo(
                                            //       cloudRecordController.tsValueSdcard,
                                            //       2);
                                            //   cloudRecordController.setstopSdcard = 0;
                                            // }

                                            // Future.delayed(Duration(
                                            //     milliseconds: 500)); // Đợi 500ms
                                            webrtcServices.replaySdVideo(
                                                video['value'],
                                                0); // Phát video mới

                                            // Implement your video playback functionality here
                                          },
                                    child: Card(
                                      color: Colors.grey.shade100,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: webrtcServices.fileList[
                                                        cloudRecordController
                                                            .currentItemIndexSDcard
                                                            .value]['start_ts'] ==
                                                    video['start_ts']
                                                ? Colors.black
                                                : Colors.white,
                                            width: 2.0),
                                      ),
                                      elevation: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: SizedBox(
                                                width: 70.w,
                                                child: Tooltip(
                                                  message: _extractTime(
                                                      convertTsToDatetime(
                                                          video['start_ts'])),
                                                  child: Text(
                                                    _extractTime(
                                                        convertTsToDatetime(
                                                            video['start_ts'])),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // IconButton(
                                          //   icon: const Icon(Icons.stop),
                                          //   onPressed: () =>
                                          //       webrtcServices.replaySdVideo(
                                          //           video['value'], 2),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          if (videos.length > 4)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
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
                                        color: Colors.grey[500]),
                                  ),
                                  onPressed: () {
                                    cloudRecordController
                                        .toggleShowMoreAdd4List(
                                            formattedDate, videos.length);
                                  },
                                ),
                                Obx(
                                  () => TextButton.icon(
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
                          SizedBox(height: 10.h),
                          Divider(color: Colors.grey.shade300, height: 1.0),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: Text("No video found"));
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
