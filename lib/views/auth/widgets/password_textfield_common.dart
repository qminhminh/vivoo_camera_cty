// ignore_for_file: use_super_parameters

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/password_controller.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    Key? key,
    required this.controller,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final passwordController = Get.put(PasswordController());
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: TextFormField(
          cursorColor: Colors.black,
          textInputAction: TextInputAction.next,
          focusNode: focusNode,
          keyboardType: TextInputType.visiblePassword,
          controller: controller,
          obscureText: passwordController.password,
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter a valid password";
            } else if (value.length < 6) {
              return "Password must be at least 6 characters";
            }
            if (value.length > 72) {
              return "Password must not exceed 72 characters";
            } else {
              return null;
            }
          },
          onEditingComplete: () {
            FocusScope.of(context)
                .unfocus(); // Ẩn bàn phím khi nhập xong mật khẩu
          },
          style: appStyle(
              16, kDark, FontWeight.normal), // Giống với TextFieldCommon
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: () {
                passwordController.setPassword = !passwordController.password;
              },
              child: Icon(
                passwordController.password
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: kGrayLight,
              ),
            ),
            hintText: 'Password',
            prefixIcon: Icon(
              CupertinoIcons.lock_circle,
              color: kGrayLight,
              size: 26.h,
            ),
            isDense: false,
            // contentPadding: const EdgeInsets.symmetric(
            //     vertical: 12.0, horizontal: 16.0), // Tăng padding chiều dọc
            hintStyle: appStyle(
                14, kGray, FontWeight.normal), // Giống với TextFieldCommon
            errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kDark, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kRed, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kGray, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: kGray, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(12))),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: kDark, width: 0.5),
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
