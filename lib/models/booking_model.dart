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
  final double? latitude;
  final double? longitude;
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
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      wasteType: json['waste_type'] ?? json['wasteType'] ?? '',
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : DateTime.now(),
      timeSlot: json['time_slot'] ?? json['timeSlot'] ?? '',
      status: json['status'] ?? 'pending',
      collectorId: json['collector_id'] ?? json['collectorId'],
      collectorName: json['collector_name'] ?? json['collectorName'],
      weight: json['weight']?.toDouble(),
      pointsEarned: json['points_earned'] ?? json['pointsEarned'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waste_type': wasteType,
      'booking_date': bookingDate.toIso8601String(),
      'time_slot': timeSlot,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
