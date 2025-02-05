import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({
    super.key,
    required this.shimmerWidth,
    required this.shimmerHeight,
    required this.shimmerRadius,
  });

  final double shimmerWidth;
  final double shimmerHeight;
  final double shimmerRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: shimmerWidth,
      height: shimmerHeight,
      padding: const EdgeInsets.only(right: 12, top: 8.0),
      child: _buildShimmerLine(
        height: shimmerHeight - 20, // Điều chỉnh chiều cao của shimmer nếu cần
        width: shimmerWidth - 15, // Điều chỉnh chiều rộng của shimmer nếu cần
        radius: shimmerRadius,
      ),
    );
  }

  Widget _buildShimmerLine({
    required double height,
    required double width,
    required double radius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor:
          kSecondaryLight, // Đảm bảo bạn đã định nghĩa kSecondaryLight
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
