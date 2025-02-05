class DeviceResponse {
  final List<Asset> data;
  final int totalPages;
  final int totalElements;
  final bool hasNext;

  DeviceResponse({
    required this.data,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(
      data: (json['data'] as List).map((e) => Asset.fromJson(e)).toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }
}

class Asset {
  final String entityType;
  final String id;
  final String name;
  final String? image;
  final String? defaultDashboardId;

  Asset({
    required this.entityType,
    required this.id,
    required this.name,
    this.image,
    this.defaultDashboardId,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      entityType: json['id']['entityType'],
      id: json['id']['id'],
      name: json['name'],
      image: json['image'], // có thể null, nên khai báo String?
      defaultDashboardId:
          json['defaultDashboardId'], // có thể null, nên khai báo String?
    );
  }
}
