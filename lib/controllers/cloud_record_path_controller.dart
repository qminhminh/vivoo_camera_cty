// ignore_for_file: prefer_final_fields, prefer_interpolation_to_compose_strings, avoid_print, prefer_const_constructors, unnecessary_string_interpolations, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vivoo_camera_cty/common/flutter_toast.dart';
import 'package:vivoo_camera_cty/controllers/notification_controller.dart';
import 'package:vivoo_camera_cty/models/cloud_hmd_img_path_model.dart';
import 'package:vivoo_camera_cty/models/cloud_mtn_img_path_model.dart';
import 'package:vivoo_camera_cty/models/cloud_record_path_model.dart';
import 'package:vivoo_camera_cty/models/environment.dart';
import 'package:vivoo_camera_cty/views/auth/login_page.dart';

import 'login_controller.dart';

class CloudRecordPathController extends GetxController {
  final loginControler = Get.put(LoginController());
  final notificationController = Get.put(NotificationController());
  var cloudrecords = <CloudRecordPath>[].obs;
  var cloudrecordshmdimg = <CloudHmdImgPath>[].obs;
  var cloudrecordMtdimg = <CloudMtdImgPath>[].obs;
  var currentPage = 0.obs;
  var totalPages = 1.obs;
  var itemsPerPage = 10.obs;
  var totalItems = 0.obs;
  bool _isRequestingPermission = false;
  final box = GetStorage();

  RxInt currentItemIndex = 0.obs;
  RxInt currentItemIndexMotion = 0.obs;
  RxInt currentItemIndexVideo = 0.obs;
  RxInt currentItemIndexSDcard = 0.obs;

  RxInt _currentTsHuman = 0.obs;
  int get currentTsHuman => _currentTsHuman.value;
  set setTsHuman(int newValue) {
    _currentTsHuman.value = newValue;
  }

  RxInt _currentTsMotion = 0.obs;
  int get currentTsMotion => _currentTsMotion.value;
  set setTsMotion(int newValue) {
    _currentTsMotion.value = newValue;
  }

  RxInt _currentTsSDcard = 0.obs;
  int get currentTsSDcard => _currentTsSDcard.value;
  set setTsSDcard(int newValue) {
    _currentTsSDcard.value = newValue;
  }

  RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  set setLoading(bool newValue) {
    _isLoading.value = newValue;
  }

  RxBool _isLoadingHuman = false.obs;
  bool get isLoadingHuman => _isLoadingHuman.value;
  set setLoadingHuman(bool newValue) {
    _isLoadingHuman.value = newValue;
  }

  RxBool _isLoadingMotion = false.obs;
  bool get isLoadingMotion => _isLoadingMotion.value;
  set setLoadingMotion(bool newValue) {
    _isLoadingMotion.value = newValue;
  }

  RxBool showButtons = false.obs;

  RxBool _isDownloading = false.obs;

  bool get isDownloading => _isDownloading.value;

  set setisDownloading(bool newValue) {
    _isDownloading.value = newValue;
  }

  RxDouble _progress = 0.0.obs;
  double get progress => _progress.value;
  set setProgress(double newValue) {
    _progress.value = newValue;
  }

  RxString _tsValueSdcard = ''.obs;
  String get tsValueSdcard => _tsValueSdcard.value;
  set settsValueSdcard(String newValue) {
    _tsValueSdcard.value = newValue;
  }

  RxString _tsHtm = ''.obs;
  String get tsHtm => _tsHtm.value;
  set setTsHtm(String newValue) {
    _tsHtm.value = newValue;
  }

  RxDouble _progressHtmImage = 0.0.obs;
  double get progressHtmImage => _progressHtmImage.value;
  set setProgressHtmImage(double newValue) {
    _progressHtmImage.value = newValue;
  }

  RxDouble _progressMtdImage = 0.0.obs;
  double get progressMtdImage => _progressMtdImage.value;
  set setProgressMtdImage(double newValue) {
    _progressMtdImage.value = newValue;
  }

  RxString _path = ''.obs;
  String get path => _path.value;
  set setPath(String newValue) {
    _path.value = newValue;
  }

  RxString _pathHtmImage = ''.obs;
  String get pathHtmImage => _pathHtmImage.value;
  set setPathHtmImage(String newValue) {
    _pathHtmImage.value = newValue;
  }

  RxString _pathMtdImage = ''.obs;
  String get pathMtdImage => _pathMtdImage.value;
  set setPathMtdImage(String newValue) {
    _pathMtdImage.value = newValue;
  }

  RxString _pathHtmImageUrl = ''.obs;
  String get pathHtmImageUrl => _pathHtmImageUrl.value;
  set setPathHtmImageUrl(String newValue) {
    _pathHtmImageUrl.value = newValue;
  }

  RxString _pathMtdImageUrl = ''.obs;
  String get pathMtdImageUrl => _pathMtdImageUrl.value;
  set setPathMtdImageUrl(String newValue) {
    _pathMtdImageUrl.value = newValue;
  }

  RxBool _isPlaying = false.obs;
  bool get isPlaying => _isPlaying.value;
  set setPlaying(bool newValue) {
    _isPlaying.value = newValue;
  }

