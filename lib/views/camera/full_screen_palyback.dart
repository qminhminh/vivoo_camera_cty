// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';

class FullScreenPlayback extends StatefulWidget {
  const FullScreenPlayback({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<FullScreenPlayback> createState() => _FullScreenPlaybackState();
}

class _FullScreenPlaybackState extends State<FullScreenPlayback> {
  late final CloudRecordPathController cloudRecordController;

  @override
  void initState() {
    super.initState();

    // Instantiate the controller only once
    cloudRecordController = Get.put(CloudRecordPathController());

    // Chuyển sang chế độ ngang khi vào fullscreen
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    // Trả lại chế độ đứng khi thoát fullscreen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Lắng nghe nhấn hoặc hover vào khu vực ảnh
          GestureDetector(
            onTap: () {
              // Toggle trạng thái hiển thị nút
              cloudRecordController.showButtons.value =
                  !cloudRecordController.showButtons.value;
            },
            onHorizontalDragEnd: (details) {
              // Kiểm tra hướng vuốt
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  // Vuốt sang trái
                  cloudRecordController.loadNextImage(widget.idcamera);
                } else if (details.primaryVelocity! > 0) {
                  // Vuốt sang phải
                  cloudRecordController.loadPreviousImage(widget.idcamera);
                }
              }
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Obx(
                () => cloudRecordController.pathHtmImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: cloudRecordController.pathHtmImageUrl,
                        placeholder: (context, url) => Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.black,
                          size: 30,
                        )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : const Center(
                        child: Text('No image'),
                      ),
              ),
            ),
          ),
          // Hiển thị nút dựa trên trạng thái
          Obx(
            () => cloudRecordController.showButtons.value
                ? Stack(
                    children: [
                      Positioned(
                        bottom: 50.w,
                        right: 15.w,
                        child: IconButton(
                          icon: const Icon(
                            Icons.fullscreen_exit,
                            color: Colors.red,
                            size: 30,
                          ),
                          onPressed: () async {
                            // Thoát fullscreen
                            await SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 150.w,
                        right: 38.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                cloudRecordController
                                    .loadPreviousImage(widget.idcamera);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Colors.black,
                                size: 30.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 150.w,
                        left: 15.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                cloudRecordController
                                    .loadNextImage(widget.idcamera);
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.black,
                                size: 30.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
