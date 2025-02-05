// ignore_for_file: avoid_print, non_constant_identifier_names, prefer_interpolation_to_compose_strings, prefer_final_fields, deprecated_member_use, prefer_const_constructors, unnecessary_null_comparison, use_build_context_synchronously, invalid_use_of_protected_member, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/common/show_dialog_setting_camera.dart';
import 'package:vivoo_camera_cty/constants/constants.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/controllers/login_controller.dart';
import 'package:vivoo_camera_cty/models/environment.dart';

class WebRTCServiceController extends GetxController {
  final controller = Get.put(LoginController()); // Khởi tạo controller
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  final cloundController = Get.put(CloudRecordPathController());
  RTCDataChannel? _dc;
  var fileList = <Map<String, dynamic>>[].obs;
  Completer<void>? gatheringCompleter;
  final box = GetStorage();
  RTCPeerConnection? _peerConnection;
  RxList<Map<String, dynamic>> scheduleData = <Map<String, dynamic>>[].obs;

  final String endpointBase = Environment.appBaseUrl;
  final String endpointRPC = Environment.endpointRPCs;
  final String endpointLogin = Environment.endpointLogins;

  final config = {
    'iceServers': [
      {'urls': Environment.urlSturn},
      {
        'urls': Environment.urlTurn,
        'username': Environment.usernameIce,
        'credential': Environment.passwordIce,
      },
    ],
  };

  final RxString clientId = ''.obs;
  String get isclientId => clientId.value;

  set setClientId(String newclientId) {
    clientId.value = newclientId;
  }

  var enableAudio = true.obs;
  bool get isAudioEnabled => enableAudio.value;
  set setEnableAudio(bool newValue) {
    enableAudio.value = newValue;
    update();
  }

  var enableAudioMic = true.obs;
  bool get isAudioEnabledMic => enableAudioMic.value;
  set setEnableAudioMic(bool newValue) {
    enableAudioMic.value = newValue;
    update();
  }

  MediaStream? mediaStream;

  @override
  void onInit() {
    super.onInit();
    remoteRenderer.initialize().then((_) {
      print("remoteRenderer initialized successfully.");
    }).catchError((error) {
      print("Error initializing remoteRenderer: $error");
    });

    setClientId = '';

    // disconnect();
  }

  @override
  void onClose() {
    remoteRenderer.dispose();
    _peerConnection?.close();
    disconnect();

    super.onClose();
  }

