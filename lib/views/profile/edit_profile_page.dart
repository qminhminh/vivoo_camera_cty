// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, unnecessary_null_comparison, prefer_const_constructors

import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/custom_button.dart';
import 'package:vivoo_camera_cty/common/reusable_text.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';
import 'package:vivoo_camera_cty/views/auth/widgets/text_field_onchange.dart';
import '../../common/app_style.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      // Kiểm tra kết nối và đảm bảo không gọi setState() nếu widget đã bị dispose
      getProfileUserEdit();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> getProfileUserEdit() async {
    var url = Uri.parse('${Environment.appBaseUrl}/api/auth/user');
    final box = GetStorage();

    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'x-authorization': 'Bearer ${loginController.token}',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _firstNameController.text = data['firstName'] ?? "";
          _lastNameController.text = data['lastName'] ?? "";
          _emailController.text = data['email'] ?? "";
          _phoneController.text = data['phone'] ?? "";
        });
      } else if (response.statusCode == 401) {
        box.erase();

        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Get user failed", data['message'],
            colorText: kLightWhite,
            backgroundColor: kRed,
            icon: const Icon(Icons.error));
        print("error: " + data['message']);
      }
    } catch (e) {
      print(e.toString());
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
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
            "Edit Profile",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60.r,
              backgroundImage: const AssetImage('assets/logo/Logo _circle.png'),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.camera_alt,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReusableText(
                      text: "First Name: ",
                      style: appStyle(16.sp, Colors.black, FontWeight.bold)),
                  SizedBox(height: 5.h),
                  TextFieldCommonOnChange(
                    hintText: "First Name",
                    prefixIcon: Icon(
                      CupertinoIcons.person,
                      color: Theme.of(context).dividerColor,
                      size: 26.h,
                    ),
                    controller: _firstNameController,
                    onChanged: (value) {
                      setState(() {
                        _firstNameController.text = value;
                      });
                    },
                  ),
                  SizedBox(height: 12.h),
                  ReusableText(
                      text: "Last Name: ",
                      style: appStyle(16.sp, Colors.black, FontWeight.bold)),
                  SizedBox(height: 5.h),
                  TextFieldCommonOnChange(
                    hintText: "Last Name",
                    controller: _lastNameController,
                    onChanged: (value) {
                      setState(() {
                        _lastNameController.text = value;
                      });
                    },
                    prefixIcon: Icon(
                      CupertinoIcons.person,
                      color: Theme.of(context).dividerColor,
                      size: 26.h,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ReusableText(
                      text: "Email: ",
                      style: appStyle(16.sp, Colors.black, FontWeight.bold)),
                  SizedBox(height: 5.h),
                  TextFieldCommonOnChange(
                      hintText: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        CupertinoIcons.mail,
                        color: Theme.of(context).dividerColor,
                        size: 26.h,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _emailController.text = value;
                        });
                      }),
                  SizedBox(height: 12.h),
                  ReusableText(
                      text: "Phone: ",
                      style: appStyle(16.sp, Colors.black, FontWeight.bold)),
                  SizedBox(height: 5.h),
                  TextFieldCommonOnChange(
                    hintText: "Phone",
                    prefixIcon: Icon(
                      CupertinoIcons.phone,
                      color: Theme.of(context).dividerColor,
                      size: 26.h,
                    ),
                    controller: _phoneController,
                    onChanged: (value) {
                      setState(() {
                        _phoneController.text = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => loginController.isLoadingUpdate
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: kDark,
                        valueColor: AlwaysStoppedAnimation<Color>(kLightWhite),
                      ),
                    )
                  : CustomButtons(
                      btnHieght: 50.h,
                      color: kDark,
                      text: "S A V E",
                      onTap: loginController.isLoadingUpdate
                          ? null
                          : () {
                              loginController
                                  .updateProfileUserEdit(
                                _phoneController
                                    .text, // Đảm bảo không cast lại sang int nếu dữ liệu là String
                                _firstNameController.text,
                                _lastNameController.text,
                                _emailController.text,
                              )
                                  .then((value) {
                                _phoneController.clear();
                                _firstNameController.clear();
                                _lastNameController.clear();
                                _emailController.clear();
                                getProfileUserEdit();
                              });
                            },
                    ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
