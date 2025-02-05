import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/common/reusable_text.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.icon, // Thêm tham số icon
    this.color,
    this.onTap,
    this.btnWidth,
    this.radius,
    this.btnHieght,
  });

  final String text;
  final IconData? icon; // Tham số icon
  final Color? color;
  final double? btnWidth;
  final double? btnHieght;
  final double? radius;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: btnWidth ?? width,
        height: btnHieght ?? 28,
        decoration: BoxDecoration(
          color: color ?? kSecondary,
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 12)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Co lại theo nội dung
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: kLightWhite, size: 14.sp), // Icon với màu và size
                SizedBox(width: 1.w), // Khoảng cách giữa icon và text
              ],
              ReusableText(
                text: text,
                style: appStyle(12.sp, kLightWhite, FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
