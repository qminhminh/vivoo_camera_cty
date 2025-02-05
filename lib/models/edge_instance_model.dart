// ignore_for_file: unused_import

import 'dart:convert';

class EdgeModel {
  final List<EdgeData> data;
  final int totalPages;
  final int totalElements;
  final bool hasNext;

  EdgeModel({
    required this.data,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
  });

  factory EdgeModel.fromJson(Map<String, dynamic> json) {
    return EdgeModel(
      data: List<EdgeData>.from(json['data'].map((x) => EdgeData.fromJson(x))),
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

class EdgeData {
  final Map<String, dynamic> additionalInfo;
  final bool customerIsPublic;
  final String customerTitle;
  final EntityId id;
  final int createdTime;
  final EntityId tenantId;
  final EntityId customerId;
  final EntityId rootRuleChainId;
  final String name;
  final String type;
  final String label;
  final String routingKey;
  final String secret;

  EdgeData({
    required this.additionalInfo,
    required this.customerIsPublic,
    required this.customerTitle,
    required this.id,
    required this.createdTime,
    required this.tenantId,
    required this.customerId,
    required this.rootRuleChainId,
    required this.name,
    required this.type,
    required this.label,
    required this.routingKey,
    required this.secret,
  });

  factory EdgeData.fromJson(Map<String, dynamic> json) {
    return EdgeData(
      additionalInfo: json['additionalInfo'],
      customerIsPublic: json['customerIsPublic'],
      customerTitle: json['customerTitle'],
      id: EntityId.fromJson(json['id']),
      createdTime: json['createdTime'],
      tenantId: EntityId.fromJson(json['tenantId']),
      customerId: EntityId.fromJson(json['customerId']),
      rootRuleChainId: EntityId.fromJson(json['rootRuleChainId']),
      name: json['name'],
      type: json['type'],
      label: json['label'],
      routingKey: json['routingKey'],
      secret: json['secret'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'additionalInfo': additionalInfo,
      'customerIsPublic': customerIsPublic,
      'customerTitle': customerTitle,
      'id': id.toJson(),
      'createdTime': createdTime,
      'tenantId': tenantId.toJson(),
      'customerId': customerId.toJson(),
      'rootRuleChainId': rootRuleChainId.toJson(),
      'name': name,
      'type': type,
      'label': label,
      'routingKey': routingKey,
      'secret': secret,
    };
  }
}

class EntityId {
  final String id;
  final String entityType;

  EntityId({
    required this.id,
    required this.entityType,
  });

  factory EntityId.fromJson(Map<String, dynamic> json) {
    return EntityId(
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
