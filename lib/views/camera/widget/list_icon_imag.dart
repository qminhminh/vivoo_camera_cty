// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';

class ListIconImag extends StatefulWidget {
  const ListIconImag({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<ListIconImag> createState() => _ListIconImagState();
}

class _ListIconImagState extends State<ListIconImag> {
  @override
  Widget build(BuildContext context) {
    final webrtcService = Get.put(WebRTCServiceController());
    final cloudRecordController = Get.put(CloudRecordPathController());
    final notifiControllerssss = Get.put(NotificationController());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 16.w,
            ),
            Obx(() {
              return !webrtcService.isConnecting ||
                      cloudRecordController.pathHtmImageUrl != ''
                  ? Align(
                      alignment: Alignment.centerLeft, // Căn lề trái
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 0, right: 16), // Cách viền phải nếu muốn
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300], // Màu nền thay đổi khi click
                        ),
                        child: IconButton(
                          onPressed: cloudRecordController.isLoading
                              ? null
                              : () {
                                  ToastComponent.showToast(
                                      message:
                                          "Please play video or back Live ");
                                },
                          icon: Icon(
                            Icons.sd_card,
                            color: Colors.black, // Thay đổi màu icon khi click
                            size: 20.sp, // Kích thước của icon
                          ),
                        ),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft, // Căn lề trái
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 0, right: 16), // Cách viền phải nếu muốn
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: webrtcService.isClickSdcard
                              ? Colors.black
                              : Colors.grey[300], // Màu nền thay đổi khi click
                        ),
                        child: IconButton(
                          onPressed: cloudRecordController.isLoading
                              ? null
                              : () {
                                  webrtcService.setIsClickSdcard = !webrtcService
                                      .isClickSdcard; // Thay đổi trạng thái khi nhấn

                                  webrtcService.setIsClickHuman = false;

                                  webrtcService.setIsClickMotion = false;

                                  webrtcService.setIsClickAll = false;

                                  webrtcService.setSelectedTime =
                                      "Choose Date:";
                                  cloudRecordController.setStartTimeMtdImage =
                                      0;
                                  cloudRecordController.setStartTimeHtmImage =
                                      0;
                                  cloudRecordController.setStartTimeAllImage =
                                      0;

                                  cloudRecordController
                                      .setStartTimeSdcardImage = 0;
                                  cloudRecordController.setEndTimeSdcardImage =
                                      0;

                                  cloudRecordController
                                      .setSelectedDateStartSdcardImage = '';
                                  cloudRecordController
                                      .setSelectedDateEndSdcardImage = '';

                                  // cloudRecordController.currentItemIndex.value =
                                  //     0;
                                  // cloudRecordController
                                  //     .currentItemIndexMotion.value = 0;

                                  webrtcService.getFileList();
                                },
                          icon: Icon(
                            Icons.sd_card,
                            color: webrtcService.isClickSdcard
                                ? Colors.white
                                : Colors.black, // Thay đổi màu icon khi click
                            size: 20.sp, // Kích thước của icon
                          ),
                        ),
                      ),
                    );
            }),
            SizedBox(
              width: 6.w,
            ),
            Obx(
              () => Align(
                alignment: Alignment.centerLeft, // Căn lề trái
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 0, right: 16), // Cách viền phải nếu muốn
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: webrtcService.isClickAll
                        ? Colors.black
                        : Colors.grey[300], // Màu nền thay đổi khi click
                  ),
                  child: IconButton(
                    onPressed: cloudRecordController.isLoading
                        ? null
                        : () {
                            webrtcService.setIsClickAll = !webrtcService
                                .isClickAll; // Thay đổi trạng thái khi nhấn

                            webrtcService.setIsClickHuman = false;

                            webrtcService.setIsClickMotion = false;

                            webrtcService.setIsClickSdcard = false;

                            webrtcService.setSelectedTime = "Choose Date:";
                            cloudRecordController.setStartTimeMtdImage = 0;
                            cloudRecordController.setStartTimeHtmImage = 0;
                            cloudRecordController.setStartTimeAllImage = 0;
                            cloudRecordController.setStartTimeSdcardImage = 0;
                            cloudRecordController.setEndTimeAllImage = 0;

                            cloudRecordController.setSelectedDateStartAllImage =
                                '';
                            cloudRecordController.setSelectedDateEndAllImage =
                                '';

                            // cloudRecordController.currentItemIndex.value =
                            //     0;
                            // cloudRecordController
                            //     .currentItemIndexMotion.value = 0;

                            cloudRecordController
                                .fetchListImageAllPlayback(widget.idcamera);
                          },
                    icon: Icon(
                      Icons.all_inbox,
                      color: webrtcService.isClickAll
                          ? Colors.white
                          : Colors.black, // Thay đổi màu icon khi click
                      size: 20.sp, // Kích thước của icon
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 6.w,
            ),
            Obx(
              () => Align(
                alignment: Alignment.centerLeft, // Căn lề trái
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 0, right: 16), // Cách viền phải nếu muốn
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: webrtcService.isClickMotion
                        ? Colors.black
                        : Colors.grey[300], // Màu nền thay đổi khi click
                  ),
                  child: IconButton(
                    onPressed: cloudRecordController.isLoading
                        ? null
                        : () {
                            webrtcService.setIsClickHuman = false;
                            webrtcService.setIsClickAll = false;
                            webrtcService.setIsClickSdcard = false;
                            webrtcService.setSelectedTime = "Choose Date:";
                            webrtcService.setIsClickMotion =
                                !webrtcService.isClickMotion;
                            cloudRecordController.setStartTimeMtdImage = 0;
                            cloudRecordController.setStartTimeHtmImage = 0;
                            cloudRecordController.setStartTimeAllImage = 0;
                            cloudRecordController.setStartTimeSdcardImage = 0;
                            cloudRecordController.currentItemIndex.value = 0;
                            cloudRecordController.setEndTimeMtdImage = 0;

                            cloudRecordController.currentItemIndexMotion.value =
                                0;
                            notifiControllerssss.setTextData =
                                "getMtdImgFileUrl";
                            cloudRecordController.setSelectedDateStartMtdImage =
                                '';
                            cloudRecordController.setSelectedDateEndMtdImage =
                                '';
                            cloudRecordController
                                .fetchListImageMtdPlayback(widget.idcamera);

                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              cloudRecordController.mtdimgPlaybackPreviewFile(
                                  cloudRecordController
                                      .cloudrecordMtdimg[cloudRecordController
                                          .currentItemIndex.value]
                                      .value,
                                  widget.idcamera);
                            });
                          },
                    icon: Icon(
                      FontAwesomeIcons.exchangeAlt,
                      color: webrtcService.isClickMotion
                          ? Colors.white
                          : Colors.black, // Thay đổi màu icon khi click
                      size: 20.sp, // Kích thước của icon
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 6.w,
            ),
            Obx(
              () => Align(
                alignment: Alignment.centerLeft, // Căn lề trái
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 0, right: 16), // Cách viền phải nếu muốn
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: webrtcService.isClickHuman
                        ? Colors.black
                        : Colors.grey[300], // Màu nền thay đổi khi click
                  ),
                  child: IconButton(
                    onPressed: cloudRecordController.isLoading
                        ? null
                        : () {
                            webrtcService.setIsClickHuman =
                                !webrtcService.isClickHuman;
                            webrtcService.setIsClickAll = false;
                            webrtcService.setIsClickMotion = false;
                            webrtcService.setIsClickSdcard = false;
                            webrtcService.setSelectedTime = "Choose Date:";
                            cloudRecordController.setStartTimeMtdImage = 0;
                            cloudRecordController.setStartTimeHtmImage = 0;
                            cloudRecordController.setStartTimeAllImage = 0;
                            cloudRecordController.setStartTimeSdcardImage = 0;
                            cloudRecordController.currentItemIndex.value = 0;
                            cloudRecordController.currentItemIndexMotion.value =
                                0;
                            cloudRecordController.setEndTimeHtmImage = 0;

                            notifiControllerssss.setTextData =
                                "getHmdImgFileUrl";
                            cloudRecordController.setSelectedDateStartHtmImage =
                                '';
                            cloudRecordController.setSelectedDateEndHtmImage =
                                '';

                            cloudRecordController
                                .fetchListImagePlayback(widget.idcamera);
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              cloudRecordController.mtdimgPlaybackPreviewFile(
                                  cloudRecordController
                                      .cloudrecordshmdimg[cloudRecordController
                                          .currentItemIndex.value]
                                      .value,
                                  widget.idcamera);
                            });
                          },
                    icon: Icon(
                      FontAwesomeIcons.person,
                      color: webrtcService.isClickHuman
                          ? Colors.white
                          : Colors.black, // Thay đổi màu icon khi click
                      size: 20.sp, // Kích thước của icon
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
