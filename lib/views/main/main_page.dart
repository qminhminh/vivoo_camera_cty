// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vivoo_camera_cty/common/app_style.dart';
import 'package:vivoo_camera_cty/common/reusable_text.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/controllers/tab_controller.dart';
import 'package:vivoo_camera_cty/views/home/home_page.dart';
import 'package:vivoo_camera_cty/views/main/menu.dart';
import 'package:vivoo_camera_cty/views/notification/notification_page.dart';
import 'package:vivoo_camera_cty/views/profile/profile_page.dart';
import 'package:rive/rive.dart';

// ignore: must_be_immutable
class MainScreen extends HookWidget {
  MainScreen({Key? key}) : super(key: key);

  final box = GetStorage();

  List<Widget> pageList = <Widget>[
    const HomePage(),
    const NotificationPage(),
    // const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]); // Chỉ cho phép màn hình dọc
      return () {
        // Trả lại cấu hình mặc định khi widget bị dispose
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      };
    }, []);
    final notiController = Get.put(NotificationController());

    final entryController = Get.put(MainScreenController());
    List<SMIBool> riveIconInputs = [];

    return Obx(
      () => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            pageList[entryController.tabIndex],
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Theme(
            //     data: Theme.of(context).copyWith(canvasColor: kPrimary),
            //     child: BottomNavigationBar(
            //       selectedFontSize: 12,
            //       backgroundColor: kLightWhite,
            //       elevation: 0,
            //       showSelectedLabels: false,
            //       showUnselectedLabels: false,
            //       unselectedIconTheme:
            //           const IconThemeData(color: Colors.black38),
            //       items: [
            //         BottomNavigationBarItem(
            //           icon: entryController.tabIndex == 0
            //               ? const Icon(
            //                   AntDesign.appstore1,
            //                   color: Colors.black,
            //                   size: 24,
            //                 )
            //               : const Icon(AntDesign.appstore1),
            //           label: 'Home',
            //         ),
            //         BottomNavigationBarItem(
            //           icon: entryController.tabIndex == 1
            //               ? Badge(
            //                   label: ReusableText(
            //                       text: (notiController.unread).toString(),
            //                       style: appStyle(
            //                           8, kLightWhite, FontWeight.normal)),
            //                   child: const Icon(
            //                     Icons.notifications_active,
            //                     color: kSecondary,
            //                     size: 24,
            //                   ))
            //               : Badge(
            //                   label: ReusableText(
            //                       text: (notiController.unread).toString(),
            //                       style: appStyle(
            //                           8, kLightWhite, FontWeight.normal)),
            //                   child: const Icon(
            //                     Icons.notifications_active,
            //                   ),
            //                 ),
            //           label: 'Notifications',
            //         ),
            //         BottomNavigationBarItem(
            //           icon: entryController.tabIndex == 2
            //               ? const Icon(
            //                   FontAwesome.user_circle_o,
            //                   color: kSecondary,
            //                   size: 28,
            //                 )
            //               : const Icon(FontAwesome.user_circle_o),
            //           label: 'Profile',
            //         ),
            //       ],
            //       currentIndex: entryController.tabIndex,
            //       unselectedItemColor: Theme.of(context)
            //           .bottomNavigationBarTheme
            //           .unselectedItemColor,
            //       selectedItemColor: Theme.of(context)
            //           .bottomNavigationBarTheme
            //           .selectedItemColor,
            //       onTap: ((value) {
            //         entryController.setTabIndex = value;
            //       }),
            //     ),
            //   ),
            // ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60.h),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(bottomNavItems.length, (index) {
                      final riveIcon = bottomNavItems[index].rive;
                      return GestureDetector(
                        onTap: () {
                          entryController.setTabIndex = index;

                          riveIconInputs[index].change(true);
                          Future.delayed(const Duration(seconds: 1), () {
                            riveIconInputs[index].change(false);
                          });
                        },
                        child: SizedBox(
                          height: 56,
                          width: 56,
                          child: Stack(
                            children: [
                              RiveAnimation.asset(
                                riveIcon.src,
                                artboard: riveIcon.artboard,
                                onInit: (artboard) {
                                  StateMachineController? controller =
                                      StateMachineController.fromArtboard(
                                          artboard, riveIcon.stateMachineName);
                                  artboard.addController(controller!);
                                  riveIconInputs.add(controller
                                      .findInput<bool>('active') as SMIBool);
                                },
                              ),
                              if (index == 1) // Notification index
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Badge(
                                    label: ReusableText(
                                      text: notiController.unread.toString(),
                                      style: appStyle(
                                          8, kLightWhite, FontWeight.normal),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
        // bottomNavigationBar: SafeArea(
        //   child: Padding(
        //     padding: const EdgeInsets.only(bottom: 50),
        //     child: Container(
        //       height: 56,
        //       padding: const EdgeInsets.all(12),
        //       margin: const EdgeInsets.symmetric(horizontal: 24),
        //       decoration: BoxDecoration(
        //         color: kSecondary.withOpacity(0.8),
        //         borderRadius: const BorderRadius.all(Radius.circular(24)),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black.withOpacity(0.3),
        //             blurRadius: 10,
        //             offset: const Offset(0, 20),
        //           ),
        //         ],
        //       ),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: List.generate(bottomNavItems.length, (index) {
        //           final riveIcon = bottomNavItems[index].rive;
        //           return GestureDetector(
        //             onTap: () {
        //               entryController.setTabIndex = index;
        //               riveIconInputs[index].change(true);
        //               Future.delayed(const Duration(seconds: 1), () {
        //                 riveIconInputs[index].change(false);
        //               });
        //             },
        //             child: SizedBox(
        //               height: 56,
        //               width: 36,
        //               child: Stack(
        //                 children: [
        //                   RiveAnimation.asset(
        //                     riveIcon.src,
        //                     artboard: riveIcon.artboard,
        //                     onInit: (artboard) {
        //                       StateMachineController? controller =
        //                           StateMachineController.fromArtboard(
        //                               artboard, riveIcon.stateMachineName);
        //                       artboard.addController(controller!);
        //                       riveIconInputs.add(controller
        //                           .findInput<bool>('active') as SMIBool);
        //                     },
        //                   ),
        //                   if (index == 1) // Notification index
        //                     Positioned(
        //                       right: 0,
        //                       top: 0,
        //                       child: Badge(
        //                         label: ReusableText(
        //                           text: notiController.unread.toString(),
        //                           style: appStyle(
        //                               8, kLightWhite, FontWeight.normal),
        //                         ),
        //                       ),
        //                     ),
        //                 ],
        //               ),
        //             ),
        //           );
        //         }),
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