  Future<void> initializeStream() async {
    mediaStream = remoteRenderer.srcObject; // Gán MediaStream từ remoteRenderer
    if (mediaStream == null) {
      print("MediaStream is not initialized.");
      return;
    }
  }

// kết nối camera
  Future<void> connect({
    required String ipcUuid,
  }) async {
    setLoading = true;
    setClientId = _generateRandomId(10);
    print("clientid: $isclientId");
    print("ipcUuid: $ipcUuid");
    try {
      // await controller.refreshToken();
      final offer = await _sendRPC(
        method: "WEBRTC_REQUEST",
        uuid: ipcUuid,
        params: {"ClientId": isclientId, "type": "request"},
      );
      print("clientid: $isclientId");
      print("offer: $offer");
      print("ipcUuid: $ipcUuid");

      if (offer.isEmpty || !offer.containsKey('sdp')) {
        print("Invalid offer received.");
        return;
      }

      try {
        await _handleOffer(ipcUuid, offer);
      } catch (error) {
        print("Error _handleOffer: $error");
        debugPrint("_handleOffer error: $error");
        ToastComponent.showToast(message: "Error occurred: $error");
      }

      setisConnected = true; // Cập nhật trạng thái kết nối
      setLoading = false;
      setIsClickSdcard = true;
      update(); // Cập nhật lại trạng thái UI
    } catch (error) {
      setLoading = false;
      setIsClickSdcard = false;
      debugPrint("Connection error: $error");
      print("Connection error: $error");
    }
  }

// hủy kết nối
  Future<void> disconnect() async {
    setisConnected = false; // Cập nhật trạng thái kết nối
    setIsClickSdcard = false;
    _peerConnection?.close();
    _peerConnection = null;
    if (remoteRenderer.srcObject != null) {
      remoteRenderer.srcObject = null;
    }

    mediaStream = null;
    if (isPTZConnect) {
      setIsPTZConnect = false;
    }
    update(); // Cập nhật lại trạng thái UI
  }

// xử lý offer khi nhận từ server
  Future<Map<String, dynamic>> _sendRPC({
    required String method,
    required String uuid,
    required Map<String, dynamic> params,
  }) async {
    if (controller.token.isEmpty ||
        controller.isTokenExpired(controller.token)) {
      await controller.refreshToken();
    }
    print("toktne: " + controller.token);

    try {
      final url = "$endpointBase$endpointRPC/$uuid";
      print("Sending request to: $url");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "X-Authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": method,
          "params": params,
          "persistent": false,
          "timeout": 10000,
        }),
      );

      if (response.statusCode == 401) {
        await controller.refreshToken();
        return await _sendRPC(
          method: method,
          uuid: uuid,
          params: params,
        );
        // throw Exception("Failed to send RPC: ${response.body}");
      }

      print("status code send rpc: ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        disconnect();
        throw Exception("Failed to send RPC: ${response.body}");
      }
    } catch (error) {
      disconnect();
      print("Failed to send RPC: $error");
      debugPrint("RPC error: $error");
      throw Exception("Failed to send RPC: ${error.toString()}");
    }
  }

  // Future<void> addPush2Talk(RTCPeerConnection pc) async {
  //   // Thiết lập cấu hình cho media
  //   final Map<String, dynamic> mediaConstraints = {
  //     'audio': {
  //       'sampleRate': 8000,
  //       'sampleSize': 64000,
  //       'channelCount': 1,
  //     },
  //     'video': false, // Chỉ yêu cầu âm thanh
  //   };

  //   try {
  //     // Lấy stream từ micro
  //     mediaStream!.getUserMedia(mediaConstraints);

  //     // Thêm các track từ MediaStream vào RTCPeerConnection
  //     mediaStream.getTracks().forEach((track) {
  //       pc.addTrack(track, mediaStream);
  //     });

  //     print('Audio track added successfully!');
  //   } catch (e) {
  //     print('Error accessing media devices: $e');
  //   }
  // }

//xử lý đề nghị
  Future<void> _handleOffer(String uuid, Map<String, dynamic> offer) async {
    try {
      _peerConnection = await _createPeerConnection();

      if (_peerConnection == null) {
        print("Failed to create peer connection.");
      }
      if (offer['sdp'] == null || offer['type'] == null) {
        print("Invalid offer received. Missing 'sdp' or 'type'.");
        return;
      }

      await _peerConnection!.setRemoteDescription(RTCSessionDescription(
        offer['sdp'],
        offer['type'],
      ));

      RTCSessionDescription answer = await _peerConnection!.createAnswer();

      await _peerConnection!.setLocalDescription(answer);
      await waitGatheringComplete();
      print("answer type: ${answer.type}");
      print("answer sdp: ${answer.sdp}");
      await _sendRPC(
        method: "WEBRTC_ANSWER",
        uuid: uuid,
        params: {
          "ClientId": isclientId,
          "type": answer.type,
          "sdp": answer.sdp,
        },
      );
    } catch (e) {
      debugPrint("_handleOffer error: $e");
      print("Error _handleOffer: $e");
    }
  }

// Chờ thu thập hoàn thành
  Future<void> waitGatheringComplete() async {
    // Nếu gathering đã hoàn thành
    if (_peerConnection!.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }

    // Nếu đang có một Completer và gathering chưa hoàn thành, thì hủy nó
    if (gatheringCompleter != null && !gatheringCompleter!.isCompleted) {
      gatheringCompleter?.completeError(
          "Gathering interrupted or disposed before completion");
    }

    gatheringCompleter = Completer<void>();

    // Đặt lại callback khi ICE gathering state thay đổi
    _peerConnection!.onIceGatheringState = (RTCIceGatheringState state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        gatheringCompleter?.complete();
      }
    };
    await gatheringCompleter!.future;
  }

