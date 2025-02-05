// ignore_for_file: unnecessary_import, prefer_const_constructors, avoid_print, unused_element, unrelated_type_equality_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vivoo_camera_cty/controllers/assets_controller.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  String? _textSearched;
  bool isReadSelected = true;
  bool isAllSelected = true; // Trạng thái cho "All"
  bool isDefaultSelected = false; // Trạng thái cho "Default"
  bool isTbServiceQueueSelected = false; // Trạng thái cho "TbServiceQueue"
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final assetController = Get.put(AssetsController());

    Future.delayed(Duration(seconds: 1), () {
      assetController.fetchAllAssetsSearch(page: 0);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          assetController.currentPage.value + 1 <
              assetController.totalPages.value) {
        assetController.fetchTextSearchAssetsSearch(
          pageSize: assetController.currentPage.value + 1,
          textsearch: _textSearched,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetController = Get.put(AssetsController());
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
            "Assets",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dropdown to select items per page
            // Container(
            //   padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     border: Border(
            //       top: BorderSide(color: Colors.grey.withOpacity(0.2)),
            //     ),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: [
            //           Text(
            //             "Items: ",
            //             style: TextStyle(fontSize: 14.sp, color: Colors.black),
            //           ),
            //           SizedBox(width: 1.w),
            //           Obx(
            //             () => DropdownButton<int>(
            //               value: assetController.itemsPerPage.value,
            //               items: [10, 20, 30]
            //                   .map((e) => DropdownMenuItem(
            //                         value: e,
            //                         child: Text("$e"),
            //                       ))
            //                   .toList(),
            //               onChanged: (value) {
            //                 if (value != null) {
            //                   assetController.itemsPerPage.value = value;
            //                   if (_textSearched == null) {
            //                     assetController.fetchAllAssetsSearch(
            //                       pageSize: value,
            //                     );
            //                   } else {
            //                     assetController.fetchTextSearchAssetsSearch(
            //                       pageSize: value,
            //                       textsearch: _textSearched,
            //                     );
            //                   }
            //                 }
            //               },
            //             ),
            //           ),
            //         ],
            //       ),
            //       Obx(
            //         () => Row(
            //           children: [
            //             Text(
            //               "${assetController.currentPage.value + 1} - ${assetController.totalItems.value} of ${assetController.totalItems.value}",
            //               style:
            //                   TextStyle(fontSize: 14.sp, color: Colors.black),
            //             ),
            //             IconButton(
            //               icon: const Icon(Icons.chevron_left),
            //               onPressed: assetController.currentPage.value > 0
            //                   ? () => {
            //                         if (_textSearched == null)
            //                           {
            //                             assetController.fetchAllAssetsSearch(
            //                               page: assetController
            //                                       .currentPage.value -
            //                                   1,
            //                             )
            //                           }
            //                         else
            //                           {
            //                             assetController
            //                                 .fetchTextSearchAssetsSearch(
            //                               page: assetController
            //                                       .currentPage.value -
            //                                   1,
            //                               textsearch: _textSearched,
            //                             )
            //                           }
            //                       }
            //                   : null,
            //             ),
            //             IconButton(
            //               icon: const Icon(Icons.chevron_right),
            //               onPressed: assetController.currentPage.value + 1 <
            //                       assetController.totalPages.value
            //                   ? () => {
            //                         if (_textSearched == null)
            //                           {
            //                             assetController.fetchAllAssetsSearch(
            //                               page: assetController
            //                                       .currentPage.value +
            //                                   1,
            //                             )
            //                           }
            //                         else
            //                           {
            //                             assetController
            //                                 .fetchTextSearchAssetsSearch(
            //                               page: assetController
            //                                       .currentPage.value +
            //                                   1,
            //                               textsearch: _textSearched,
            //                             )
            //                           }
            //                       }
            //                   : null,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 10.h),
            // Dropdown to select asset profile
            ToggleButtons(
              borderRadius: BorderRadius.circular(20),
              isSelected: [
                isAllSelected,
                isDefaultSelected,
                isTbServiceQueueSelected
              ], // Thêm mục thứ ba
              selectedColor: Colors.white,
              fillColor: Colors.black,
              color: Colors.black,
              borderWidth: 2,
              borderColor: Colors.grey.shade300,
              selectedBorderColor: Colors.black,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text("All"),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text("Default"),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text("TbServiceQueue"),
                ),
              ],
              onPressed: (index) {
                setState(() {
                  if (index == 0) {
                    isAllSelected = true;
                    isDefaultSelected = false;
                    isTbServiceQueueSelected = false;
                    setState(() {
                      _textSearched = "All";
                    });
                    assetController.fetchAllAssetsSearch(
                      pageSize: assetController.itemsPerPage.value,
                    );
                    // Xử lý khi chọn "All"
                  } else if (index == 1) {
                    isAllSelected = false;
                    isDefaultSelected = true;
                    isTbServiceQueueSelected = false;
                    setState(() {
                      _textSearched = "Default";
                    });
                    assetController.fetchTextSearchAssetsSearch(
                      pageSize: assetController.itemsPerPage.value,
                      textsearch: _textSearched,
                    );
                    // Xử lý khi chọn "Default"
                  } else if (index == 2) {
                    // Xử lý khi chọn "TbServiceQueue"
                    isAllSelected = false;
                    isDefaultSelected = false;
                    isTbServiceQueueSelected = true;
                    setState(() {
                      _textSearched = "TbServiceQueue";
                    });

                    assetController.fetchTextSearchAssetsSearch(
                      pageSize: assetController.itemsPerPage.value,
                      textsearch: _textSearched,
                    );
                  }
                });
              },
            ),

            SizedBox(height: 10.h),
            Obx(() {
              if (assetController.isLoading) {
                return Center(
                  child: Text('Loading...'),
                );
              }

              if (assetController.assets.isEmpty) {
                return Center(
                  child: Text(
                    'No assets found.',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap:
                    true, // Make the list view take only as much space as needed
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling for inner scroll views
                itemCount: assetController.assets.length,
                itemBuilder: (context, index) {
                  final asset = assetController.assets[index];
                  return Card(
                    color: Colors.white,
                    margin:
                        EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                    elevation: 3,
                    child: ListTile(
                      tileColor: Colors.white,
                      leading: asset.image != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(asset.image!),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.image_not_supported),
                            ),
                      title: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          asset.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          "ID: ${asset.id}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      onTap: () {
                        //Get.snackbar('Asset Selected', asset.name);
                      },
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
