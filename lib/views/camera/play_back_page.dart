// ignore_for_file: sized_box_for_whitespace, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, prefer_const_constructors, unnecessary_import, curly_braces_in_flow_control_structures, unnecessary_null_comparison, prefer_is_empty, avoid_print, deprecated_member_use

import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/common/shimmer/shimmer_grid_view.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';
import 'package:vivoo_camera_cty/controllers/camera_controller.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'package:vivoo_camera_cty/views/camera/widget/dropdown_date_all_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart'; // Thêm thư viện video_player
import 'package:http/http.dart' as http;
import 'dart:convert';

class PLayBackVideo extends StatefulWidget {
  const PLayBackVideo({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<PLayBackVideo> createState() => _PLayBackVideoState();
}

class _PLayBackVideoState extends State<PLayBackVideo> {
  VideoPlayerController? _controller;
  final loginControler = Get.put(LoginController());
  final cloudRecordControllessr = Get.put(CloudRecordPathController());
  final notificationController = Get.put(NotificationController());
  final box = GetStorage();
  final webrtcServices = Get.put(WebRTCServiceController());

  ChewieController? _chewieController;
  Timer? _debounce;
  final TransformationController _transformationController =
      TransformationController();
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    // Trì hoãn 2 giây trước khi gọi fetchListVideoPlayback
    Future.delayed(Duration(seconds: 1), () {
      if (cloudRecordControllessr.cloudrecords.isNotEmpty) {
        cloudRecordControllessr.cloudrecords.clear();
      }
      webrtcServices.setSelectedTime = "Choose Date:";
      cloudRecordControllessr.setSelectedDateStart = '';
      cloudRecordControllessr.setSelectedDateEnd = '';
      cloudRecordControllessr.currentItemIndex.value = 0;
      cloudRecordControllessr.setStartTime = 0;
      cloudRecordControllessr.fetchListVideoPlayback(widget.idcamera);
    });
  }

  @override
  void dispose() {
    // if (_chewieController != null) {
    //   _chewieController!.dispose();
    // }
    if (_controller != null) {
      _controller!.pause();

      // Tắt âm thanh
      _controller!.setVolume(0.0); // Đặt âm lượng về 0

      // Hủy listener nếu có
      _controller!.removeListener(() {});

      _controller!.dispose();
    }

    _transformationController.dispose();
    // cloudRecordControllessr.dispose();
// Giải phóng controller khi widget bị hủy
    super.dispose();
  }

  Future<void> videoPlaybackPreviewFile(String cloudPath) async {
    cloudRecordControllessr.setLoadingPreviews = true;

    cloudRecordControllessr.setPath = cloudPath;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getRecordFileUrl";
    print("url videoPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": widget.idcamera,
          "cloud_record_path": cloudPath,
        }),
      );

      if (response.statusCode == 200) {
        print(
            "linkvideo videoPlaybackPreviewFile: ${cloudRecordControllessr.path}");
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];

        // Khởi tạo controller và phát video
        _controller = VideoPlayerController.network(
          presignedUrl,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        );

        try {
          await _controller!.initialize();
          if (mounted) {
            _chewieController = ChewieController(
              videoPlayerController: _controller!,
              autoPlay: true,
              looping: true,
              placeholder: Container(
                color: Colors.black,
              ),
              allowFullScreen: true,
              draggableProgressBar: true,
              showOptions: true,
              showControls: true,
              maxScale: 4.0,
              transformationController: _transformationController,
              zoomAndPan: true,
              additionalOptions: (context) {
                return [
                  OptionItem(
                    onTap: (BuildContext context) {
                      _captureScreenshot(); // đảm bảo là async nếu cần
                    },
                    iconData: Icons.photo_camera,
                    title: 'Capture Screenshot',
                  ),
                  OptionItem(
                    onTap: (BuildContext context) {
                      showDeleteConfirmationDialog(
                        context,
                        () {
                          cloudRecordControllessr.downloadVideo(
                              cloudPath, widget.idcamera);
                        },
                        "Are you sure you want to download this? This action cannot be undone.",
                        const Icon(
                          Icons.download,
                          size: 50,
                          color: Colors.black,
                        ),
                        'Download',
                        'Download',
                      );
                    },
                    iconData: Icons.download,
                    title: 'Download Video',
                  ),
                ];
              },
              optionsTranslation: OptionsTranslation(),
              playbackSpeeds: [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 3, 4],
              allowPlaybackSpeedChanging: true,
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
              bufferingBuilder: (context) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              },
            );

            cloudRecordControllessr.setPlaying = true;

            // cloudRecordControllessr
            //     .updateVideoDuration(_controller!.value.duration);
          }
          // _controller!.addListener(() {
          //   if (mounted) {
          //     // Kiểm tra mounted trước khi

