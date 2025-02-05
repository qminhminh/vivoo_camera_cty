// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/views/camera/fullscreen_video.dart';
import 'package:vivoo_camera_cty/views/camera/play_back_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class PtzCamera extends StatefulWidget {
  const PtzCamera({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<PtzCamera> createState() => _PtzCameraState();
}

class _PtzCameraState extends State<PtzCamera> {
  ScreenshotController screenshotController = ScreenshotController();
  Future<void> requestPermissions() async {
    if (await Permission.camera.isDenied ||
        await Permission.camera.isPermanentlyDenied) {
      await Permission.camera.request();
    }

    if (await Permission.microphone.isDenied ||
        await Permission.microphone.isPermanentlyDenied) {
      await Permission.microphone.request();
    }

    if (await Permission.storage.isDenied ||
        await Permission.storage.isPermanentlyDenied) {
      await Permission.storage.request();
    }
  }

  void _captureScreenshot() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + '/screenshot.png';

    screenshotController
        .captureAndSave(directory.path, fileName: "screenshot.png")
        .then((value) async {
      // Lưu ảnh vào bộ sưu tập sử dụng image_gallery_saver
      final result = await ImageGallerySaverPlus.saveFile(path);
      if (result != null && result != '') {
        print('Screenshot saved to gallery at $result');
        ToastComponent.showToast(message: "Screenshot saved to gallery");
      } else {
        ToastComponent.showToast(message: "Failed to save screenshot");
        print('Failed to save screenshot');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final webrtcService = Get.put(WebRTCServiceController());
    final cloudRecordController = Get.put(CloudRecordPathController());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ptz
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => IconButton(
                    onPressed: () {
                      webrtcService.setIsPTZConnect =
                          !webrtcService.isPTZConnect;
                      webrtcService.setIsTimer = true;
                    },
                    icon: Icon(
                      webrtcService.isPTZConnect
                          ? Icons.close
                          : Icons.api_rounded,
                      color: Colors.black,
                      size: 20.sp,
                    ),
                  ),
                ),
                Text(
                  "PTZ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 16.w,
            ),
            // stop video
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !webrtcService.isConnecting
                      ? IconButton(
                          onPressed: () {
                            ToastComponent.showToast(
                                message:
                                    "You need to connect the camera before Stop Video");
                          },
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            color: Colors.grey,
                            size: 20.sp,
                          ))
                      : IconButton(
                          onPressed: () async {
                            await requestPermissions();
                            if (webrtcService.isConnecting) {
                              webrtcService.disconnect();
                              webrtcService.setIsSounding = false;
                              ToastComponent.showToast(message: "Stop play");
                            } else {
                              webrtcService.connect(ipcUuid: widget.idcamera);
                            }
                          },
                          icon: Icon(
                            Icons.stop_circle_outlined,
                            size: 20.sp,
                          )),
                  Text(
                    "Stop",
                    style: TextStyle(
                      color: !webrtcService.isConnecting
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.w,
            ),

            Obx(
              () => cloudRecordController.buttonListSDCard == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !webrtcService.isConnecting
                            ? IconButton(
                                onPressed: () {
                                  ToastComponent.showToast(
                                      message:
                                          "You need to connect the camera before Stop Video");
                                },
                                icon: Icon(
                                  Icons.stop_circle_outlined,
                                  color: Colors.grey,
                                  size: 20.sp,
                                ))
                            : IconButton(
                                onPressed: () async {
                                  cloudRecordController.setbuttonListSDCard = 0;
                                  webrtcService.replaySdVideo(
                                      cloudRecordController.tsValueSdcard, 2);
                                },
                                icon: Icon(
                                  Icons.stop_circle_outlined,
                                  size: 20.sp,
                                )),
                        Text(
                          "Stop SDCard",
                          style: TextStyle(
                            color: !webrtcService.isConnecting
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            Obx(() {
              return cloudRecordController.buttonListSDCard == 1
                  ? SizedBox(
                      width: 16.w,
                    )
                  : const SizedBox();
            }),

            Obx(
              () => cloudRecordController.buttonListSDCard == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !webrtcService.isConnecting
                            ? IconButton(
                                onPressed: () {
                                  ToastComponent.showToast(
                                      message:
                                          "You need to connect the camera before Stop Video");
                                },
                                icon: Icon(
                                  Icons.pause,
                                  color: Colors.grey,
                                  size: 20.sp,
                                ))
                            : IconButton(
                                onPressed: () async {
                                  webrtcService.loadPreviousImage();
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  size: 20.sp,
                                )),
                        Text(
                          "Previous SDCard",
                          style: TextStyle(
                            color: !webrtcService.isConnecting
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),

            Obx(() {
              return cloudRecordController.buttonListSDCard == 1
                  ? SizedBox(
                      width: 16.w,
                    )
                  : const SizedBox();
            }),

            Obx(
              () => cloudRecordController.buttonListSDCard == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !webrtcService.isConnecting
                            ? IconButton(
                                onPressed: () {
                                  ToastComponent.showToast(
                                      message:
                                          "You need to connect the camera before Stop Video");
                                },
                                icon: Icon(
                                  Icons.pause,
                                  color: Colors.grey,
                                  size: 20.sp,
                                ))
                            : IconButton(
                                onPressed: () async {
                                  webrtcService.loadNextImage();
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 20.sp,
                                )),
                        Text(
                          "Next SDCard",
                          style: TextStyle(
                            color: !webrtcService.isConnecting
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),

            Obx(() {
              return cloudRecordController.buttonListSDCard == 1
                  ? SizedBox(
                      width: 16.w,
                    )
                  : const SizedBox();
            }),

            Obx(
              () => cloudRecordController.buttonListSDCard == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !webrtcService.isConnecting
                            ? IconButton(
                                onPressed: () {
                                  ToastComponent.showToast(
                                      message:
                                          "You need to connect the camera before Stop Video");
                                },
                                icon: Icon(
                                  Icons.pause,
                                  color: Colors.grey,
                                  size: 20.sp,
                                ))
                            : IconButton(
                                onPressed: () async {
                                  cloudRecordController.setbuttonListSDCard = 0;
                                  webrtcService.replaySdVideo(
                                      cloudRecordController.tsValueSdcard, 1);
                                },
                                icon: Icon(
                                  Icons.pause,
                                  size: 20.sp,
                                )),
                        Text(
                          "Pause SDCard",
                          style: TextStyle(
                            color: !webrtcService.isConnecting
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),

            Obx(() {
              return cloudRecordController.buttonListSDCard == 1
                  ? SizedBox(
                      width: 16.w,
                    )
                  : const SizedBox();
            }),

            Obx(
              () => cloudRecordController.buttonListSDCard == 1
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        !webrtcService.isConnecting
                            ? IconButton(
                                onPressed: () {
                                  ToastComponent.showToast(
                                      message:
                                          "You need to connect the camera before Stop Video");
                                },
                                icon: Icon(
                                  Icons.replay_outlined,
                                  color: Colors.grey,
                                  size: 20.sp,
                                ))
                            : IconButton(
                                onPressed: () async {
                                  cloudRecordController.setbuttonListSDCard = 0;
                                  webrtcService.replaySdVideo(
                                      cloudRecordController.tsValueSdcard, 3);
                                },
                                icon: Icon(
                                  Icons.replay_outlined,
                                  size: 20.sp,
                                )),
                        Text(
                          "Resume SDCard",
                          style: TextStyle(
                            color: !webrtcService.isConnecting
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
            Obx(() {
              return cloudRecordController.buttonListSDCard == 1
                  ? SizedBox(
                      width: 16.w,
                    )
                  : const SizedBox();
            }),
            // Quay lại video
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Get.to(
                        () => PLayBackVideo(
                              idcamera: widget.idcamera,
                            ),
                        transition: Transition.native,
                        duration: const Duration(seconds: 1));
                  },
                  icon: Icon(
                    Icons.play_lesson_rounded,
                    color: Colors.black,
                    size: 20.sp,
                  ),
                ),
                Text(
                  "PlayBack",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 16.w,
            ),
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !webrtcService.isConnecting
                      ? IconButton(
                          onPressed: () async {
                            ToastComponent.showToast(
                                message:
                                    "You need to connect the camera before calling");
                          },
                          icon: Icon(
                            Icons.phone,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            await webrtcService.initializeStream();
                            if (webrtcService.isAudioEnabledMic) {
                              webrtcService.startAudioTransmission();
                            } else {
                              webrtcService.stopAudioTransmission();
                            }

                            webrtcService.setEnableAudioMic =
                                !webrtcService.isAudioEnabledMic;
                          },
                          icon: Icon(
                            webrtcService.isAudioEnabledMic
                                ? Icons.phone
                                : Icons.phone_disabled,
                            color: Colors.black,
                            size: 20.sp,
                          ),
                        ),
                  Text(
                    "Call",
                    style: TextStyle(
                      color: !webrtcService.isConnecting
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Ghi ��m thanh
            SizedBox(
              width: 16.w,
            ),
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !webrtcService.isConnecting
                      ? IconButton(
                          onPressed: () {
                            ToastComponent.showToast(
                                message:
                                    "You need to connect the camera before Sound");
                          },
                          icon: Icon(
                            Icons.volume_up_outlined,
                            color: Colors.grey,
                            size: 20.sp,
                          ))
                      : IconButton(
                          onPressed: () {
                            webrtcService.setIsSounding =
                                !webrtcService.isSounding;
                          },
                          icon: Icon(
                            webrtcService.isAudioEnabled
                                ? Icons.volume_up_outlined
                                : Icons.volume_off,
                            size: 20.sp,
                          )),
                  Text(
                    "Sound",
                    style: TextStyle(
                      color: !webrtcService.isConnecting
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            // Screenshot
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !webrtcService.isConnecting
                      ? IconButton(
                          onPressed: () {
                            ToastComponent.showToast(
                                message:
                                    "You need to connect the camera before Screenshot");
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.grey,
                            size: 20.sp,
                          ))
                      : IconButton(
                          onPressed: () {
                            _captureScreenshot();
                          },
                          icon: Icon(
                            Icons.camera_alt_rounded,
                            size: 20.sp,
                          )),
                  Text(
                    "Screenshot",
                    style: TextStyle(
                      color: !webrtcService.isConnecting
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            // Tắt kết nối
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !webrtcService.isConnecting
                      ? IconButton(
                          onPressed: () {
                            ToastComponent.showToast(
                                message:
                                    "You need to connect the camera before Record");
                          },
                          icon: Icon(
                            Icons.video_call,
                            color: Colors.grey,
                            size: 20.sp,
                          ))
                      : IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.video_call,
                            size: 20.sp,
                          )),
                  Text(
                    "Record",
                    style: TextStyle(
                      color: !webrtcService.isConnecting
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            // Chuyển đ��i giữa camera chính và phụ
            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !webrtcService.isConnecting
                      ? IconButton(
                          onPressed: () {
                            ToastComponent.showToast(
                                message:
                                    "You need to connect the camera before Fullscreen");
                          },
                          icon: Icon(
                            Icons.fullscreen,
                            color: Colors.grey,
                            size: 20.sp,
                          ))
                      : IconButton(
                          onPressed: () {
                            Get.to(
                                () => FullscreenVideoPage(
                                      webrtcService: webrtcService,
                                      idcamera: widget.idcamera,
                                    ),
                                transition: Transition.native,
                                duration: const Duration(seconds: 1));
                          },
                          icon: Icon(
                            Icons.fullscreen,
                            size: 20.sp,
                          )),
                  Text(
                    "Fullscreen",
                    style: TextStyle(
                      color: !webrtcService.isConnecting
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.w,
            ),
            // Dừng video

            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: webrtcService.isLoadingSettingCamera
                        ? null
                        : () async {
                            webrtcService.settingsCamera(
                                widget.idcamera, context);
                          },
                    icon: Icon(
                      Icons.settings,
                      size: 20.sp,
                    ),
                  ),
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 16.w,
            ),

            Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      await webrtcService.settingsCameraTimer(widget.idcamera);
                      webrtcService.setIsTimer = !webrtcService.isTimer;
                      webrtcService.setIsPTZConnect = false;
                    },
                    icon: Icon(
                      !webrtcService.isTimer ? Icons.close : Icons.timer,
                      size: 20.sp,
                    ),
                  ),
                  Text(
                    "Timer",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}
