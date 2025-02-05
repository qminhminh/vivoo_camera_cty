// ignore_for_file: prefer_const_constructors, avoid_print, unused_import

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/common/custom_button.dart';
import 'package:vivoo_camera_cty/common/custom_container.dart';
import 'package:vivoo_camera_cty/common/show_dialog.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/views/check_internet.dart/no_connect_page.dart';
import 'package:vivoo_camera_cty/views/profile/alarms_page.dart';
import 'package:vivoo_camera_cty/views/profile/assets_page.dart';
import 'package:vivoo_camera_cty/views/profile/edit_profile_page.dart';
import 'package:vivoo_camera_cty/views/profile/notification_settings.dart';
import 'package:vivoo_camera_cty/views/profile/security_page.dart';
import 'package:vivoo_camera_cty/views/profile/widgets/tile_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final box = GetStorage();
    String? username = box.read('username');

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
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
          //         Colors.black, // Màu đen
          //         Colors.grey.shade800, // Màu xám
          //         Colors.white, // Màu trắng
          //       ],
          //       stops: const [0.0, 0.5, 1.0], // Điểm dừng của màu
          //     ),
          //   ),
          // ),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: 200,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "Profile",
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomContainer(
          color: Colors.white,
          containerContent: Column(
            children: [
              Container(
                height: hieght * 0.1,
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const EditProfilePage(),
                                    transition: Transition.native,
                                    duration: const Duration(seconds: 1));
                              },
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 40.h,
                                    width: 40.w,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      backgroundImage: const AssetImage(
                                        'assets/logo/Logo _circle.png',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          child: Tooltip(
                                            message: username ?? "",
                                            child: Text(
                                              username ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: appStyle(15.sp, kDark,
                                                  FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const EditProfilePage(),
                                    transition: Transition.native,
                                    duration: const Duration(seconds: 1));
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 21.0.h),
                                child: Icon(Feather.edit, size: 19.sp),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 170.h,
                decoration: const BoxDecoration(color: Colors.white),
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    TilesWidget(
                      onTap: () {
                        Get.to(() => SecurityPage(),
                            transition: Transition.native,
                            duration: const Duration(seconds: 1));
                      },
                      title: "Security",
                      leading: Ionicons.lock_closed,
                    ),
                    TilesWidget(
                      onTap: () {
                        Get.to(() => const NotificationSettingPage(),
                            transition: Transition.native,
                            duration: const Duration(seconds: 1));
                      },
                      title: "Notification settings",
                      leading: Ionicons.notifications,
                    ),
                    TilesWidget(
                      onTap: () {
                        Get.to(() => const AssetsPage(),
                            transition: Transition.native,
                            duration: const Duration(seconds: 1));
                      },
                      title: "Assets",
                      leading: Ionicons.build,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                height: 70.h,
                decoration: const BoxDecoration(color: Colors.white),
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: CustomButtons(
                            btnHieght: 50.h,
                            color: kDark,
                            text: "L O G  O U T",
                            onTap: () {
                              showDeleteConfirmationDialog(context, () {
                                controller.logout();
                              },
                                  "Are you sure you want to Logout? This action cannot be undone.",
                                  const Icon(
                                    Icons.logout_outlined,
                                    size: 50,
                                    color: Colors.black,
                                  ),
                                  'Logout',
                                  'Logout');
                            }),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
