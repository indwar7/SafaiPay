import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory CollectorModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CollectorModel(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      ward: data['ward'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      totalCollections: data['totalCollections'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'ward': ward,
      'isAvailable': isAvailable,
      'totalCollections': totalCollections,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
