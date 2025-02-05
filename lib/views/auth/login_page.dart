// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/login_request.dart';
import 'package:vivoo_camera_cty/views/auth/widgets/password_textfield_common.dart';
import 'package:vivoo_camera_cty/views/auth/widgets/text_field_common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: const Color(0xFF0A74DA), // Xanh nước biển chủ đạo
      body: Center(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus(); // Ẩn bàn phím khi nhấn ra ngoài
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/Logo.png',
                      width: 100.w,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Box chứa nội dung đăng nhập
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Login to continue",
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.black54),
                          ),
                          SizedBox(height: 30.h),

                          // Email Input
                          TextFieldCommon(
                            focusNode: _passwordFocusNode,
                            hintText: "Email",
                            controller: _emailController,
                            prefixIcon: Icon(
                              CupertinoIcons.mail,
                              color: Colors.black54,
                              size: 22.h,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_passwordFocusNode),
                          ),
                          SizedBox(height: 20.h),

                          // Password Input
                          PasswordField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                          ),
                          SizedBox(height: 20.h),

                          // Nút đăng nhập
                          Obx(
                            () => controller.isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blueAccent),
                                  )
                                : GestureDetector(
                                    onTap: controller.isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              LoginRequest model = LoginRequest(
                                                username: _emailController.text,
                                                password:
                                                    _passwordController.text,
                                              );
                                              String authData =
                                                  loginRequestToJson(model);
                                              controller.loginFunc(authData);
                                            }
                                          },
                                    child: Container(
                                      width: double.infinity,
                                      height: 50.h,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.black, Colors.black],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "LOGIN",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          SizedBox(height: 20.h),

                          // Quên mật khẩu
                          GestureDetector(
                            onTap: () {
                              print("Navigate to Forgot Password");
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Đăng ký
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: () {
                                  print("Navigate to Sign Up");
                                },
                                child: Text(
                                  " Sign Up",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
