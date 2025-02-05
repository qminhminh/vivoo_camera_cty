// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';

class TimerCamera extends StatefulWidget {
  const TimerCamera({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<TimerCamera> createState() => _TimerCameraState();
}

class _TimerCameraState extends State<TimerCamera> {
  final webrtcServices = Get.put(WebRTCServiceController());
  final Map<String, String> friendlyNames = {
    "1": "Monday",
    "2": "Tuesday",
    "3": "Wednesday",
    "4": "Thursday",
    "5": "Friday",
    "6": "Saturday",
    "7": "Sunday",
  };
  Future<void> _pickTime(Map<String, dynamic> schedule, String key) async {
    final context = Get.context!;
    final initialTime = webrtcServices.millisecondsToTime(schedule[key]);
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      schedule[key] = webrtcServices.timeToMilliseconds(pickedTime);
      webrtcServices.scheduleData.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final webrtcService = Get.put(WebRTCServiceController());

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: webrtcService.scheduleData.length,
          itemBuilder: (context, index) {
            final schedule = webrtcService.scheduleData[index];
            final dayOfWeek = schedule["dayOfWeek"];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3), // Shadow direction
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.scale(
                          scale: 1.2, // Increase checkbox size
                          child: Checkbox(
                            value: schedule["enabled"],
                            onChanged: (value) {
                              schedule["enabled"] = value;
                              webrtcService.scheduleData.refresh();
                              // webrtcService.saveScheduleData(
                              //     widget.idcamera);
                            },
                            activeColor: Colors.black, // Custom checkbox color
                          ),
                        ),
                        // Increased space
                        Text(
                          friendlyNames[schedule["dayOfWeek"].toString()] ??
                              'Day $dayOfWeek',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                _pickTime(schedule, "startsOn");
                                // webrtcService.saveScheduleData(
                                //     widget.idcamera);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.black, width: 1.2),
                                ),
                                child: Text(
                                  "${webrtcService.millisecondsToTime(schedule["startsOn"]).format(context)}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              ' to ',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _pickTime(schedule, "endsOn");
                                // webrtcService.saveScheduleData(
                                //     widget.idcamera);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.black, width: 1.2),
                                ),
                                child: Text(
                                  "${webrtcService.millisecondsToTime(schedule["endsOn"]).format(context)}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h), // Increased space
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ElevatedButton(
            onPressed: webrtcService.isLoadingTimer
                ? null
                : () {
                    webrtcService.saveScheduleData(widget
                        .idcamera); // Gọi hàm lưu dữ liệu khi người dùng nhấn nút
                  },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black, // Màu chữ nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Bo góc nút
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 40, vertical: 12), // Căng rộng nút
              elevation: 5, // Đổ bóng dưới nút
            ),
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 14.sp, // Kích thước chữ
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
