import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String phoneNumber;
  final String address;
  final String wasteType;
  final DateTime bookingDate;
  final String timeSlot;
  final String status; // pending, assigned, completed, cancelled
  final String? collectorId;
  final String? collectorName;
  final double? weight;
  final int? pointsEarned;
  final String? imageUrl;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.address,
    required this.wasteType,
    required this.bookingDate,
    required this.timeSlot,
    this.status = 'pending',
    this.collectorId,
    this.collectorName,
    this.weight,
    this.pointsEarned,
    this.imageUrl,
    required this.createdAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      wasteType: data['wasteType'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      status: data['status'] ?? 'pending',
      collectorId: data['collectorId'],
      collectorName: data['collectorName'],
      weight: data['weight']?.toDouble(),
      pointsEarned: data['pointsEarned'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'address': address,
      'wasteType': wasteType,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'timeSlot': timeSlot,
      'status': status,
      'collectorId': collectorId,
      'collectorName': collectorName,
      'weight': weight,
      'pointsEarned': pointsEarned,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
