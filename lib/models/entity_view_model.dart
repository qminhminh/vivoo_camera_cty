class ResponseModel {
  final List<DataView> data;
  final int totalPages;
  final int totalElements;
  final bool hasNext;

  ResponseModel({
    required this.data,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      data: List<DataView>.from(json['data'].map((x) => DataView.fromJson(x))),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      hasNext: json['hasNext'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
      'totalPages': totalPages,
      'totalElements': totalElements,
      'hasNext': hasNext,
    };
  }
}

class DataView {
  final Id id;
  final int createdTime;
  final Id tenantId;
  final Id customerId;
  final String name;
  final String type;
  final Id entityId;
  final Keys keys;
  final int startTimeMs;
  final int endTimeMs;
  final Map<String, dynamic> additionalInfo;
  final String customerTitle;
  final bool customerIsPublic;

  DataView({
    required this.id,
    required this.createdTime,
    required this.tenantId,
    required this.customerId,
    required this.name,
    required this.type,
    required this.entityId,
    required this.keys,
    required this.startTimeMs,
    required this.endTimeMs,
    required this.additionalInfo,
    required this.customerTitle,
    required this.customerIsPublic,
  });

  factory DataView.fromJson(Map<String, dynamic> json) {
    return DataView(
      id: Id.fromJson(json['id']),
      createdTime: json['createdTime'],
      tenantId: Id.fromJson(json['tenantId']),
      customerId: Id.fromJson(json['customerId']),
      name: json['name'],
      type: json['type'],
      entityId: Id.fromJson(json['entityId']),
      keys: Keys.fromJson(json['keys']),
      startTimeMs: json['startTimeMs'],
      endTimeMs: json['endTimeMs'],
      additionalInfo: json['additionalInfo'] ?? {},
      customerTitle: json['customerTitle'],
      customerIsPublic: json['customerIsPublic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toJson(),
      'createdTime': createdTime,
      'tenantId': tenantId.toJson(),
      'customerId': customerId.toJson(),
      'name': name,
      'type': type,
      'entityId': entityId.toJson(),
      'keys': keys.toJson(),
      'startTimeMs': startTimeMs,
      'endTimeMs': endTimeMs,
      'additionalInfo': additionalInfo,
      'customerTitle': customerTitle,
      'customerIsPublic': customerIsPublic,
    };
  }
}

class Id {
  final String id;
  final String entityType;

  Id({
    required this.id,
    required this.entityType,
  });

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(
      id: json['id'],
      entityType: json['entityType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
    };
  }
}

class Keys {
  final String timeseries;
  final Attributes attributes;

  Keys({
    required this.timeseries,
    required this.attributes,
  });

  factory Keys.fromJson(Map<String, dynamic> json) {
    return Keys(
      timeseries: json['timeseries'],
      attributes: Attributes.fromJson(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeseries': timeseries,
      'attributes': attributes.toJson(),
    };
  }
}

class Attributes {
  final String cs;
  final String sh;
  final String ss;

  Attributes({
    required this.cs,
    required this.sh,
    required this.ss,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      cs: json['cs'],
      sh: json['sh'],
      ss: json['ss'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cs': cs,
      'sh': sh,
      'ss': ss,
    };
  }
}