// Tạo kết nối ngang hàng
  Future<RTCPeerConnection> _createPeerConnection() async {
    final pc = await createPeerConnection(config);

    print("pc: $pc");

    pc.onIceConnectionState = (RTCIceConnectionState state) {
      print("ICE Connection state changed to: ${state.toString()}");
      if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        print(
            "ICE Connection failed. Check STUN/TURN server and network : ${state.toString()}");
      }
    };

    pc.onConnectionState = (RTCPeerConnectionState state) {
      print("Connection state changed to: ${state.toString()}");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        print(
            "PeerConnection failed. Possible ICE negotiation issues.${state.toString()}");
      }
    };

    pc.onTrack = (RTCTrackEvent event) {
      print("Received track event: ${event.toString()}");
      print("Event streams count: ${event.streams.length}");
      event.streams.forEach((stream) {
        print("Stream ID: ${stream.id}, Tracks: ${stream.getTracks().length}");
      });
      if (event.streams.isNotEmpty) {
        print("Stream ID: ${event.streams.first.id}");
        // mediaStream = event.streams.first;
        remoteRenderer.srcObject = event.streams.first;
      } else {
        disconnect();
        print("No streams found in track event.");
      }
    };

    pc.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate != null) {
        print("Generated ICE Candidate: ${candidate.toMap()}");
      } else {
        print("No more ICE candidates.");
      }
    };

    pc.onSignalingState = (RTCSignalingState state) {
      print("Signaling state changed: ${state.toString()}");
    };

    pc.onDataChannel = (RTCDataChannel channel) {
      _dc = channel;
      print("DataChannel opened: ${_dc?.label}");
      _dc?.onMessage = (RTCDataChannelMessage message) {
        if (message.isBinary) {
          print("Can't handle binary messages");
          return;
        }
        final response = jsonDecode(message.text);
        print("Received data channel message: $response");
        _handleDataChannelMessage(response);

        // try {
        //   final response = jsonDecode(message.text);
        //   print("Received data channel message: $response");
        //   _handleDataChannelMessage(response);
        // } catch (e) {
        //   print("Error decoding message: ${message.text}, error: $e");
        // }
      };

      _dc?.onDataChannelState = (RTCDataChannelState state) {
        print("DataChannel state changed: ${state.toString()}");
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          print("DataChannel closed");
        }
      };
    };

    return pc;
  }

  // Bắt đầu truyền âm thanh từ mic trên app
  Future<void> startAudioTransmission() async {
    if (_peerConnection == null) return;

    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': {
          'sampleRate': 8000,
          'sampleSize': 64000,
          'channelCount': 1,
        },
        // 'video': false, // Chỉ yêu cầu âm thanh
      };

      // Sử dụng getUserMedia từ flutter_webrtc
      mediaStream =
          await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);

      mediaStream!.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, mediaStream!);
      });

      print("Audio transmission started.");
      ToastComponent.showToast(message: "Audio transmission started.");
    } catch (e) {
      print("Error accessing media devices: $e");
      ToastComponent.showToast(message: "Error accessing media devices: $e");
    }
  }

// Dừng truyền âm thanh
  Future<void> stopAudioTransmission() async {
    if (_peerConnection == null) return;

    mediaStream?.getTracks().forEach((track) {
      track.stop();
    });

    print("Audio transmission stopped.");
    ToastComponent.showToast(message: "Audio transmission stopped.");
  }

  void toggleMute() {
    if (mediaStream == null) {
      print("MediaStream is not initialized.");
      return;
    }
    setEnableAudio = !isAudioEnabled; // Cập nhật giá trị bằng .value
    update(); // Cập nhật lại trạng thái UI

    mediaStream!.getAudioTracks().forEach((track) {
      track.enabled = isAudioEnabled;
    });
  }

  void adjustVolume(double volume) {
    if (mediaStream == null) {
      print("MediaStream is not initialized.");
      return;
    }
    mediaStream!.getAudioTracks().forEach((track) {
      track.enabled = volume > 0;
    });
  }