          //     cloudRecordControllessr
          //         .updateCurrentPosition(_controller!.value.position);
          //   }
          // });
          _controller!.addListener(() {
            if (_controller!.value.isPlaying &&
                _controller!.value.isInitialized) {
              // Nếu video đang phát, âm thanh cũng sẽ phát
            } else {
              // Nếu video đã dừng, dừng luôn âm thanh
              _controller!.pause();
              _controller!.setVolume(0.0); // Tắt âm thanh khi video dừng
            }

            if (_controller!.value.hasError) {
              print(
                  "Video player error: ${_controller!.value.errorDescription}");
            }
          });

          _controller!.play();

          cloudRecordControllessr.setLoadingPreviews = false;

          ToastComponent.showToast(message: "Load Video Success");
        } catch (e) {
          print("Error initializing video player: $e");
          cloudRecordControllessr.setLoadingPreviews = false;
        }
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
        cloudRecordControllessr.setLoadingPreviews = false;
      } else {
        cloudRecordControllessr.setLoadingPreviews = false;

        ToastComponent.showToast(message: "Load Video Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      cloudRecordControllessr.setLoadingPreviews = false;

      print("Error videoPlaybackPreviewFile: $e");
    }
  }

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

  // void _togglePlayPause() {
  //   if (_controller != null) {
  //     if (_controller!.value.isPlaying) {
  //       _controller!.pause();
  //       cloudRecordControllessr.setPlaying = false;
  //     } else {
  //       _controller!.play();
  //       cloudRecordControllessr.setPlaying = true;
  //     }
  //   }
  // }

  // void _toggleMute() {
  //   if (_controller != null) {
  //     cloudRecordControllessr.setMuted = !cloudRecordControllessr.isMuted;
  //     _controller!.setVolume(cloudRecordControllessr.isMuted ? 0 : 1);
  //   }
  // }

  // String _formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final minutes = twoDigits(duration.inMinutes.remainder(60));
  //   final seconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "${twoDigits(duration.inHours)}:$minutes:$seconds";
  // }
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

  Future<void> loadNextImage() async {
    // Tải ảnh tiếp theo

    if (cloudRecordControllessr.currentItemIndexVideo.value <
        cloudRecordControllessr.cloudrecords.length - 1) {
      cloudRecordControllessr
          .currentItemIndexVideo.value++; // Tăng chỉ mục lên 1
    } else {
      cloudRecordControllessr.currentItemIndexVideo.value =
          0; // Nếu là item cuối cùng, quay lại đầu danh sách
    }

    videoPlaybackPreviewFile(cloudRecordControllessr
        .cloudrecords[cloudRecordControllessr.currentItemIndexVideo.value]
        .value);
  }

  Future<void> loadPreviousImage() async {
    // Tải ảnh tiếp theo

    if (cloudRecordControllessr.currentItemIndexVideo.value > 0) {
      cloudRecordControllessr
          .currentItemIndexVideo.value--; // Go to previous item
    } else {
      cloudRecordControllessr.currentItemIndexVideo.value =
          cloudRecordControllessr.cloudrecords.length -
              1; // If it's the first item, go to the last one
    }

    videoPlaybackPreviewFile(cloudRecordControllessr
        .cloudrecords[cloudRecordControllessr.currentItemIndexVideo.value]
        .value);
  }

  @override
  Widget build(BuildContext context) {
    final cloudRecordController = Get.put(CloudRecordPathController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h),
        child: AppBar(
          backgroundColor: Colors.blueGrey.shade900,
          // flexibleSpace: Container(
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [
          //         Colors.black,
          //         Colors.grey.shade800,
          //         Colors.white,
          //       ],
          //       stops: const [0.0, 0.5, 1.0],
          //     ),
          //   ),
          // ),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Play Back Video",
            style: TextStyle(
              fontSize: 24.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              if (_controller != null) {
                // Dừng video trước khi tắt âm thanh
                _controller!.pause();

                // Tắt âm thanh
                _controller!.setVolume(0.0); // Đặt âm lượng về 0

                // Hủy listener nếu có
                _controller!.removeListener(() {});

                // Giải phóng tài nguyên
                _controller!.dispose();
              }

              // Nếu bạn có chewieController thì cũng nên dừng nó
              if (_chewieController != null) {
                _chewieController!.dispose();
              }
              Get.back();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.rotate_left_outlined,
                color: Colors.black,
              ),
              onPressed: cloudRecordController.isLoadingPreviews
                  ? null
                  : () {
                      if (cloudRecordController.cloudrecords.isNotEmpty) {
                        cloudRecordController.cloudrecords.clear();
                      }
                      cloudRecordController
                          .fetchListVideoPlayback(widget.idcamera);
                      ToastComponent.showToast(
                          message: "Load Playback Success");
                    },
            ),
          ],
        ),
      ),
      body: Obx(
        () {
          if (cloudRecordController.isLoading) {
            return ShimmerGridView();
          }
          final groupedVideos =
              groupVideosByDate(cloudRecordController.cloudrecords);
          return Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller != null && cloudRecordController.isPlaying)
                  Center(
                    child: Stack(
                      children: [
                        Screenshot(
                          controller: screenshotController,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: Chewie(
                                controller: _chewieController!,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  cloudRecordController.isLoadingPreviews
                      ? Container(
                          color: Colors.black,
                          height: 200.h,
                          child: Center(
                              child: LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.black,
                            size: 30,
                          )),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          height: 200.h,
                          child: Center(
                            child: Text(
                              "No video to play",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (cloudRecordController.cloudrecords.length > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed:
                                    cloudRecordControllessr.isLoadingPreviews
                                        ? null
                                        : () {
                                            loadPreviousImage();
                                          },
                                icon: Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                              ),
                              Text(
                                "Previous",
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed:
                                    cloudRecordControllessr.isLoadingPreviews
                                        ? null
                                        : () {
                                            loadNextImage();
                                          },
                                icon: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                              ),
                              Text(
                                "Next",
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
                        ],
                      ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() {
                          return cloudRecordController.isDownloading
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 40.w,
                                      child: LinearProgressIndicator(
                                        value: cloudRecordController.progress,
                                        backgroundColor: Colors.grey,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    SizedBox(width: 6.w),
                                    SizedBox(
                                      width: 170.w,
                                      child: Text(
                                        '${(cloudRecordController.progress * 100).toStringAsFixed(2)}% Downloading...',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 17.sp),
                                      ),
                                    ),
                                  ],
                                )
                              : Container();
                        }),
                        if (!cloudRecordController.isDownloading)
                          Expanded(
                            child: Container(
                              width: double
                                  .infinity, // Bây giờ an toàn vì Expanded giới hạn kích thước
                              child: DropdownDateAllVideoPlayBack(
                                idcamera: widget.idcamera,
                              ),
                            ),
                          ),
                        SizedBox(width: 10.w),
                        if (!cloudRecordController.isDownloading)
                          Text("| Select Date:"),
                        if (!cloudRecordController.isDownloading)
                          IconButton(
                            icon: Icon(
                              Icons.calendar_month_outlined,
                              size: 30.sp,
                              color: Colors.black,
                            ),
                            onPressed: () async {
                              await cloudRecordController
                                  .showCustomDateTimePicker(context);

                              cloudRecordController
                                  .fetchListVideoPlayback(widget.idcamera);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
                if (!cloudRecordController.isDownloading &&
                    cloudRecordController.selectedDateStart != null &&
                    cloudRecordController.selectedDateStart.isNotEmpty)
                  Text(
                      "  Start Date: ${cloudRecordController.selectedDateStart}"),
                if (!cloudRecordController.isDownloading &&
                    cloudRecordController.selectedDateStart != null &&
                    cloudRecordController.selectedDateStart.isNotEmpty)
                  Text("  End Date: ${cloudRecordController.selectedDateEnd}"),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            String formattedDate =
                                groupedVideos.keys.elementAt(index);
                            List<dynamic> videos =
                                groupedVideos[formattedDate]!;
                            if (videos.isEmpty) {
                              return SizedBox
                                  .shrink(); // Không hiển thị gì nếu videos trống
                            }
                            if (videos.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          formattedDate.isNotEmpty
                                              ? formattedDate
                                              : "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 16.h),
                                        Obx(
                                          () => Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: Icon(
                                                cloudRecordController
                                                        .isShowMore(
                                                            formattedDate)
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
                                                    .toggleShowMore(
                                                        formattedDate);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    Obx(() {
                                      final visibleCount = cloudRecordController
                                          .getVisibleItemCount(
                                              formattedDate, videos.length);

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
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
                                                    .isLoadingPreviews
                                                ? null
                                                : () {
                                                    // if (_controller != null) {
                                                    //   _controller = null;
                                                    // }
                                                    int foundIndex =
                                                        cloudRecordControllessr
                                                            .cloudrecords
                                                            .indexWhere(
                                                                (record) =>
                                                                    record.ts ==
                                                                    video.ts);

                                                    cloudRecordControllessr
                                                        .currentItemIndexVideo
                                                        .value = (foundIndex !=
                                                            -1)
                                                        ? foundIndex
                                                        : 0;
                                                    if (_debounce?.isActive ??
                                                        false)
                                                      _debounce?.cancel();
                                                    _debounce = Timer(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      videoPlaybackPreviewFile(
                                                          video.value);
                                                    });
                                                  },
                                            child: Card(
                                              color: Colors.grey.shade100,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                side: BorderSide(
                                                  color: cloudRecordController
                                                              .cloudrecords[
                                                                  cloudRecordController
                                                                      .currentItemIndexVideo
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
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
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
                                                                    .downloadVideo(
                                                                        video
                                                                            .value,
                                                                        widget
                                                                            .idcamera);
                                                              },
                                                                  "Are you sure you want to download ${_extractTime(formattedDate)} this? This action cannot be undone.",
                                                                  const Icon(
                                                                    Icons
                                                                        .download,
                                                                    size: 50,
                                                                    color: Colors
                                                                        .black,
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
                                          );
                                        },
                                      );
                                    }),
                                    if (videos.length > 4)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(
                                            () => Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton.icon(
                                                icon: Icon(
                                                  cloudRecordController
                                                          .isShowMore(
                                                              formattedDate)
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 30.sp,
                                                  color: Colors.grey[500],
                                                ),
                                                label: Text(
                                                  cloudRecordController
                                                          .isShowMore(
                                                              formattedDate)
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
                                                          formattedDate,
                                                          videos.length);
                                                },
                                              ),
                                            ),
                                          ),
                                          Obx(
                                            () => Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton.icon(
                                                icon: Icon(
                                                  cloudRecordController
                                                          .isShowMore(
                                                              formattedDate)
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                          .keyboard_arrow_down,
                                                  size: 30.sp,
                                                  color: Colors.grey[500],
                                                ),
                                                label: Text(
                                                  cloudRecordController
                                                          .isShowMore(
                                                              formattedDate)
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
                                                      .toggleShowMore(
                                                          formattedDate);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(height: 10.h),
                                    Divider(
                                        color: Colors.grey.shade300,
                                        height: 1.0),
                                  ],
                                ),
                              );
                            } else {
                              return const Center(
                                  child: Text("No video found"));
                            }
                          },
                          childCount: groupedVideos.keys.isNotEmpty
                              ? groupedVideos.keys.length
                              : 0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
