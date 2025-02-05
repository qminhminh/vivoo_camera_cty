import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';

// ignore: must_be_immutable
class CustomContainer extends StatelessWidget {
  CustomContainer(
      {super.key, this.containerContent, this.color, this.containerHieght});

  Widget? containerContent;
  Color? color;
  double? containerHieght;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: containerHieght ?? MediaQuery.of(context).size.height * 0.75,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.r),
            bottomRight: Radius.circular(30.r)),
        child: Container(
          width: width,
          height: ScreenUtil().screenHeight,
          color: kOffWhite,
          child: SingleChildScrollView(
            child: containerContent,
          ),
        ),
      ),
    );
  }
}
