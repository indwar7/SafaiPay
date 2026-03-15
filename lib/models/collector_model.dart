class CollectorModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String ward;
  final bool isAvailable;
  final int totalCollections;
  final DateTime createdAt;

  CollectorModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.ward,
    this.isAvailable = true,
    this.totalCollections = 0,
    required this.createdAt,
  });

  factory CollectorModel.fromJson(Map<String, dynamic> json) {
    return CollectorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      ward: json['ward'] ?? '',
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
      totalCollections:
          json['total_collections'] ?? json['totalCollections'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
