class CloudHmdImgPath {
  final int ts;
  final String value;

  CloudHmdImgPath({
    required this.ts,
    required this.value,
  });

  // Factory method to create an instance from JSON
  factory CloudHmdImgPath.fromJson(Map<String, dynamic> json) {
    return CloudHmdImgPath(
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

class CloudHmd {
  final List<CloudHmdImgPath> cloudRecordPath;

  CloudHmd({
    required this.cloudRecordPath,
  });

  // Factory method to create an instance from JSON
  factory CloudHmd.fromJson(Map<String, dynamic> json) {
    var list = json['cloud_hmd_img_path'] as List;
    List<CloudHmdImgPath> cloudRecordPathList =
        list.map((i) => CloudHmdImgPath.fromJson(i)).toList();

    return CloudHmd(
      cloudRecordPath: cloudRecordPathList,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cloud_hmd_img_path': cloudRecordPath.map((e) => e.toJson()).toList(),
    };
  }
}