  RxBool _isMuted = false.obs;
  bool get isMuted => _isMuted.value;
  set setMuted(bool newValue) {
    _isMuted.value = newValue;
  }

  RxBool _isLoadingPreviews = false.obs;
  bool get isLoadingPreviews => _isLoadingPreviews.value;
  set setLoadingPreviews(bool newValue) {
    _isLoadingPreviews.value = newValue;
  }

  RxBool _isLoadNextandPrevious = false.obs;
  bool get isLoadNextandPrevious => _isLoadNextandPrevious.value;
  set setLoadNextandPrevious(bool newValue) {
    _isLoadNextandPrevious.value = newValue;
  }

  RxInt _stopSdcard = 0.obs;
  int get stopSdcard => _stopSdcard.value;
  set setstopSdcard(int newValue) {
    _stopSdcard.value = newValue;
  }

  RxInt _startTime = 0.obs;
  int get startTime => _startTime.value;
  set setStartTime(int newValue) {
    _startTime.value = newValue;
  }

  RxInt _endTime = 0.obs;
  int get endTime => _endTime.value;
  set setEndTime(int newValue) {
    _endTime.value = newValue;
  }

  RxString _selectedDate = ''.obs;
  String get selectedDate => _selectedDate.value;
  set setSelectedDate(String newValue) {
    _selectedDate.value = newValue;
  }

  RxString _selectedDateStart = ''.obs;
  String get selectedDateStart => _selectedDateStart.value;
  set setSelectedDateStart(String newValue) {
    _selectedDateStart.value = newValue;
  }

  RxString _selectedDateEnd = ''.obs;
  String get selectedDateEnd => _selectedDateEnd.value;
  set setSelectedDateEnd(String newValue) {
    _selectedDateEnd.value = newValue;
  }

  RxString _selectedDateStartHtmImage = ''.obs;
  String get selectedDateStartHtmImage => _selectedDateStartHtmImage.value;
  set setSelectedDateStartHtmImage(String newValue) {
    _selectedDateStartHtmImage.value = newValue;
  }

  RxString _selectedDateEndHtmImage = ''.obs;
  String get selectedDateEndHtmImage => _selectedDateEndHtmImage.value;
  set setSelectedDateEndHtmImage(String newValue) {
    _selectedDateEndHtmImage.value = newValue;
  }

  RxString _selectedDateStartMtdImage = ''.obs;
  String get selectedDateStartMtdImage => _selectedDateStartMtdImage.value;
  set setSelectedDateStartMtdImage(String newValue) {
    _selectedDateStartMtdImage.value = newValue;
  }

  RxString _selectedDateEndMtdImage = ''.obs;
  String get selectedDateEndMtdImage => _selectedDateEndMtdImage.value;
  set setSelectedDateEndMtdImage(String newValue) {
    _selectedDateEndMtdImage.value = newValue;
  }

  RxString _selectedDateStartAllImage = ''.obs;
  String get selectedDateStartAllImage => _selectedDateStartAllImage.value;
  set setSelectedDateStartAllImage(String newValue) {
    _selectedDateStartAllImage.value = newValue;
  }

  RxString _selectedDateEndAllImage = ''.obs;
  String get selectedDateEndAllImage => _selectedDateEndAllImage.value;
  set setSelectedDateEndAllImage(String newValue) {
    _selectedDateEndAllImage.value = newValue;
  }

  RxString _selectedDateStartSdcardImage = ''.obs;
  String get selectedDateStartSdcardImage =>
      _selectedDateStartSdcardImage.value;
  set setSelectedDateStartSdcardImage(String newValue) {
    _selectedDateStartSdcardImage.value = newValue;
  }

  RxInt _buttonListSDCard = 0.obs;
  int get buttonListSDCard => _buttonListSDCard.value;
  set setbuttonListSDCard(int newValue) {
    _buttonListSDCard.value = newValue;
  }

  RxString _selectedDateEndSdcardImage = ''.obs;
  String get selectedDateEndSdcardImage => _selectedDateEndSdcardImage.value;
  set setSelectedDateEndSdcardImage(String newValue) {
    _selectedDateEndSdcardImage.value = newValue;
  }

  RxInt _startTimeHtmImage = 0.obs;
  int get startTimeHtmImage => _startTimeHtmImage.value;
  set setStartTimeHtmImage(int newValue) {
    _startTimeHtmImage.value = newValue;
  }

  RxInt _endTimeHtmImage = 0.obs;
  int get endTimeHtmImage => _endTimeHtmImage.value;
  set setEndTimeHtmImage(int newValue) {
    _endTimeHtmImage.value = newValue;
  }

  RxInt _startTimeMtdImage = 0.obs;
  int get startTimeMtdImage => _startTimeMtdImage.value;
  set setStartTimeMtdImage(int newValue) {
    _startTimeMtdImage.value = newValue;
  }

  RxInt _endTimeMtdImage = 0.obs;
  int get endTimeMtdImage => _endTimeMtdImage.value;
  set setEndTimeMtdImage(int newValue) {
    _endTimeMtdImage.value = newValue;
  }

