import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? name;
  final String? ward;
  final String? address;
  final int points;
  final int walletBalance;
  final int totalReports;
  final int totalBookings;
  final int streak;
  final DateTime createdAt;
  final DateTime? lastCheckIn;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.name,
    this.ward,
    this.address,
    this.points = 0,
    this.walletBalance = 0,
    this.totalReports = 0,
    this.totalBookings = 0,
    this.streak = 0,
    required this.createdAt,
    this.lastCheckIn,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      phoneNumber: data['phoneNumber'] ?? '',
      name: data['name'],
      ward: data['ward'],
      address: data['address'],
      points: data['points'] ?? 0,
      walletBalance: data['walletBalance'] ?? 0,
      totalReports: data['totalReports'] ?? 0,
      totalBookings: data['totalBookings'] ?? 0,
      streak: data['streak'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastCheckIn: data['lastCheckIn'] != null
          ? (data['lastCheckIn'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'ward': ward,
      'address': address,
      'points': points,
      'walletBalance': walletBalance,
      'totalReports': totalReports,
      'totalBookings': totalBookings,
      'streak': streak,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastCheckIn':
          lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
    };
  }

  UserModel copyWith({
    String? name,
    String? ward,
    String? address,
    int? points,
    int? walletBalance,
    int? totalReports,
    int? totalBookings,
    int? streak,
    DateTime? lastCheckIn,
  }) {
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      name: name ?? this.name,
      ward: ward ?? this.ward,
      address: address ?? this.address,
      points: points ?? this.points,
      walletBalance: walletBalance ?? this.walletBalance,
      totalReports: totalReports ?? this.totalReports,
      totalBookings: totalBookings ?? this.totalBookings,
      streak: streak ?? this.streak,
      createdAt: createdAt,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
    );
  }
}
