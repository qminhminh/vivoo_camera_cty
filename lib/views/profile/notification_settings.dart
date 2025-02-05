// ignore_for_file: prefer_const_constructors, avoid_print, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/common/shimmer/shimmer_notification_setting.dart';

import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/notification_setting_controller.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() =>
      _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final NotificationSettingController controller =
        Get.put(NotificationSettingController());

    Widget buildNotificationSettingItem(String key, dynamic setting) {
      return Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      key,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Obx(() => controller.notificationTypes[key] ?? false
                  ? Column(
                      children: controller.deliveryMethods.map((method) {
                        return SwitchListTile(
                          title: Text(method),
                          activeColor: Colors.black,
                          value: setting['enabledDeliveryMethods']?[method] ??
                              false,
                          onChanged: (value) {
                            controller.updateDeliveryMethod(key, method, value);
                          },
                        );
                      }).toList(),
                    )
                  : SizedBox.shrink()),
            ],
          ),
        ),
      );
    }

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
            "Notification Settings",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoadingWidget();
        }

        if (controller.notificationSettings.entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Icon(
                  Icons.notifications,
                  size: 150,
                ),

                SizedBox(height: 16), // Khoảng cách giữa ảnh và văn bản
                Text(
                  'Notification Setting in here',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView(
          children: controller.notificationSettings.entries.map((entry) {
            return buildNotificationSettingItem(entry.key, entry.value);
          }).toList(),
        );
      }),
      floatingActionButton: Obx(() {
        return SizedBox(
          width: 90.w,
          height: 40.h,
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            child: controller.isLoadingSave
                ? const Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: kDark,
                      valueColor: AlwaysStoppedAnimation<Color>(kLightWhite),
                    ),
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 25.sp,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
            onPressed: controller.isLoadingSave
                ? null
                : () {
                    controller.saveSettings().then((value) {
                      controller.fetchNotificationSettings();
                    }).catchError((error) {
                      controller.fetchNotificationSettings();
                    });
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text('Settings saved successfully')));
                  },
          ),
        );
      }),
    );
  }
}
