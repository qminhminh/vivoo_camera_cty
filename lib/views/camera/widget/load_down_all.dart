// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/cloud_record_path_controller.dart';
import 'package:vivoo_camera_cty/views/camera/widget/dropdown_date_all.dart';

class LoadDownAll extends StatefulWidget {
  const LoadDownAll({super.key, required this.idcamera});
  final String idcamera;

  @override
  State<LoadDownAll> createState() => _LoadDownAllState();
}

class _LoadDownAllState extends State<LoadDownAll> {
  @override
  Widget build(BuildContext context) {
    final cloudRecordController = Get.put(CloudRecordPathController());
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                return cloudRecordController.isDownloading
                    ? Row(
                        children: [
                          SizedBox(
                            width: 40.w,
                            child: LinearProgressIndicator(
                              value: cloudRecordController.progressHtmImage,
                              backgroundColor: Colors.grey,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          SizedBox(width: 6.w),
                          SizedBox(
                            width: 170.w,
                            child: Text(
                              '${(cloudRecordController.progressMtdImage * 100).toStringAsFixed(2)}% Downloading...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 17.sp),
                            ),
                          ),
                        ],
                      )
                    : Container();
              }),
              if (!cloudRecordController.isDownloading)
                Expanded(
                  child: Container(
                    width: double
                        .infinity, // Bây giờ an toàn vì Expanded giới hạn kích thước
                    child: DropdownDateAll(
                      idcamera: widget.idcamera,
                    ),
                  ),
                ),
              SizedBox(width: 10.w),
              if (!cloudRecordController.isDownloading) Text("| Select Date:"),
              if (!cloudRecordController.isDownloading)
                IconButton(
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    size: 30.sp,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    await cloudRecordController
                        .showCustomDateTimePickerAllImge(context);

                    cloudRecordController
                        .fetchListImageAllPlayback(widget.idcamera);
                  },
                ),
            ],
          ),
          if (!cloudRecordController.isDownloading &&
              cloudRecordController.selectedDateStartAllImage != null &&
              cloudRecordController.selectedDateStartAllImage.isNotEmpty)
            Text(
                "  Start Date: ${cloudRecordController.selectedDateStartAllImage}"),
          if (!cloudRecordController.isDownloading &&
              cloudRecordController.selectedDateStartAllImage.isNotEmpty)
            Text(
                "  End Date: ${cloudRecordController.selectedDateEndAllImage}"),
        ],
      ),
    );
  }
}
