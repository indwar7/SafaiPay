class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String issueType;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String? imageUrl;
  final String status; // pending, assigned, resolved
  final int pointsEarned;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.issueType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrl,
    this.status = 'pending',
    this.pointsEarned = 5,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      issueType: json['issue_type'] ?? json['issueType'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      status: json['status'] ?? 'pending',
      pointsEarned: json['points_earned'] ?? json['pointsEarned'] ?? 5,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
