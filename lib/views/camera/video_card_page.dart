// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  final String videoPath;
  final String formattedDate;

  VideoCard({required this.videoPath, required this.formattedDate});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    // VideoPlayerController: Giải phóng tài nguyên video
    _controller.pause();
    _controller.dispose();

    super.dispose();
  }

  String _extractTime(String formattedDate) {
    // Giả định `formattedDate` là chuỗi có dạng "YYYY-MM-DD HH:mm:ss"
    List<String> dateParts = formattedDate.split(' ');
    if (dateParts.length > 1) {
      return dateParts[1]; // Lấy phần HH:mm:ss
    } else {
      return ''; // Trả về chuỗi rỗng nếu không có phần thời gian
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      height: 50.h,
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Center(
                  child: Text('No image', style: TextStyle(fontSize: 10.sp))),
            ),
          ),
          Positioned(
            bottom: 5.h,
            left: 10.w,
            child: Text(
              _extractTime(widget.formattedDate), // Chỉ hiển thị HH:mm:ss
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
