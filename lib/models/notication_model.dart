class NotificationResponse {
  final List<NotificationData> data;
  final int totalPages;
  final int totalElements;
  final bool hasNext;

  NotificationResponse({
    required this.data,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: (json['data'] as List?)
              ?.map((e) => NotificationData.fromJson(e))
              .toList() ??
          [],
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }
}

class NotificationData {
  final NotificationId requestId;
  final NotificationId recipientId;
  final String type;
  final String deliveryMethod;
  final String subject;
  final String text;
  final AdditionalConfig additionalConfig;
  final NotificationInfo info;
  final String status;
  final NotificationId id;
  final int createdTime;

  NotificationData({
    required this.requestId,
    required this.recipientId,
    required this.type,
    required this.deliveryMethod,
    required this.subject,
    required this.text,
    required this.additionalConfig,
    required this.info,
    required this.status,
    required this.id,
    required this.createdTime,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      requestId: NotificationId.fromJson(json['requestId']),
      recipientId: NotificationId.fromJson(json['recipientId']),
      type: json['type'] ?? '',
      deliveryMethod: json['deliveryMethod'] ?? '',
      subject: json['subject'] ?? '',
      text: json['text'] ?? '',
      additionalConfig: AdditionalConfig.fromJson(json['additionalConfig']),
      info: NotificationInfo.fromJson(json['info']),
      status: json['status'] ?? '',
      id: NotificationId.fromJson(json['id']),
      createdTime: json['createdTime'] ?? 0,
    );
  }
}

class NotificationId {
  final String entityType;
  final String id;

  NotificationId({
    required this.entityType,
    required this.id,
  });

  factory NotificationId.fromJson(Map<String, dynamic> json) {
    return NotificationId(
      entityType: json['entityType'] ?? '',
      id: json['id'] ?? '',
    );
  }
}

class AdditionalConfig {
  final IconConfig icon;
  final ActionButtonConfig actionButtonConfig;

  AdditionalConfig({
    required this.icon,
    required this.actionButtonConfig,
  });

  factory AdditionalConfig.fromJson(Map<String, dynamic> json) {
    return AdditionalConfig(
      icon: IconConfig.fromJson(json['icon']),
      actionButtonConfig:
          ActionButtonConfig.fromJson(json['actionButtonConfig']),
    );
  }
}

class IconConfig {
  final bool enabled;

  IconConfig({
    required this.enabled,
  });

  factory IconConfig.fromJson(Map<String, dynamic> json) {
    return IconConfig(
      enabled: json['enabled'] ?? false,
    );
  }
}

class ActionButtonConfig {
  final bool enabled;

  ActionButtonConfig({
    required this.enabled,
  });

  factory ActionButtonConfig.fromJson(Map<String, dynamic> json) {
    return ActionButtonConfig(
      enabled: json['enabled'] ?? false,
    );
  }
}

class NotificationInfo {
  final String type;
  final NotificationId msgOriginator;
  final NotificationId msgCustomerId;
  final String msgType;
  final Map<String, dynamic> msgMetadata;
  final Map<String, dynamic> msgData;
  final NotificationId stateEntityId;
  final NotificationId affectedCustomerId;
  final NotificationId? affectedUserId;
  final NotificationId? affectedTenantId;
  final NotificationId? dashboardId;

  NotificationInfo({
    required this.type,
    required this.msgOriginator,
    required this.msgCustomerId,
    required this.msgType,
    required this.msgMetadata,
    required this.msgData,
    required this.stateEntityId,
    required this.affectedCustomerId,
    this.affectedUserId,
    this.affectedTenantId,
    this.dashboardId,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> json) {
    return NotificationInfo(
      type: json['type'] ?? '',
      msgOriginator: NotificationId.fromJson(json['msgOriginator']),
      msgCustomerId: NotificationId.fromJson(json['msgCustomerId']),
      msgType: json['msgType'] ?? '',
      msgMetadata: Map<String, dynamic>.from(json['msgMetadata'] ?? {}),
      msgData: Map<String, dynamic>.from(json['msgData'] ?? {}),
      stateEntityId: NotificationId.fromJson(json['stateEntityId']),
      affectedCustomerId: NotificationId.fromJson(json['affectedCustomerId']),
      affectedUserId: json['affectedUserId'] != null
          ? NotificationId.fromJson(json['affectedUserId'])
          : null,
      affectedTenantId: json['affectedTenantId'] != null
          ? NotificationId.fromJson(json['affectedTenantId'])
          : null,
      dashboardId: json['dashboardId'] != null
          ? NotificationId.fromJson(json['dashboardId'])
          : null,
    );
  }
}
