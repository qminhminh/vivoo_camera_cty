// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/common/custom_button.dart';
import 'package:vivoo_camera_cty/common/reusable_text.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/views/profile/widgets/text_field_security.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  late final TextEditingController newPasswordController =
      TextEditingController();
  late final TextEditingController confirmPasswordController =
      TextEditingController();
  late final TextEditingController oldPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Thêm GlobalKey

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Get.put(LoginController());

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
          //     ),
          //   ),
          // ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Security",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          SizedBox(
            height: 70.h,
          ),
          Center(
            child: ReusableText(
                text: "Change Password",
                style: appStyle(20.sp, Colors.black, FontWeight.bold)),
          ),
          SizedBox(height: 35.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableText(
                  text: "Current Password: ",
                  style: appStyle(16.sp, Colors.black, FontWeight.bold)),
              SizedBox(height: 5.h),
              Form(
                key: _formKey, // Sử dụng _formKey để quản lý form
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFieldCommonSecurity(
                      controller: oldPasswordController,
                      hintText: "Current Password",
                      validator: (value) {
                        if (value!.length < 6 || value.length > 72) {
                          return 'Password must be between 6 and 72 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    ReusableText(
                        text: "New Password: ",
                        style: appStyle(16.sp, Colors.black, FontWeight.bold)),
                    SizedBox(height: 5.h),
                    TextFieldCommonSecurity(
                      controller: newPasswordController,
                      hintText: "New Password",
                      validator: (value) {
                        if (value == oldPasswordController.text) {
                          return 'New password must be different from old password';
                        }
                        if (value!.length < 6 || value.length > 72) {
                          return 'Password must be between 6 and 72 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    ReusableText(
                        text: "Confirm New Password: ",
                        style: appStyle(16.sp, Colors.black, FontWeight.bold)),
                    SizedBox(height: 5.h),
                    TextFieldCommonSecurity(
                      controller: confirmPasswordController,
                      hintText: "Confirm New Password",
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Confirm password does not match new password';
                        }
                        if (value!.length < 6 || value.length > 72) {
                          return 'Password must be between 6 and 72 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Obx(
                () => loginController.isLoadChangePass
                    ? const Center(
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: kDark,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kLightWhite),
                        ),
                      )
                    : CustomButtons(
                        btnHieght: 50.h,
                        color: kDark,
                        text: "S A V E",
                        onTap: loginController.isLoadChangePass
                            ? null
                            : () {
                                // Gọi validate() khi người dùng nhấn nút "S A V E"
                                if (_formKey.currentState!.validate()) {
                                  // Kiểm tra kết nối nếu form hợp
                                  loginController.changePassword(
                                      oldPasswordController.text,
                                      newPasswordController.text);
                                } else {
                                  print("Form is not valid");
                                }
                              },
                      ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