  RxInt _startTimeAllImage = 0.obs;
  int get startTimeAllImage => _startTimeAllImage.value;
  set setStartTimeAllImage(int newValue) {
    _startTimeAllImage.value = newValue;
  }

  RxInt _endTimeAllImage = 0.obs;
  int get endTimeAllImage => _endTimeAllImage.value;
  set setEndTimeAllImage(int newValue) {
    _endTimeAllImage.value = newValue;
  }

  RxInt _startTimeSdcardImage = 0.obs;
  int get startTimeSdcardImage => _startTimeSdcardImage.value;
  set setStartTimeSdcardImage(int newValue) {
    _startTimeSdcardImage.value = newValue;
  }

  RxInt _endTimeSdcardImage = 0.obs;
  int get endTimeSdcardImage => _endTimeSdcardImage.value;
  set setEndTimeSdcardImage(int newValue) {
    _endTimeSdcardImage.value = newValue;
  }

  final RxMap<String, int> visibleItemCount = <String, int>{}.obs;

  void toggleShowMoreAdd4List(String formattedDate, int totalItems) {
    // visibleItemCount.clear();
    if (visibleItemCount[formattedDate] == null) {
      visibleItemCount[formattedDate] = 4; // Khởi tạo với 4 sản phẩm
    } else {
      visibleItemCount[formattedDate] = visibleItemCount[formattedDate]! + 4;
      if (visibleItemCount[formattedDate]! >= totalItems) {
        visibleItemCount[formattedDate] =
            totalItems; // Không vượt quá tổng số sản phẩm
      }
    }
  }

  void toggleShowMoreTru4List(String formattedDate, int totalItems) {
    // visibleItemCount.clear();
    visibleItemCount[formattedDate] == 4;
    if (visibleItemCount[formattedDate] == null) {
      visibleItemCount[formattedDate] = 4; // Khởi tạo với 4 sản phẩm
    } else {
      visibleItemCount[formattedDate] = visibleItemCount[formattedDate]! - 4;
      if (visibleItemCount[formattedDate]! >= totalItems) {
        visibleItemCount[formattedDate] =
            totalItems; // Không vượt quá tổng số sản phẩm
      }
    }
  }

  int getVisibleItemCount(String formattedDate, int totalItems) {
    // Kiểm tra xem có phải đang hiển thị tất cả các mục không
    if (isShowMore(formattedDate)) {
      return totalItems; // Nếu là true, hiển thị toàn bộ danh sách
    }

    // Kiểm tra nếu visibleItemCount[formattedDate] là null hoặc empty
    int count = visibleItemCount[formattedDate] ?? 4; // Mặc định là 4 sản phẩm
    if (count == null || count == 0) {
      return 0; // Nếu null hoặc empty, trả về 0
    }

    // Kiểm tra nếu count lớn hơn số lượng item thực tế
    if (count > totalItems) {
      return totalItems; // Nếu count lớn hơn số lượng item thực tế, chỉ hiển thị số lượng thực tế
    }
    return count;
  }

  final RxMap<String, bool> showMoreStatus = <String, bool>{}.obs;

  void toggleShowMore(String formattedDate) {
    showMoreStatus[formattedDate] = !(showMoreStatus[formattedDate] ?? false);
  }

  bool isShowMore(String formattedDate) {
    return showMoreStatus[formattedDate] ?? false;
  }

  final RxMap<String, bool> showMoreStatusTrue = <String, bool>{}.obs;

  void toggleShowMoreTrue(String formattedDate) {
    showMoreStatusTrue[formattedDate] =
        !(showMoreStatusTrue[formattedDate] ?? true);
  }

  bool isShowMoreTrue(String formattedDate) {
    return showMoreStatusTrue[formattedDate] ?? true;
  }

  Rx<Duration> currentPosition = Duration.zero.obs;
  Rx<Duration> videoDuration = Duration.zero.obs;

  // Hàm để cập nhật vị trí video
  void updateCurrentPosition(Duration newPosition) {
    currentPosition.value = newPosition;
  }

  // Hàm để cập nhật độ dài video
  void updateVideoDuration(Duration newDuration) {
    videoDuration.value = newDuration;
  }

  @override
  void onClose() {
    setLoading = true;
    cloudrecords.clear();
    cloudrecordshmdimg.clear();
    cloudrecordMtdimg.clear();

    super.onClose();
  }
//41cf0f00-936a-11ef-a41f-ffffca4e13b8

