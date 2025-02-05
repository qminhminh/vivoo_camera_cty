class CloudRecordPath {
  final int ts;
  final String value;

  CloudRecordPath({
    required this.ts,
    required this.value,
  });

  // Factory method to create an instance from JSON
  factory CloudRecordPath.fromJson(Map<String, dynamic> json) {
    return CloudRecordPath(
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

class CloudRecord {
  final List<CloudRecordPath> cloudRecordPath;

  CloudRecord({
    required this.cloudRecordPath,
  });

  // Factory method to create an instance from JSON
  factory CloudRecord.fromJson(Map<String, dynamic> json) {
    var list = json['cloud_record_path'] as List;
    List<CloudRecordPath> cloudRecordPathList =
        list.map((i) => CloudRecordPath.fromJson(i)).toList();

    return CloudRecord(
      cloudRecordPath: cloudRecordPathList,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cloud_record_path': cloudRecordPath.map((e) => e.toJson()).toList(),
    };
  }
}
