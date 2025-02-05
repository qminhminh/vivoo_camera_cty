// ignore_for_file: unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';

void showDeleteConfirmationDialogSettings(BuildContext context,
    List<Map<String, dynamic>> settings, String cameraId) async {
  final cameraController = Get.put(WebRTCServiceController());
  final Map<String, String> friendlyNames = {
    "cloud_hmd_enable": "Human",
    "cloud_mtd_enable": "Motion",
    "cloud_stream_enable": "Cloud Storage",
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (settings == [])
                    Text(
                      "No foud setting",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (settings != [])
                    ...settings.map((setting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                friendlyNames[setting["key"]] ?? setting["key"],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Obx(
                              () => Switch(
                                value: setting["value"] == true,
                                onChanged: cameraController.isLoadingCamera
                                    ? null
                                    : (bool newValue) {
                                        setState(() {
                                          setting["value"] = newValue;
                                        });
                                        // Gửi trạng thái mới lên server nếu cần
                                        cameraController.updatesettingsCamera(
                                            cameraId, setting["key"], newValue);
                                      },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog
                        },
                        child: const Text(
                          "Cancle",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
