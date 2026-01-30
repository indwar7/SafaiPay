import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String status; // pending, resolved, rejected
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

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      issueType: data['issueType'] ?? '',
      description: data['description'] ?? '',
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'],
      status: data['status'] ?? 'pending',
      pointsEarned: data['pointsEarned'] ?? 5,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'issueType': issueType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'imageUrl': imageUrl,
      'status': status,
      'pointsEarned': pointsEarned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