// Tạo ID ngẫu nhiên
  static String _generateRandomId(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return List.generate(length, (index) {
      final randomIndex = random.nextInt(characters.length);
      return characters[randomIndex];
    }).join();
  }

  void _handleDataChannelMessage(Map<String, dynamic> message) {
    print("Handling data channel message: $message");

    if (message['Type'] == 'Respond') {
      switch (message['Command']) {
        case 'GET_PLAYLIST':
          final content = message['Content'];
          print("Content received: $content");

          if (content['Regular'] != null) {
            final List<Map<String, dynamic>> files =
                List<Map<String, dynamic>>.from(content['Regular']);
            print("Regular files: $files");

            // Dữ liệu đang được mape thành fileData
            fileList.value = files.map((file) {
              final fileData = {
                'value': file['Name'],
                'start_ts': file['StartTS'],
                'end_ts': file['EndTS'],
              };
              print("Mapped file data: $fileData");
              return fileData;
            }).toList();

            fileList.value
                .sort((a, b) => b['start_ts'].compareTo(a['start_ts']));

            if (fileList.isEmpty) {
              setLoadingSDCard = false;
            }

            // Cập nhật danh sách file sau khi mape
            print("Updated fileList: ${fileList.value}");
            update(); // Nếu bạn đang sử dụng state management, gọi update để cập nhật UI
          } else {
            print("No regular files found.");
          }
          break;

        case "REQ_PLAYBACK":
          {}
          break;

        case 'REQ_FORMATSD':
          {}
          break;

        default:
          print("Unknown command: ${message['Command']}");
      }
      setLoadingSDCard = false;
    } else {
      print("Unknown message type: ${message['Type']}");
      setLoadingSDCard = false;
    }
  }

  void getFileList() {
    // setLoadingSDCard = true;
    fileList.clear();
    // int startTs = cloundController.startTimeSdcardImage == 0
    //     ? DateTime.now().toUtc().millisecondsSinceEpoch - 86400000
    //     : cloundController.startTimeSdcardImage;
    // int endTs = cloundController.endTimeSdcardImage == 0
    //     ? DateTime.now().toUtc().millisecondsSinceEpoch
    //     : cloundController.endTimeSdcardImage;

    // int startTsInSeconds = startTs ~/ 1000;
    // int endTsInSeconds = endTs ~/ 1000;
    // Giả sử selectedDate, startTime và endTime đã được lấy từ giao diện người dùng (giống JavaScript)

    DateTime now = DateTime.now();
    String selectedDate = DateFormat('MM/dd/yyyy').format(now);
    String startTime = "00:00";
    String endTime = "23:59";

// Hàm chuyển đổi ngày và giờ thành timestamp UTC (giây)
    int parseDateTimeToTimestamp(String date, String time) {
      final dateParts = date.split('/');
      final timeParts = time.split(':');
      return DateTime.utc(
            int.parse(dateParts[2]), // Năm
            int.parse(dateParts[0]), // Tháng
            int.parse(dateParts[1]), // Ngày
            int.parse(timeParts[0]), // Giờ
            int.parse(timeParts[1]), // Phút
          ).millisecondsSinceEpoch ~/
          1000;
    }

// Tính timestamp bắt đầu và kết thúc
    int startTsInSeconds = parseDateTimeToTimestamp(selectedDate, startTime);
    int endTsInSeconds = parseDateTimeToTimestamp(selectedDate, endTime);

// Lấy timestamp từ cloudController
    int parseCloudTimestamp(int cloudTime) {
      if (cloudTime == 0) return 0;

      DateTime originalDateTime =
          DateTime.fromMillisecondsSinceEpoch(cloudTime, isUtc: true);

      // Tạo DateTime mới không bao gồm giây
      DateTime withoutSeconds = DateTime.utc(
        originalDateTime.year,
        originalDateTime.month,
        originalDateTime.day,
        originalDateTime.hour,
        originalDateTime.minute,
      );

      // Trả về timestamp (millisecond)
      return withoutSeconds.millisecondsSinceEpoch ~/ 1000;
    }

    int startTimeInSeconds =
        parseCloudTimestamp(cloundController.startTimeSdcardImage);
    int endTimeInSeconds =
        parseCloudTimestamp(cloundController.endTimeSdcardImage);

// Kết hợp timestamp
    int startTs = cloundController.startTimeSdcardImage == 0
        ? startTsInSeconds
        : startTimeInSeconds;
    int endTs = cloundController.endTimeSdcardImage == 0
        ? endTsInSeconds
        : endTimeInSeconds;

    print(
        "Start timestamp in seconds: $startTs, End timestamp in seconds: $endTs");

    // print("Start timestamp: $startTs, End timestamp: $endTs");

    final msg = jsonEncode({
      'Id': idCamera,
      'Command': 'GET_PLAYLIST',
      'Type': 'Request',
      'Content': {
        'Type': 0,
        'BeginTime': startTs,
        'EndTime': endTs,
      },
    });

    print("Sending message: $msg");

    _dc?.send(RTCDataChannelMessage(msg));
    // setLoadingSDCard = false;
  }

  void replaySdVideo(String alias, int state) {
    print("Replaying video: $alias, state: $state");
    setLoadingSDCard = true;
    final msg = jsonEncode({
      'Id': idCamera,
      'Command': 'REQ_PLAYBACK',
      'Type': 'Request',
      'Content': {
        'Assign': alias,
        'Status': state,
      },
    });

    Future.delayed(const Duration(seconds: 1), () {
      _dc?.send(RTCDataChannelMessage(msg));
    });
  }

  Future<void> loadNextImage() async {
    // Tải ảnh tiếp theo

    if (cloundController.currentItemIndexSDcard.value < fileList.length - 1) {
      cloundController.currentItemIndexSDcard.value++; // Tăng chỉ mục lên 1
    } else {
      cloundController.currentItemIndexSDcard.value =
          0; // Nếu là item cuối cùng, quay lại đầu danh sách
    }

    replaySdVideo(
        fileList[cloundController.currentItemIndexSDcard.value]['value'], 0);
  }

  Future<void> loadPreviousImage() async {
    // Tải ảnh tiếp theo

    if (cloundController.currentItemIndexSDcard.value > 0) {
      cloundController.currentItemIndexSDcard.value--; // Go to previous item
    } else {
      cloundController.currentItemIndexSDcard.value =
          fileList.length - 1; // If it's the first item, go to the last one
    }

    replaySdVideo(
        fileList[cloundController.currentItemIndexSDcard.value]['value'], 0);
  }

  TimeOfDay millisecondsToTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  int timeToMilliseconds(TimeOfDay time) {
    return (time.hour * 3600 + time.minute * 60) * 1000;
  }

  // setting timer
  Future<void> settingsCameraTimer(String uuid) async {
    try {
      final url =
          "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$uuid/values/attributes/SERVER_SCOPE?keys=alarm_schedule";

      print("settingsCameraTimer url: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
      );

      if (response.statusCode == 200) {
        print("settingsCameraTimer successfully: ${response.body}");

        final data = jsonDecode(response.body) as List;
        if (data.isNotEmpty) {
          final alarmSchedule = data.firstWhere(
            (element) => element["key"] == "alarm_schedule",
            orElse: () => null,
          );

          if (alarmSchedule != null) {
            final items = alarmSchedule["value"]["items"] as List;
            scheduleData.value = items.cast<Map<String, dynamic>>();
          }
        }

        print("settingsCameraTimer scheduleData: $scheduleData");
      } else {
        final data = jsonDecode(response.body);
        print(
            "settingsCameraTimer: ${response.statusCode}: ${data['message']}");
        Get.snackbar(
          "Error",
          "Failed to fetch data: ${data["message"] ?? "Unknown error"}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("settingsCameraTimer camera fix: $e");
    }
  }

  Future<void> saveScheduleData(String uuid) async {
    setLoadingTimer = true;
    try {
      final url =
          "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$uuid/SERVER_SCOPE";

      print("Saving schedule data to: $url");

      final schedulePayload = {
        "alarm_schedule": {
          "timezone": "Asia/Ho_Chi_Minh",
          "items": scheduleData.value,
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode(schedulePayload),
      );

      if (response.statusCode == 200) {
        print("Schedule data saved successfully: ${response.body}");
        Get.snackbar(
          "Success",
          "Schedule data updated successfully",
          backgroundColor: Colors.grey[100],
          colorText: Colors.black,
        );
        setLoadingTimer = false;
      } else {
        final data = jsonDecode(response.body);
        print(
            "Failed to save schedule data: ${response.statusCode}: ${data['message']}");
        Get.snackbar(
          "Error",
          "Failed to update schedule: ${data["message"] ?? "Unknown error"}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        setLoadingTimer = false;
      }
    } catch (e) {
      setLoadingTimer = false;
      print("Error saving schedule data: $e");
      Get.snackbar(
        "Error",
        "An error occurred while saving the schedule.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // setting camrera
  Future<void> settingsCamera(String uuid, BuildContext context) async {
    setLoadingSettingCamera = true;
    try {
      final url =
          "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$uuid/values/attributes/SHARED_SCOPE";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
      );

      if (response.statusCode == 200) {
        print("Setting camera successfully: $url");
        print("Setting camera data successfully: ${response.body}");
        final data = jsonDecode(response.body);
        setLoadingSettingCamera = false;
        final filteredSettings = filterSettings(data);
        showDeleteConfirmationDialogSettings(context, filteredSettings, uuid);
      } else {
        setLoadingSettingCamera = false;
        final data = jsonDecode(response.body);

        print("Setting: ${response.statusCode}" + data['message']);
        Get.snackbar(
          "Setting camera false",
          "Error: ${data["message"] ?? "Unknown error"}",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      setLoadingSettingCamera = false;
      print("Setting camera fix: $e");
      Get.snackbar("Setting camera false", "Setting camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  // update setting camera
  Future<void> updatesettingsCamera(
      String cameraId, String key, bool value) async {
    setLoadingCamera = true;
    try {
      final url =
          "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$cameraId/SHARED_SCOPE";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({key: value}),
      );

      if (response.statusCode == 200) {
        print("updatesettingsCamera camera successfully: $url");
        print(
            "updatesettingsCamera camera data successfully: ${response.body}");
        final data = jsonDecode(response.body);
        Get.snackbar(
          "Update camera successfully",
          "Error: ${data["message"] ?? "Unknown error"}",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.error),
        );
        setLoadingCamera = false;
      } else {
        final data = jsonDecode(response.body);

        print("Setting: ${response.statusCode}" + data['message']);
        Get.snackbar(
          "Update camera false",
          "Error: ${data["message"] ?? "Unknown error"}",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.error),
        );
        setLoadingCamera = false;
      }
    } catch (e) {
      setLoadingCamera = false;
      print("Setting camera fix: $e");
      // Get.snackbar("Setting camera false", "Setting camera false",
      //     colorText: kLightWhite,
      //     backgroundColor: kDark,
      //     icon: const Icon(Icons.check));
    }
  }

  List<Map<String, dynamic>> filterSettings(List<dynamic> data) {
    const keysToExtract = [
      "cloud_hmd_enable",
      "cloud_mtd_enable",
      "cloud_stream_enable"
    ];
    return data
        .where((item) => keysToExtract.contains(item["key"]))
        .map((item) => {
              "key": item["key"],
              "value": item["value"],
            })
        .toList();
  }

// button PTZ
  Future<void> leftCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 3 0 100"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Left camera successfully");
        ToastComponent.showToast(message: "Left camera successfully");
      } else {
        ToastComponent.showToast(message: "Failed to send RPC");

        final data = jsonDecode(response.body);
        print("leftCamera: ${response.statusCode}" + data['message']);
        Get.snackbar(
          "Left camera false",
          "Error: ${data["message"] ?? "Unknown error"}",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      print("Left camera fix: $e");
      Get.snackbar("Left camera false", "Left camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> rightCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 3 0 -100"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Right camera successfully");
        ToastComponent.showToast(message: "Right camera successfully");
      } else {
        final data = jsonDecode(response.body);
        print("rightCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("Right camera false", "${data["message"]}",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("Right camera fix" + e.toString());
      Get.snackbar("Right camera false", "Right camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> upCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 3 50 0"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Up camera successfully");
        ToastComponent.showToast(message: "Up camera successfully");
      } else {
        final data = jsonDecode(response.body);
        print("upCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("Up camera false", "${data["message"]}",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("Up camera fix" + e.toString());
      Get.snackbar("Up camera false", "Up camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> downCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 3 -50 0"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Down camera successfully");
        ToastComponent.showToast(message: "Down camera successfully");
      } else {
        final data = jsonDecode(response.body);
        print("downCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("Down camera false", "${data["message"]}",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("Down camera fix" + e.toString());
      Get.snackbar("Down camera false", "Down camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> resetCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 2 1000 4000 300 2000"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Stop camera successfully");
        ToastComponent.showToast(message: "Reset camera successfully");
        // Get.snackbar("Stop camera successfully", "Stop camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("resetCamera: ${response.statusCode}" + data['message']);

        Get.snackbar("Reset camera false", "${data["message"]}",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("Reset camera fix" + e.toString());
      Get.snackbar("Stop camera false", "Stop camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> stopCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 1"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Stop camera successfully");
        ToastComponent.showToast(message: "Stop camera successfully");
        // Get.snackbar("Stop camera successfully", "Stop camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        print("Failed to send RPC: ${response.body}");
        final data = jsonDecode(response.body);
        print("Stop camera: ${response.statusCode}" + data['message']);
        Get.snackbar("Stop camera false", "${data["message"]}",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("Stop camera fix" + e.toString());

      Get.snackbar("Stop camera false", "Stop camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> goBackCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/motor 6"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        print("Stop camera successfully");

        ToastComponent.showToast(message: "Go back successfully");
        // Get.snackbar("Go back successfully", "Go back successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("goBackCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("Go back camera false", "${data["message"]}",
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("Go back camera fix" + e.toString());
      Get.snackbar("Go back camera false", "Go back camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> IROnCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/gpio2 3 i 10000 10000 n"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        ToastComponent.showToast(message: "IR On camera successfully");
        // Get.snackbar("IR On camera successfully", "IR On camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("IROnCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("IR On camera false", data["message"],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("IR On camera fix" + e.toString());
      Get.snackbar("IR On camera false", "IR On camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> IROffCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/gpio2 3 i 10000 0 n"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        ToastComponent.showToast(message: "IR Off camera successfully");
        // print("Stop camera successfully");
        // Get.snackbar("IR Off camera successfully", "IR Off camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("IROffCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("IR Off camera false", data["message"],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("IR On camera fix" + e.toString());
      Get.snackbar("IR Off camera false", "IR Off camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> IRCUTOnCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/gpio2 66 s 1"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        ToastComponent.showToast(message: "IRCUT On camera successfully");
        // print("Stop camera successfully");

        // Get.snackbar(
        //     "IRCUT On camera successfully", "IRCUT On camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("IRCUTOnCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("IRCUT On camera false", data["message"],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("IRCUTOnCamera camera fix" + e.toString());
      Get.snackbar("IRCUT On camera false", "IRCUT On camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> IRCUTOffCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/gpio2 66 s 0"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        ToastComponent.showToast(message: "IRCUT Off camera successfully");
        // print("Stop camera successfully");
        // Get.snackbar("LED On camera successfully", "LED On camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("IRCUTOffCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("LED On camera false", data["message"],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("IRCUTOffCamera camera fix" + e.toString());
      Get.snackbar("LED On camera false", "LED On camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> LEDONCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/gpio2 7 i 10000 10000 n"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        ToastComponent.showToast(message: "LED On camera successfully");
        // print("LEDONCamera camera successfully");
        // Get.snackbar("LED On camera successfully", "LED On camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("LEDONCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("LED On camera false", data["message"],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("LEDONCamera camera fix" + e.toString());
      Get.snackbar("LED On camera false", "LED On camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  Future<void> LEDOFFCamera(String uuid) async {
    try {
      final url = "${Environment.appBaseUrl}/api/rpc/oneway/$uuid";
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-authorization": "Bearer ${controller.token}",
        },
        body: jsonEncode({
          "method": "CLI",
          "params": {"cmd": "/oem/usr/bin/gpio2 7 i 10000 0 n"},
          "persistent": false,
          "timeout": 5000
        }),
      );

      if (response.statusCode == 200) {
        ToastComponent.showToast(message: "LED Off camera successfully");
        // print("Stop camera successfully");
        // Get.snackbar(
        //     "LED Off camera successfully", "LED Off camera successfully",
        //     colorText: kLightWhite,
        //     backgroundColor: kDark,
        //     icon: const Icon(Icons.check));
      } else {
        final data = jsonDecode(response.body);
        print("LEDOFFCamera: ${response.statusCode}" + data['message']);
        Get.snackbar("LED Off camera false", data["message"],
            colorText: kLightWhite,
            backgroundColor: kDark,
            icon: const Icon(Icons.check));
      }
    } catch (e) {
      print("LEDOFFCamera camera fix" + e.toString());
      Get.snackbar("LED Off camera false", "LED Off camera false",
          colorText: kLightWhite,
          backgroundColor: kDark,
          icon: const Icon(Icons.check));
    }
  }

  RxBool isConnected = false.obs;
  bool get isConnecting => isConnected.value;
  set setisConnected(bool newValue) {
    isConnected.value = newValue;
  }

  RxBool _isConnectWifi = true.obs;
  bool get isConnectWifi => _isConnectWifi.value;
  set setIsConnectWifi(bool newValue) {
    _isConnectWifi.value = newValue;
  }

  RxBool _isDropdownOpen = false.obs;
  bool get isDropdownOpen => _isDropdownOpen.value;
  set setIsDropdownOpen(bool newValue) {
    _isDropdownOpen.value = newValue;
  }

  RxString _selectedTime = "Choose Date:".obs;
  String get selectedTime => _selectedTime.value;
  set setSelectedTime(String newValue) {
    _selectedTime.value = newValue;
  }

  RxString _idCamera = "".obs;
  String get idCamera => _idCamera.value;
  set setidCamera(String newValue) {
    _idCamera.value = newValue;
  }

  RxDouble _volume = 1.0.obs;
  double get volume => _volume.value;
  set setVolume(double newValue) {
    _volume.value = newValue;
  }

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  RxBool _isLoadingSDCard = false.obs;

  bool get isLoadingSDCard => _isLoadingSDCard.value;

  set setLoadingSDCard(bool newValue) {
    _isLoadingSDCard.value = newValue;
  }

  RxBool _isLoadingSettingCamera = false.obs;

  bool get isLoadingSettingCamera => _isLoadingSettingCamera.value;

  set setLoadingSettingCamera(bool newValue) {
    _isLoadingSettingCamera.value = newValue;
  }

  RxBool _isLoadingTimer = false.obs;

  bool get isLoadingTimer => _isLoadingTimer.value;

  set setLoadingTimer(bool newValue) {
    _isLoadingTimer.value = newValue;
  }

  RxBool _isLoadingCamera = false.obs;

  bool get isLoadingCamera => _isLoadingCamera.value;

  set setLoadingCamera(bool newValue) {
    _isLoadingCamera.value = newValue;
  }

  RxBool _isRecording = false.obs;
  bool get isRecording => _isRecording.value;
  set setRecording(bool newValue) {
    _isRecording.value = newValue;
  }

  RxBool _isMenu = false.obs;
  bool get isMenu => _isMenu.value;
  set setIsMenu(bool newValue) {
    _isMenu.value = newValue;
  }

  RxBool _isPTZConnect = false.obs;
  bool get isPTZConnect => _isPTZConnect.value;
  set setIsPTZConnect(bool newValue) {
    _isPTZConnect.value = newValue;
  }

  RxBool _isSounding = false.obs;
  bool get isSounding => _isSounding.value;
  set setIsSounding(bool newValue) {
    _isSounding.value = newValue;
  }

  RxBool _isTimer = true.obs;
  bool get isTimer => _isTimer.value;
  set setIsTimer(bool newValue) {
    _isTimer.value = newValue;
  }

  RxBool _isClickAll = false.obs;
  bool get isClickAll => _isClickAll.value;
  set setIsClickAll(bool newValue) {
    _isClickAll.value = newValue;
  }

  RxBool _isClickSdcard = false.obs;
  bool get isClickSdcard => _isClickSdcard.value;
  set setIsClickSdcard(bool newValue) {
    _isClickSdcard.value = newValue;
  }

  RxBool _isClickHuman = false.obs;
  bool get isClickHuman => _isClickHuman.value;
  set setIsClickHuman(bool newValue) {
    _isClickHuman.value = newValue;
  }

  RxBool _isClickMotion = false.obs;
  bool get isClickMotion => _isClickMotion.value;
  set setIsClickMotion(bool newValue) {
    _isClickMotion.value = newValue;
  }
}
