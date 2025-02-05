// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, use_build_context_synchronously, prefer_const_declarations, avoid_print, unnecessary_null_comparison, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:vivoo_camera_cty/common/control_row_component.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class FullscreenVideoPage extends StatefulWidget {
  final WebRTCServiceController webrtcService;
  final String idcamera;

  FullscreenVideoPage({required this.webrtcService, required this.idcamera});

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  ScreenshotController screenshotController = ScreenshotController();
  final webrtcServices = Get.put(WebRTCServiceController());

  @override
  void initState() {
    super.initState();

    // Đảm bảo chuyển chế độ màn hình sang ngang khi mở trang
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    // Đặt lại lại chế độ quay về chế độ mặc định khi thoát khỏi màn hình
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (webrtcServices.isRecording) {
      _stopRecording();
    }
    // webrtcServices.disconnect();
    super.dispose();
  }

  // Bắt đầu ghi màn hình
  Future<void> _startRecording() async {}

  // Future<void> _requestPermissions() async {
  //   await Permission.storage.request();
  //   await Permission.microphone.request();
  // }

  // Dừng ghi màn hình và lưu video vào bộ sưu tập
  Future<void> _stopRecording() async {}

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
        print('Failed to save screenshot');
        ToastComponent.showToast(message: "Failed to save screenshot");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Screenshot(
            controller: screenshotController,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: RTCVideoView(
                  widget.webrtcService.remoteRenderer,
                  mirror: false,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 38,
            child: IconButton(
              icon: const Icon(
                Icons.fullscreen_exit,
                color: Colors.red,
                size: 30,
              ),
              onPressed: () async {
                // Trở về chế độ đứng
                await SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);
                Navigator.pop(context);
              },
            ),
          ),
          // Positioned(
          //   bottom: 60.h,
          //   left: 8,
          //   child: IconButton(
          //     icon: Icon(
          //       widget.webrtcService.isConnecting
          //           ? Icons.stop_circle_outlined
          //           : Icons.play_circle_outline_outlined,
          //       color: Colors.white,
          //       size: 30,
          //     ),
          //     onPressed: () async {
          //       if (widget.webrtcService.isConnecting) {
          //         widget.webrtcService.disconnect();
          //         await SystemChrome.setPreferredOrientations(
          //             [DeviceOrientation.portraitUp]);
          //         Navigator.pop(context);
          //       } else {
          //         widget.webrtcService.connect(ipcUuid: widget.idcamera);
          //       }
          //     },
          //   ),
          // ),
          Positioned(
            bottom: 8.h,
            left: 8,
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _captureScreenshot,
            ),
          ),
          Positioned(
            bottom: 80.h,
            left: 8,
            child: IconButton(
              icon: Icon(
                webrtcServices.isRecording ? Icons.stop : Icons.videocam,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                if (webrtcServices.isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
                setState(() {
                  webrtcServices.setRecording = !webrtcServices.isRecording;
                });
              },
            ),
          ),
          Positioned(
            bottom: 150,
            left: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 30,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'Reset':
                    widget.webrtcService.resetCamera(widget.idcamera);
                    break;
                  case 'Stop':
                    widget.webrtcService.stopCamera(widget.idcamera);
                    break;
                  case 'Goback':
                    widget.webrtcService.goBackCamera(widget.idcamera);
                    break;
                  case "Left":
                    widget.webrtcService.leftCamera(widget.idcamera);
                    break;
                  case "Right":
                    widget.webrtcService.rightCamera(widget.idcamera);
                    break;
                  case "Up":
                    widget.webrtcService.upCamera(widget.idcamera);
                    break;
                  case "Down":
                    widget.webrtcService.downCamera(widget.idcamera);
                    break;
                  case "IR On":
                    widget.webrtcService.IROnCamera(widget.idcamera);
                    break;
                  case "IR Off":
                    widget.webrtcService.IROffCamera(widget.idcamera);
                    break;
                  case "IRCUT On":
                    widget.webrtcService.IRCUTOnCamera(widget.idcamera);
                    break;
                  case "IRCUT Off":
                    widget.webrtcService.IRCUTOffCamera(widget.idcamera);
                    break;
                  case "LED On":
                    widget.webrtcService.LEDONCamera(widget.idcamera);
                    break;
                  case "LED Off":
                    widget.webrtcService.LEDOFFCamera(widget.idcamera);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Reset',
                  child: Row(
                    children: const [
                      Icon(Icons.refresh, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Reset'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Stop',
                  child: Row(
                    children: const [
                      Icon(Icons.stop, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Stop'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Goback',
                  child: Row(
                    children: const [
                      Icon(Icons.home, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Goback'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Left',
                  child: Row(
                    children: const [
                      Icon(Icons.keyboard_arrow_left_rounded,
                          color: Colors.black),
                      SizedBox(width: 10),
                      Text('Left'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Right',
                  child: Row(
                    children: const [
                      Icon(Icons.chevron_right_outlined, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Right'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Up',
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_upward, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Up'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'Down',
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_downward, color: Colors.black),
                      SizedBox(width: 10),
                      Text('Down'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'IR On',
                  child: Row(
                    children: const [
                      Icon(Icons.wb_iridescent_outlined, color: Colors.black),
                      SizedBox(width: 10),
                      Text('IR On'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'IR Off',
                  child: Row(
                    children: const [
                      Icon(Icons.wb_iridescent, color: Colors.black),
                      SizedBox(width: 10),
                      Text('IR Off'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'IRCUT On',
                  child: Row(
                    children: const [
                      Icon(Icons.lens_outlined, color: Colors.black),
                      SizedBox(width: 10),
                      Text('IRCUT On'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'IRCUT Off',
                  child: Row(
                    children: const [
                      Icon(Icons.lens, color: Colors.black),
                      SizedBox(width: 10),
                      Text('IRCUT Off'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'LED On',
                  child: Row(
                    children: const [
                      Icon(Icons.light_mode_rounded, color: Colors.black),
                      SizedBox(width: 10),
                      Text('LED On'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'LED Off',
                  child: Row(
                    children: const [
                      Icon(Icons.light_mode_outlined, color: Colors.black),
                      SizedBox(width: 10),
                      Text('LED Off'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 150.h,
            right: 38,
            child: IconButton(
              icon: Icon(
                webrtcServices.isMenu ? Icons.close : Icons.menu_open_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  webrtcServices.setIsMenu = !webrtcServices.isMenu;
                });
              },
            ),
          ),
          Positioned(
              bottom: 210.h,
              right: 38,
              child: IconButton(
                onPressed: () async {
                  await webrtcServices.initializeStream();
                  if (webrtcServices.isAudioEnabledMic) {
                    webrtcServices.startAudioTransmission();
                  } else {
                    webrtcServices.stopAudioTransmission();
                  }
                  setState(() {
                    webrtcServices.setEnableAudioMic =
                        !webrtcServices.isAudioEnabledMic;
                  });
                },
                icon: Icon(
                  webrtcServices.isAudioEnabledMic
                      ? Icons.phone
                      : Icons.phone_disabled,
                  color: Colors.white,
                ),
              )),
          !webrtcServices.isMenu
              ? Container()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ControlRowComponent(
                          buttons: [
                            // Nút Left
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_left_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .leftCamera(widget.idcamera);
                              },
                            ),
                            // Nút Right
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_right_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .rightCamera(widget.idcamera);
                              },
                            ),
                            // Nút Up
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService.upCamera(widget.idcamera);
                              },
                            ),
                            // Nút Down
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .downCamera(widget.idcamera);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ControlRowComponent(
                          buttons: [
                            // Nút Reset
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .resetCamera(widget.idcamera);
                              },
                            ),
                            // Nút Stop
                            IconButton(
                              icon: const Icon(
                                Icons.light_mode_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .LEDONCamera(widget.idcamera);
                              },
                            ),
                            // Nút Goback
                            IconButton(
                              icon: const Icon(
                                Icons.light_mode_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .LEDOFFCamera(widget.idcamera);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ControlRowComponent(
                          buttons: [
                            // Nút Reset
                            IconButton(
                              icon: const Icon(
                                Icons.home,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .goBackCamera(widget.idcamera);
                              },
                            ),
                            // Nút Stop
                            IconButton(
                              icon: const Icon(
                                Icons.wb_iridescent_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .IROnCamera(widget.idcamera);
                              },
                            ),
                            // Nút Goback
                            IconButton(
                              icon: const Icon(
                                Icons.wb_iridescent,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .IROffCamera(widget.idcamera);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.lens_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .IRCUTOnCamera(widget.idcamera);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.lens,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.webrtcService
                                    .IRCUTOffCamera(widget.idcamera);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
