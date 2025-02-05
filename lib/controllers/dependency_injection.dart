import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/network_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
