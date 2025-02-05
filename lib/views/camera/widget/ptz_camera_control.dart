import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/custom_btn.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';

class PtzCameraControl extends StatefulWidget {
  const PtzCameraControl({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<PtzCameraControl> createState() => _PtzCameraControlState();
}

class _PtzCameraControlState extends State<PtzCameraControl> {
  @override
  Widget build(BuildContext context) {
    final webrtcService = Get.put(WebRTCServiceController());

    return SizedBox(
      height: 500.h,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa các nút
                  children: [
                    CustomButton(
                        btnWidth: 60.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "Left",
                        icon: Icons.keyboard_arrow_left_rounded,
                        onTap: () {
                          webrtcService.leftCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 80.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "Right",
                        icon: Icons.chevron_right_outlined,
                        onTap: () {
                          webrtcService.rightCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 60.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "Up",
                        icon: Icons.arrow_upward,
                        onTap: () {
                          webrtcService.upCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 80.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "Down",
                        icon: Icons.arrow_downward,
                        onTap: () {
                          webrtcService.downCamera(widget.idcamera);
                        }),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa các nút
                  children: [
                    CustomButton(
                        btnWidth: 90.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "Reset",
                        icon: Icons.refresh,
                        onTap: () {
                          webrtcService.resetCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 80.w,
                        btnHieght: 40.h,
                        color: kDark,
                        icon: Icons.stop,
                        text: "Stop",
                        onTap: () {
                          webrtcService.stopCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 100.w,
                        btnHieght: 40.h,
                        color: kDark,
                        icon: Icons.home,
                        text: "Goback",
                        onTap: () {
                          webrtcService.goBackCamera(widget.idcamera);
                        }),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa các nút
                  children: [
                    CustomButton(
                        btnWidth: 90.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "IR On",
                        icon: Icons.wb_iridescent_outlined,
                        onTap: () {
                          webrtcService.IROnCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 80.w,
                        btnHieght: 40.h,
                        color: kDark,
                        icon: Icons.wb_iridescent,
                        text: "IR Off",
                        onTap: () {
                          webrtcService.IROffCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 100.w,
                        btnHieght: 40.h,
                        color: kDark,
                        icon: Icons.lens_outlined,
                        text: "IRCUT On",
                        onTap: () {
                          webrtcService.IRCUTOnCamera(widget.idcamera);
                        }),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa các nút
                  children: [
                    CustomButton(
                        btnWidth: 99.w,
                        btnHieght: 40.h,
                        color: kDark,
                        text: "IRCUT Off",
                        icon: Icons.lens,
                        onTap: () {
                          webrtcService.IRCUTOffCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 80.w,
                        btnHieght: 40.h,
                        color: kDark,
                        icon: Icons.light_mode_rounded,
                        text: "LED On",
                        onTap: () {
                          webrtcService.LEDONCamera(widget.idcamera);
                        }),
                    SizedBox(width: 5.w),
                    CustomButton(
                        btnWidth: 100.w,
                        btnHieght: 40.h,
                        color: kDark,
                        icon: Icons.light_mode_outlined,
                        text: "LED Off",
                        onTap: () {
                          webrtcService.LEDOFFCamera(widget.idcamera);
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
