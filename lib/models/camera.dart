class Camera {
  final String id;
  final String entityType;
  final int createdTime;
  final bool gateway;
  final bool overwriteActivityTime;
  final String description;
  final String tenantId;
  final String customerId;
  final String name;
  final String type;
  final String label;
  final String deviceProfileId;
  final String customerTitle;
  final bool customerIsPublic;
  final String deviceProfileName;
  final bool active;

  Camera({
    required this.id,
    required this.entityType,
    required this.createdTime,
    required this.gateway,
    required this.overwriteActivityTime,
    required this.description,
    required this.tenantId,
    required this.customerId,
    required this.name,
    required this.type,
    required this.label,
    required this.deviceProfileId,
    required this.customerTitle,
    required this.customerIsPublic,
    required this.deviceProfileName,
    required this.active,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id']['id'],
      entityType: json['id']['entityType'],
      createdTime: json['createdTime'],
      gateway: json['additionalInfo']['gateway'],
      overwriteActivityTime: json['additionalInfo']['overwriteActivityTime'],
      description: json['additionalInfo']['description'],
      tenantId: json['tenantId']['id'],
      customerId: json['customerId']['id'],
      name: json['name'],
      type: json['type'],
      label: json['label'],
      deviceProfileId: json['deviceProfileId']['id'],
      customerTitle: json['customerTitle'],
      customerIsPublic: json['customerIsPublic'],
      deviceProfileName: json['deviceProfileName'],
      active: json['active'],
    );
  }
}

class CameraResponse {
  final List<Camera> cameras;
  final int totalPages;
  final int totalElements;
  final bool hasNext;

  CameraResponse({
    required this.cameras,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
  });

  factory CameraResponse.fromJson(Map<String, dynamic> json) {
    return CameraResponse(
      cameras: (json['data'] as List).map((e) => Camera.fromJson(e)).toList(),
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      hasNext: json['hasNext'],
    );
  }
}
