// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_null_comparison, avoid_print, empty_catches, prefer_const_constructors, unrelated_type_equality_checks

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/notification_conttroller.dart';
import 'package:vivoo_camera_cty/main.dart';
import 'package:vivoo_camera_cty/views/camera/camera_page.dart';

class NotificationService {
  final controller = Get.put(NotificationsController());
  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    if (!await checkInternetConnection()) {
      print("Không có kết nối mạng, không thể lấy FCM token.");
      return;
    }
    var androidInitialize =
        const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onDidReceiveNotificationResponse: (data) {
      try {
        if (data != null && data.payload!.isNotEmpty) {
          print("Received Notification: ${data.payload}");
          // navigatorKey.currentState
          //     ?.pushNamed('/order_details_page', arguments: data);
          final payloadData = jsonDecode(data.payload!);
          Get.to(
              () => CameraPage(
                    idcamera: payloadData['idcamera'] ?? '',
                    label: payloadData['label'] ?? '',
                  ),
              arguments: data);
        } else {
          //  Get.toNamed(RouteHelper.getNotificationRoute());
        }
      } catch (e) {}
    });
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final token = await _messaging.getToken();
    if (token != null) {
      controller.setFcm = token;
    }

    print('FCM Token: $token');

    initPushNotification();
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void handleMessage(RemoteMessage? message) {
    if (message?.notification != null) {
      navigatorKey.currentState
          ?.pushNamed('/order_details_page', arguments: message);
    } else {
      return;
    }
  }

  void initPushNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "onMessage: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");

      String orderData = jsonEncode(message.data);
      print("Order Data: $orderData");
      showBigTextNotification(
          message.notification!.body!,
          message.notification!.title!,
          orderData,
          flutterLocalNotificationsPlugin);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          "onOpenApp: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
      try {} catch (e) {
        print(e.toString());
      }
    });
  }

  static Future<void> showBigTextNotification(String title, String body,
      String orderID, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id_vivoo_1',
      'Vivoo',
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.high,
      ticker: 'You have a new announcement!',
      playSound: true,
      icon: 'notification_icon',
      color: Color(0xFF009CFF),
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }
}
