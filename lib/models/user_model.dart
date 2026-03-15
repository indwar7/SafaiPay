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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] ?? json['uid'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      name: json['name'],
      ward: json['ward'],
      address: json['address'],
      points: json['points'] ?? 0,
      walletBalance: (json['wallet_balance'] ?? json['walletBalance'] ?? 0) is double
          ? (json['wallet_balance'] ?? json['walletBalance'] ?? 0).toInt()
          : json['wallet_balance'] ?? json['walletBalance'] ?? 0,
      totalReports: json['total_reports'] ?? json['totalReports'] ?? 0,
      totalBookings: json['total_bookings'] ?? json['totalBookings'] ?? 0,
      streak: json['streak'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastCheckIn: json['last_check_in'] != null
          ? DateTime.parse(json['last_check_in'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ward': ward,
      'address': address,
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