  // fetch video play black
  Future<void> fetchListVideoPlayback(String ipUUid) async {
    setLoading = true;
    cloudrecords.clear();

    setLoadingPreviews = true;
    if (loginControler.token.isEmpty ||
        loginControler.isTokenExpired(loginControler.token)) {
      await loginControler.refreshToken();
    }
    int startTs = startTime == 0
        ? DateTime.now().millisecondsSinceEpoch - 86400000
        : startTime;
    int endTs = endTime == 0 ? DateTime.now().millisecondsSinceEpoch : endTime;

    final String url =
        "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_record_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    print("url fetchListVideoPlayback :" + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          // 'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        setLoading = false;
        final data = json.decode(response.body);
        final cloudrecordsresponse = CloudRecord.fromJson(data);

        cloudrecords.addAll(cloudrecordsresponse.cloudRecordPath);

        print(
            "fetchListVideoPlayback: ${response.body} = length: ${cloudrecords.length}");
        setLoadingPreviews = false;
      } else if (response.statusCode == 401) {
        setLoadingPreviews = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadingPreviews = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error fetchListVideoPlayback", "${data['message']}");

        print(
            "fetchListVideoPlayback: ${response.statusCode}" + data['message']);
      }
      update();
    } catch (e) {
      print("Error fetchListVideoPlayback: $e");
      setLoadingPreviews = false;
      update();
    } finally {
      setLoadingPreviews = false;
    }
  }

  Future<void> showCustomDateTimePicker(BuildContext context) async {
    DateTime? startDateTime =
        await selectDateTime(context, "Select Start Time");
    if (startDateTime == null) return;

    setStartTime = startDateTime.millisecondsSinceEpoch;
    setSelectedDateStart =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
    update();

    DateTime? endDateTime = await selectDateTime(context, "Select End Time");
    if (endDateTime == null) return;

    setEndTime = endDateTime.millisecondsSinceEpoch;
    setSelectedDateEnd = DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);
    update();

    print("Datetime start: $startTime, end: $endTime");
    print("Datetime now: ${DateTime.now().millisecondsSinceEpoch}");

    // setStartTime = startTs;
    // setEndTime = endTs;
    update();
  }

  Future<DateTime?> selectDateTime(BuildContext context, String title) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Pick Date
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: title,
    );

    if (selectedDate == null) return null;

    // Pick Time
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return null;

    // Combine Date and Time
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
      1, // Seconds default to 0
    );
  }

  Future<void> videoPlaybackPreviewFile(String ipUUid, String cloudPath) async {
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getRecordFileUrl";
    print("url videoPlaybackPreviewFile :" + url);
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": ipUUid,
          "cloud_record_path": cloudPath
        }),
      );

      if (response.statusCode == 200) {
        print("videoPlaybackPreviewFile: ${response.statusCode}");
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error videoPlaybackPreviewFile", "${data['message']}");

        print("videoPlaybackPreviewFile: ${response.statusCode}" +
            data['message']);
      }
      update();
    } catch (e) {
      print("Error videoPlaybackPreviewFile: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
    }
  }

  Future<void> downloadVideo(String linkVideo, String idCamera) async {
    _requestPermissions();
    Dio dio = Dio();
    setisDownloading = true;
    print("linkvideo: $linkVideo");
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getRecordFileUrl";
    print("url downloadVideo: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idCamera,
          "cloud_record_path": linkVideo,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        print("presignedUrl: $presignedUrl");
// Đường dẫn lưu video
        try {
          final directory = await getTemporaryDirectory();
          // Tải video bằng Dio và theo dõi tiến trình
          final filename =
              'downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          final filePath = '${directory.path}/$filename';
          await dio.download(presignedUrl, filePath,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              setProgress = received / total; // Cập nhật tiến trình tải xuống
              print("progress: " + _progress.toString());
              update();
            }
          });
          final result = await ImageGallerySaverPlus.saveFile(filePath);
          print(result);

          // Mở video sau khi tải xong
          OpenFile.open(filePath);

          // Hiển thị thông báo thành công
          ToastComponent.showToast(message: "Download Video Success");
          setisDownloading = false;
        } catch (e) {
          //  debugPrint('Tải video thất bại: $e');
          ToastComponent.showToast(
              message: "Download Video Failed! Check Internet");
          setisDownloading = false;
        }
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error downloadVideo", "${data['message']}");
        print("downloadVideo: ${response.statusCode}" + data['message']);
        ToastComponent.showToast(message: "Download Video Failed");
        setisDownloading = false;
      }
    } catch (e) {
      print("Error downloadVideo: $e");
      setisDownloading = false;
    }
  }

  void _requestPermissions() async {
    if (_isRequestingPermission) {
      return; // If a request is already in progress, return early
    }

    _isRequestingPermission = true; // Mark the request as in progress
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    _isRequestingPermission =
        false; // Reset the flag after the request is complete
  }

  //=================================================== fecth htm image play back
  Future<void> fetchListImagePlayback(String ipUUid) async {
    setLoading = true;
    cloudrecordshmdimg.clear();
    if (loginControler.token.isEmpty ||
        loginControler.isTokenExpired(loginControler.token)) {
      await loginControler.refreshToken();
    }
    int startTs = startTimeHtmImage == 0
        ? DateTime.now().millisecondsSinceEpoch - 86400000
        : startTimeHtmImage;
    int endTs = endTimeHtmImage == 0
        ? DateTime.now().millisecondsSinceEpoch
        : endTimeHtmImage;

    final String url =
        "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_hmd_img_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";

    //  "https://demo.espitek.com/api/plugins/telemetry/DEVICE/41cf0f00-936a-11ef-a41f-ffffca4e13b8/values/timeseries?keys=cloud_hmd_img_path&startTs=1736153000126&endTs=1736239400127&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    // "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_hmd_img_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    print("url fetchListImagePlayback :" + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          // 'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cloudrecordsresponse = CloudHmd.fromJson(data);

        cloudrecordshmdimg.addAll(cloudrecordsresponse.cloudRecordPath);
        setLoading = false;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error fetchListImagePlayback", "${data['message']}");

        print(
            "fetchListImagePlayback: ${response.statusCode}" + data['message']);
      }
      update();
    } catch (e) {
      print("Error fetchListImagePlayback: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
    }
  }

  // download image htm
  Future<void> downloadImageHtm(String linkImag, String idCamera) async {
    _requestPermissions();
    Dio dio = Dio();
    setisDownloading = true;
    print("linkvideo: $linkImag");
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getHmdImgFileUrl";
    print("url downloadVideo: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idCamera,
          "cloud_hmd_img_path": linkImag,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        print("presignedUrl: $presignedUrl");
// Đường dẫn lưu video
        try {
          final directory = await getTemporaryDirectory();
          // Tải video bằng Dio và theo dõi tiến trình
          final filename =
              'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = '${directory.path}/$filename';
          await dio.download(presignedUrl, filePath,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              setProgressHtmImage =
                  received / total; // Cập nhật tiến trình tải xuống
              print("progress: " + _progressHtmImage.toString());
              update();
            }
          });
          final result = await ImageGallerySaverPlus.saveFile(filePath);
          print(result);

          // Mở video sau khi tải xong
          OpenFile.open(filePath);

          // Hiển thị thông báo thành công
          ToastComponent.showToast(message: "Download Video Success");
          setisDownloading = false;
        } catch (e) {
          //  debugPrint('Tải video thất bại: $e');
          ToastComponent.showToast(
              message: "Download Video Failed! Check Internet");
          setisDownloading = false;
        }
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error downloadVideo", "${data['message']}");
        print("downloadVideo: ${response.statusCode}" + data['message']);
        ToastComponent.showToast(message: "Download Video Failed");
        setisDownloading = false;
      }
    } catch (e) {
      print("Error downloadVideo: $e");
      setisDownloading = false;
    }
  }

  // download image htm
  Future<void> downloadImageAll(String linkImag, String idCamera) async {
    _requestPermissions();
    Dio dio = Dio();
    setisDownloading = true;
    print("linkvideo: $linkImag");
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getHmdImgFileUrl";
    print("url downloadVideo: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idCamera,
          "cloud_hmd_img_path": linkImag,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        print("presignedUrl: $presignedUrl");
// Đường dẫn lưu video
        try {
          final directory = await getTemporaryDirectory();
          // Tải video bằng Dio và theo dõi tiến trình
          final filename =
              'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = '${directory.path}/$filename';
          await dio.download(presignedUrl, filePath,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              setProgressHtmImage =
                  received / total; // Cập nhật tiến trình tải xuống
              print("progress: " + _progressHtmImage.toString());
              update();
            }
          });
          final result = await ImageGallerySaverPlus.saveFile(filePath);
          print(result);

          // Mở video sau khi tải xong
          OpenFile.open(filePath);

          // Hiển thị thông báo thành công
          ToastComponent.showToast(message: "Download Video Success");
          setisDownloading = false;
        } catch (e) {
          //  debugPrint('Tải video thất bại: $e');
          ToastComponent.showToast(
              message: "Download Video Failed! Check Internet");
          setisDownloading = false;
        }
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error downloadVideo", "${data['message']}");
        print("downloadVideo: ${response.statusCode}" + data['message']);
        ToastComponent.showToast(message: "Download Video Failed");
        setisDownloading = false;
      }
    } catch (e) {
      print("Error downloadVideo: $e");
      setisDownloading = false;
    }
  }

  Future<void> showCustomDateTimePickerHtmImge(BuildContext context) async {
    DateTime? startDateTime =
        await selectDateTimeHtmImge(context, "Select Start Time");
    if (startDateTime == null) return;

    setStartTimeHtmImage = startDateTime.millisecondsSinceEpoch;
    setSelectedDateStartHtmImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
    update();

    DateTime? endDateTime =
        await selectDateTimeHtmImge(context, "Select End Time");
    if (endDateTime == null) return;

    setEndTimeHtmImage = endDateTime.millisecondsSinceEpoch;
    setSelectedDateEndHtmImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);
    update();

    print("Datetime start: $startTime, end: $endTime");
    print("Datetime now: ${DateTime.now().millisecondsSinceEpoch}");

    // setStartTime = startTs;
    // setEndTime = endTs;
    update();
  }

  Future<DateTime?> selectDateTimeHtmImge(
      BuildContext context, String title) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Pick Date
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: title,
    );

    if (selectedDate == null) return null;

    // Pick Time
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return null;

    // Combine Date and Time
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
      1, // Seconds default to 0
    );
  }

  // ================================= slect date sdcard
  Future<void> showCustomDateTimePickerSdcardImage(BuildContext context) async {
    DateTime? startDateTime =
        await selectDateTimeSdcardImage(context, "Select Start Time");
    if (startDateTime == null) return;

    setStartTimeSdcardImage = startDateTime.millisecondsSinceEpoch;
    setSelectedDateStartSdcardImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
    update();

    DateTime? endDateTime =
        await selectDateTimeSdcardImage(context, "Select End Time");
    if (endDateTime == null) return;

    setEndTimeSdcardImage = endDateTime.millisecondsSinceEpoch;
    setSelectedDateEndSdcardImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);
    update();

    print("Datetime start: $startTime, end: $endTime");
    print("Datetime now: ${DateTime.now().millisecondsSinceEpoch}");

    // setStartTime = startTs;
    // setEndTime = endTs;
    update();
  }

  Future<DateTime?> selectDateTimeSdcardImage(
      BuildContext context, String title) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Pick Date
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: title,
    );

    if (selectedDate == null) return null;

    // Pick Time
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return null;

    // Combine Date and Time
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
      1, // Seconds default to 0
    );
  }

  // ================================================ fetch image mtd

  Future<void> fetchListImageMtdPlayback(String ipUUid) async {
    setLoading = true;
    cloudrecordMtdimg.clear();
    if (loginControler.token.isEmpty ||
        loginControler.isTokenExpired(loginControler.token)) {
      await loginControler.refreshToken();
    }
    int startTs = startTimeMtdImage == 0
        ? DateTime.now().millisecondsSinceEpoch - 86400000
        : startTimeMtdImage;
    int endTs = endTimeMtdImage == 0
        ? DateTime.now().millisecondsSinceEpoch
        : endTimeMtdImage;

    final String url =
        "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_mtd_img_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";

    //   "https://demo.espitek.com/api/plugins/telemetry/DEVICE/41cf0f00-936a-11ef-a41f-ffffca4e13b8/values/timeseries?keys=cloud_mtd_img_path&startTs=1735448401000&endTs=1735621201000&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    // "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_mtd_img_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    print("url fetchListImageMtdPlayback :" + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          // 'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cloudrecordsresponse = CloudMtd.fromJson(data);

        cloudrecordMtdimg.addAll(cloudrecordsresponse.cloudRecordPath);

        print(
            "fetchListImageMtdPlayback: ${response.body} = length: ${cloudrecords.length}");
        setLoading = false;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error fetchListImageMtdPlayback", "${data['message']}");

        print("fetchListImageMtdPlayback: ${response.statusCode}" +
            data['message']);
      }
      update();
    } catch (e) {
      print("Error fetchListImageMtdPlayback: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
    }
  }

  // download image mtd
  Future<void> downloadImageMtd(String linkImag, String idCamera) async {
    _requestPermissions();
    Dio dio = Dio();
    setisDownloading = true;
    print("linkvideo: $linkImag");
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getMtdImgFileUrl";
    print("url downloadVideo: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idCamera,
          "cloud_mtd_img_path": linkImag,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        print("presignedUrl: $presignedUrl");
// Đường dẫn lưu video
        try {
          final directory = await getTemporaryDirectory();
          // Tải video bằng Dio và theo dõi tiến trình
          final filename =
              'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final filePath = '${directory.path}/$filename';
          await dio.download(presignedUrl, filePath,
              onReceiveProgress: (received, total) {
            if (total != -1) {
              setProgressMtdImage =
                  received / total; // Cập nhật tiến trình tải xuống
              print("progress: " + _progressMtdImage.toString());
              update();
            }
          });
          final result = await ImageGallerySaverPlus.saveFile(filePath);
          print(result);

          // Mở video sau khi tải xong
          OpenFile.open(filePath);

          // Hiển thị thông báo thành công
          ToastComponent.showToast(message: "Download Video Success");
          setisDownloading = false;
        } catch (e) {
          //  debugPrint('Tải video thất bại: $e');
          ToastComponent.showToast(
              message: "Download Video Failed! Check Internet");
          setisDownloading = false;
        }
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar("Error downloadVideo", "${data['message']}");
        print("downloadVideo: ${response.statusCode}" + data['message']);
        ToastComponent.showToast(message: "Download Video Failed");
        setisDownloading = false;
      }
    } catch (e) {
      print("Error downloadVideo: $e");
      setisDownloading = false;
    }
  }

  Future<void> showCustomDateTimePickerMtdImge(BuildContext context) async {
    DateTime? startDateTime =
        await selectDateTime(context, "Select Start Time");
    if (startDateTime == null) return;

    setStartTimeMtdImage = startDateTime.millisecondsSinceEpoch;
    setSelectedDateStartMtdImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
    update();

    DateTime? endDateTime = await selectDateTime(context, "Select End Time");
    if (endDateTime == null) return;

    setEndTimeMtdImage = endDateTime.millisecondsSinceEpoch;
    setSelectedDateEndMtdImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);
    update();

    print("Datetime start: $startTime, end: $endTime");
    print("Datetime now: ${DateTime.now().millisecondsSinceEpoch}");

    // setStartTime = startTs;
    // setEndTime = endTs;
    update();
  }

  Future<DateTime?> selectDateTimeMtdImge(
      BuildContext context, String title) async {
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    // Pick Date
    selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: title,
    );

    if (selectedDate == null) return null;

    // Pick Time
    selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return null;

    // Combine Date and Time
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
      1, // Seconds default to 0
    );
  }

  void updateCurrentItem() {
    if (notificationController.textData == 'getHmdImgFileUrl') {
      print("Current TS: $currentTsHuman");

      int foundIndex = cloudrecordshmdimg
          .indexWhere((record) => record.ts == currentTsHuman);
      currentItemIndex.value = (foundIndex != -1) ? foundIndex : 0;

      print("currentItemIndex HMD: ${currentItemIndex.value}");
    }

    if (notificationController.textData == 'getMtdImgFileUrl') {
      print("Danh sách TS MTD: ${cloudrecordMtdimg.map((e) => e.ts)}");
      print("Current TS: $currentTsMotion");

      int foundIndex = cloudrecordMtdimg
          .indexWhere((record) => record.ts == currentTsMotion);
      currentItemIndexMotion.value = (foundIndex != -1) ? foundIndex : 0;

      print("currentItemIndex MTD: ${currentItemIndexMotion.value}");
    }
  }

  //=================================================== fecth all image play back
  Future<void> fetchListImageAllPlayback(String ipUUid) async {
    setLoading = true;
    cloudrecordMtdimg.clear();
    cloudrecordshmdimg.clear();
    if (loginControler.token.isEmpty ||
        loginControler.isTokenExpired(loginControler.token)) {
      await loginControler.refreshToken();
    }

    int startTs = startTimeAllImage == 0
        ? DateTime.now().millisecondsSinceEpoch - 86400000
        : startTimeAllImage;
    int endTs = endTimeAllImage == 0
        ? DateTime.now().millisecondsSinceEpoch
        : endTimeAllImage;

    final String url =
        "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_hmd_img_path,cloud_mtd_img_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";

    // "https://demo.espitek.com/api/plugins/telemetry/DEVICE/41cf0f00-936a-11ef-a41f-ffffca4e13b8/values/timeseries?keys=cloud_hmd_img_path,cloud_mtd_img_path&startTs=1736153000126&endTs=1736239400127&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    // "${Environment.appBaseUrl}/api/plugins/telemetry/DEVICE/$ipUUid/values/timeseries?keys=cloud_mtd_img_path&startTs=$startTs&endTs=$endTs&agg=NONE&orderBy=DESC&useStrictDataTypes=true";
    print("url fetchListImageMtdPlayback :" + url);
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          // 'Content-Type': 'application/json',
          'x-authorization': 'Bearer ${loginControler.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cloudrecordsresponse = CloudMtd.fromJson(data);

        cloudrecordMtdimg.addAll(cloudrecordsresponse.cloudRecordPath);

        final cloudrecordsresponsehmd = CloudHmd.fromJson(data);

        cloudrecordshmdimg.addAll(cloudrecordsresponsehmd.cloudRecordPath);
        print(
            "fetchListImageMtdPlayback: ${response.body} = length: ${cloudrecords.length}");
        update();
        updateCurrentItem();
        setLoading = false;
      } else if (response.statusCode == 401) {
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoading = false;
        final data = jsonDecode(response.body);
        Get.snackbar("Error fetchListImageMtdPlayback", "${data['message']}");

        print("fetchListImageMtdPlayback: ${response.statusCode}" +
            data['message']);
      }
      update();
    } catch (e) {
      print("Error fetchListImageMtdPlayback: $e");
      setLoading = false;
      update();
    } finally {
      setLoading = false;
    }
  }

  Future<void> showCustomDateTimePickerAllImge(BuildContext context) async {
    DateTime? startDateTime =
        await selectDateTime(context, "Select Start Time");
    if (startDateTime == null) return;

    setStartTimeAllImage = startDateTime.millisecondsSinceEpoch;
    setSelectedDateStartAllImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime);
    update();

    DateTime? endDateTime = await selectDateTime(context, "Select End Time");
    if (endDateTime == null) return;

    setEndTimeAllImage = endDateTime.millisecondsSinceEpoch;
    setSelectedDateEndAllImage =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime);
    update();

    print("Datetime start: $startTime, end: $endTime");
    print("Datetime now: ${DateTime.now().millisecondsSinceEpoch}");

    // setStartTime = startTs;
    // setEndTime = endTs;
    update();
  }

  Future<void> loadNextImage(String idcamera) async {
    // Tải ảnh tiếp theo
    if (notificationController.textData == "getHmdImgFileUrl") {
      if (currentItemIndex.value < cloudrecordshmdimg.length - 1) {
        currentItemIndex.value++; // Tăng chỉ mục lên 1
      } else {
        currentItemIndex.value =
            0; // Nếu là item cuối cùng, quay lại đầu danh sách
      }

      print("Current item index: $currentItemIndex"
          "cloudrecordshmdimg.length: ${cloudrecordshmdimg.length}");

      print("current index ${currentItemIndex.value}");
      htmimgPlaybackPreviewFile(
          cloudrecordshmdimg[currentItemIndex.value].value, idcamera);
    }
    if (notificationController.textData == "getMtdImgFileUrl") {
      if (currentItemIndexMotion.value < cloudrecordMtdimg.length - 1) {
        currentItemIndexMotion.value++; // Tăng chỉ mục lên 1
      } else {
        currentItemIndexMotion.value =
            0; // Nếu là item cuối cùng, quay lại đầu danh sách
      }
      mtdimgPlaybackPreviewFile(
          cloudrecordMtdimg[currentItemIndexMotion.value].value, idcamera);
    }

    // if (notificationController.textData == "getMtdImgFileUrl") {
    //   if (currentItemIndexMotion.value < cloudrecordMtdimg.length - 1) {
    //     currentItemIndexMotion.value++; // Tăng chỉ mục lên 1
    //   } else {
    //     currentItemIndexMotion.value =
    //         0; // Nếu là item cuối cùng, quay lại đầu danh sách
    //   }
    // }
  }

  Map<String, List<dynamic>> groupVideosByDate(List<dynamic> videos) {
    Map<String, List<dynamic>> groupedVideos = {};

    for (var video in videos) {
      // Chuyển đổi video.value thành ngày tháng năm giờ phút
      String formattedDate =
          convertTsToDatetime(video.ts); // Astssuming video.value is a string

      if (!groupedVideos.containsKey(_extractTimeDay(formattedDate))) {
        groupedVideos[_extractTimeDay(formattedDate)] = [];
      }
      // Thêm video vào nhóm ngày tương ứng
      groupedVideos[_extractTimeDay(formattedDate)]?.add(video);
    }

    return groupedVideos;
  }

  String convertTsToDatetime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String _extractTimeDay(String formattedDate) {
    List<String> dateParts = formattedDate.split(' ');
    if (dateParts.length > 1) {
      return dateParts[0];
    } else {
      return '';
    }
  }

  void loadPreviousImage(String idcamera) {
    if (notificationController.textData == "getHmdImgFileUrl") {
      if (currentItemIndex.value > 0) {
        currentItemIndex.value--; // Go to previous item
      } else {
        currentItemIndex.value = cloudrecordshmdimg.length -
            1; // If it's the first item, go to the last one
      }
    }
    if (notificationController.textData == "getMtdImgFileUrl") {
      if (currentItemIndexMotion.value > 0) {
        currentItemIndexMotion.value--; // Go to previous item
      } else {
        currentItemIndexMotion.value = cloudrecordMtdimg.length -
            1; // If it's the first item, go to the last one
      }
    }

    // Tải ảnh tiếp theo
    if (notificationController.textData == "getHmdImgFileUrl") {
      htmimgPlaybackPreviewFile(
          cloudrecordshmdimg[currentItemIndex.value].value, idcamera);
    }
    if (notificationController.textData == "getMtdImgFileUrl") {
      mtdimgPlaybackPreviewFile(
          cloudrecordMtdimg[currentItemIndex.value].value, idcamera);
    }
  }

  Future<void> htmimgPlaybackPreviewFile(
      String cloudPath, String idcamera) async {
    setLoadNextandPrevious = true;
    setPathHtmImage = cloudPath;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getHmdImgFileUrl";
    print("url htmimgPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idcamera,
          "cloud_hmd_img_path": cloudPath,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        setPathHtmImageUrl = presignedUrl;
        print("Link url htmimgPlaybackPreviewFile: $pathHtmImageUrl");
        // Khởi tạo controller và phát video
        setLoadNextandPrevious = false;
      } else if (response.statusCode == 401) {
        setLoadNextandPrevious = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadNextandPrevious = false;
        ToastComponent.showToast(message: "Load Image Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      setLoadNextandPrevious = false;
      print("Error htmimgPlaybackPreviewFile: $e");
    }
  }

  Future<void> mtdimgPlaybackPreviewFile(
      String cloudPath, String idcamera) async {
    setLoadNextandPrevious = true;
    setPathMtdImage = cloudPath;
    final String url =
        "${Environment.appBaseUrl}:${Environment.portDownload}/api/v1/getMtdImgFileUrl";
    print("url mtdimgPlaybackPreviewFile: " + url);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "jwt_token": "${loginControler.token}",
          "device_uuid": idcamera,
          "cloud_mtd_img_path": cloudPath,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String presignedUrl = data['presigned_url'];
        setPathHtmImageUrl = presignedUrl;
        print("Link url mtdimgPlaybackPreviewFile: $pathMtdImageUrl");
        // Khởi tạo controller và phát video
        setLoadNextandPrevious = false;
      } else if (response.statusCode == 401) {
        setLoadNextandPrevious = false;
        box.erase();
        Get.offAll(() => LoginPage(),
            transition: Transition.fade, duration: const Duration(seconds: 2));
      } else {
        setLoadNextandPrevious = false;
        ToastComponent.showToast(message: "Load Image Failed");
        throw Exception('Failed to fetch presigned URL');
      }
    } catch (e) {
      setLoadNextandPrevious = false;
      print("Error mtdimgPlaybackPreviewFile: $e");
    }
  }
}
