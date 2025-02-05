import 'package:flutter/material.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

class CustomButtonComponent extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final double? btnWidth;
  final double? btnHeight;

  const CustomButtonComponent({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.btnWidth = 80.0, // Default width
    this.btnHeight = 40.0, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: btnWidth,
        height: btnHeight,
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: appStyle(14, Colors.white, FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
