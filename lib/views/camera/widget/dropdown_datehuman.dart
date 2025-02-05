// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';

class DropdownDatehuman extends StatefulWidget {
  const DropdownDatehuman({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<DropdownDatehuman> createState() => _DropdownDatehumanState();
}

class _DropdownDatehumanState extends State<DropdownDatehuman> {
  final ScrollController _scrollController =
      ScrollController(); // Thêm ScrollController

  final Map<String, Duration> friendlyDurations = {
    // "Last 1 hour": const Duration(hours: 1),
    // "Last 2 hours": const Duration(hours: 2),
    // "Last 3 hours": const Duration(hours: 3),
    // "Last 4 hours": const Duration(hours: 4),
    // "Last 5 hours": const Duration(hours: 5),
    // "Last 6 hours": const Duration(hours: 6),
    // "Last 7 hours": const Duration(hours: 7),
    // "Last 8 hours": const Duration(hours: 8),
    // "Last 9 hours": const Duration(hours: 9),
    // "Last 10 hours": const Duration(hours: 10),
    // "Last 11 hours": const Duration(hours: 11),
    // "Last 12 hours": const Duration(hours: 12),
    "Last day": const Duration(days: 1),
    // "Last 2 days": const Duration(days: 2),
    "Last 3 days": const Duration(days: 3),
    // "Last 4 days": const Duration(days: 4),
    // "Last 5 days": const Duration(days: 5),
    // "Last 6 days": const Duration(days: 6),
    // "Last 1 week": const Duration(days: 7),
    // "Last 2 weeks": const Duration(days: 14),
  };

  @override
  void dispose() {
    _scrollController.dispose(); // Hủy ScrollController khi không cần thiết
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cloudRecordController = Get.put(CloudRecordPathController());
    final webrtcServices = Get.put(WebRTCServiceController());
    return Obx(
      () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                webrtcServices.setIsDropdownOpen =
                    !webrtcServices.isDropdownOpen;
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    webrtcServices.selectedTime,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  Icon(
                    webrtcServices.isDropdownOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (webrtcServices.isDropdownOpen)
              Container(
                width: 180.w,
                constraints: BoxConstraints(maxHeight: 150.h),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController, // Gắn ScrollController vào đây
                  child: ListView(
                    controller:
                        _scrollController, // Gắn ScrollController vào đây
                    shrinkWrap: true,
                    children: friendlyDurations.keys.map((key) {
                      return ListTile(
                        title: Text(
                          key,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        onTap: () {
                          setState(() {
                            webrtcServices.setSelectedTime = key;
                            webrtcServices.setIsDropdownOpen = false;

                            final currentTime = DateTime.now();
                            final duration = friendlyDurations[key]!;
                            final calculatedTime =
                                currentTime.subtract(duration);
                            cloudRecordController.setSelectedDateStartHtmImage =
                                '';
                            cloudRecordController.setSelectedDateEndHtmImage =
                                '';
                            cloudRecordController.setStartTimeHtmImage =
                                calculatedTime.millisecondsSinceEpoch;
                            cloudRecordController.setStartTimeMtdImage = 0;
                            cloudRecordController.setStartTimeAllImage = 0;
                            cloudRecordController.setStartTimeSdcardImage = 0;
                            print(
                                "cloudRecordController.setStartTimeHtmImage: ${cloudRecordController.startTimeHtmImage}");
                            print(
                                "cloudRecordController.setStartTimeMtdImage: ${cloudRecordController.startTimeMtdImage}");
                            print(
                                "cloudRecordController.setStartTimeAllImage: ${cloudRecordController.startTimeAllImage}");
                            print(
                                "human date duration: +$duration  : + calculated time: +$calculatedTime");

                            cloudRecordController
                                .fetchListImagePlayback(widget.idcamera);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
