class CloudMtdImgPath {
  final int ts;
  final String value;

  CloudMtdImgPath({
    required this.ts,
    required this.value,
  });

  // Factory method to create an instance from JSON
  factory CloudMtdImgPath.fromJson(Map<String, dynamic> json) {
    return CloudMtdImgPath(
      ts: json['ts'],
      value: json['value'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'ts': ts,
      'value': value,
    };
  }
}

class CloudMtd {
  final List<CloudMtdImgPath> cloudRecordPath;

  CloudMtd({
    required this.cloudRecordPath,
  });

  // Factory method to create an instance from JSON
  factory CloudMtd.fromJson(Map<String, dynamic> json) {
    var list = json['cloud_mtd_img_path'] as List;
    List<CloudMtdImgPath> cloudRecordPathList =
        list.map((i) => CloudMtdImgPath.fromJson(i)).toList();

    return CloudMtd(
      cloudRecordPath: cloudRecordPathList,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cloud_mtd_img_path': cloudRecordPath.map((e) => e.toJson()).toList(),
    };
  }
}
