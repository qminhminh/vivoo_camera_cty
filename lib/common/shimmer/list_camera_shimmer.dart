import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivoo_camera_cty/common/shimmer/shimmer_widget.dart';

class CameraListShimmer extends StatelessWidget {
  const CameraListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng của màn hình
    double width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(left: 12, top: 10),
      height: MediaQuery.of(context).size.height *
          0.6, // Thay đổi chiều cao nếu cần
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        itemCount: 6, // Hiển thị 6 item shimmer
        itemBuilder: (context, index) {
          return ShimmerWidget(
            shimmerWidth:
                width / 6, // Chia chiều rộng cho số lượng item (6 item)
            shimmerHeight:
                100.h, // Chiều cao của mỗi item shimmer (có thể thay đổi)
            shimmerRadius: 12,
          );
        },
      ),
    );
  }
}
