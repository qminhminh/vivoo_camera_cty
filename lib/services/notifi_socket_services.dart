// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:get/get.dart';

class NotificationServiceSocket {
  WebSocketChannel? channel;
  final notiController = Get.put(NotificationController());
  // final service = FlutterBackgroundService();

  // Hàm khởi tạo WebSocket và dịch vụ nền

  // Kết nối WebSocket và lắng nghe dữ liệu
  void connect(String token) {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('wss://demo.espitek.com/api/ws'),
      );

      sendUnreadNotificationRequest(token);

      channel?.stream.listen(
        (message) {
          final response = jsonDecode(message);
          if (response["cmdId"] == 1 &&
              response["cmdUpdateType"] == "NOTIFICATIONS_COUNT") {
            print("Notifications: $response");
            notiController.setUnread = response["totalUnreadCount"];
            print("Unread notifications: ${notiController.unread}");
          } else {
            print("Received unexpected data: $response");
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          // reconnect(token);
        },
        onDone: () {
          print("WebSocket Connection Closed");
          // reconnect(token);
        },
      );
    } catch (e) {
      print("Error: $e");
      reconnect(token);
    }
  }

  // Gửi yêu cầu số lượng thông báo chưa đọc
  void sendUnreadNotificationRequest(String token) {
    final requestPayload = {
      "authCmd": {
        "cmdId": 0,
        "token": token,
      },
      "cmds": [
        {
          "type": "NOTIFICATIONS_COUNT",
          "cmdId": 1,
        }
      ],
    };

    channel?.sink.add(jsonEncode(requestPayload));
    print("Request sent: ${jsonEncode(requestPayload)}");
  }

  // Ngắt kết nối WebSocket
  void disconnect() {
    if (channel != null) {
      channel?.sink.close();
    }
    print("Disconnected from WebSocket");
  }

  void reconnect(String token) {
    Future.delayed(const Duration(seconds: 5), () {
      print("Reconnecting...");
      connect(token);
    });
  }
}
