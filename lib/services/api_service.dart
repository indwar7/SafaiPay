import 'dart:io';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/report_model.dart';
import '../models/transaction_model.dart';
import '../models/badge_model.dart';

class ApiService {
  final Dio _dio = ApiClient().dio;

  // ─── User / Profile ───

  Future<UserModel?> getProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      if (response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get profile');
    }
  }

  Future<UserModel?> updateProfile({
    String? name,
    String? ward,
    String? address,
    String? fcmToken,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (ward != null) data['ward'] = ward;
      if (address != null) data['address'] = address;
      if (fcmToken != null) data['fcm_token'] = fcmToken;

      final response = await _dio.patch('/user/profile', data: data);
      if (response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to update profile');
    }
  }

  Future<UserModel?> dailyCheckIn() async {
    try {
      final response = await _dio.post('/user/checkin');
      if (response.data['data'] != null) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Check-in failed');
    }
  }

  // ─── Reports ───

  Future<ReportModel?> createReport({
    required String issueType,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    File? image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'issue_type': issueType,
        'description': description,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
      });

      final response = await _dio.post('/reports',
          data: formData,
          options: Options(contentType: 'multipart/form-data'));

      if (response.data['data'] != null) {
        return ReportModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to create report');
    }
  }

  Future<List<ReportModel>> getReports({
    String? status,
    String? issueType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) params['status'] = status;
      if (issueType != null) params['issue_type'] = issueType;

      final response =
          await _dio.get('/reports', queryParameters: params);

      final data = response.data['data'];
      if (data != null && data['reports'] != null) {
        return (data['reports'] as List)
            .map((r) => ReportModel.fromJson(r))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get reports');
    }
  }

  Future<ReportModel?> getReportById(String id) async {
    try {
      final response = await _dio.get('/reports/$id');
      if (response.data['data'] != null) {
        return ReportModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get report');
    }
  }

  // ─── Bookings ───

  Future<BookingModel?> createBooking({
    required String wasteType,
    required DateTime bookingDate,
    required String timeSlot,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.post('/bookings', data: {
        'waste_type': wasteType,
        'booking_date': bookingDate.toIso8601String(),
        'time_slot': timeSlot,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      });

      if (response.data['data'] != null) {
        return BookingModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to create booking');
    }
  }

  Future<List<BookingModel>> getBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) params['status'] = status;

      final response =
          await _dio.get('/bookings', queryParameters: params);

      final data = response.data['data'];
      if (data != null && data['bookings'] != null) {
        return (data['bookings'] as List)
            .map((b) => BookingModel.fromJson(b))
            .toList();
      }
      // Handle case where data is a list directly
      if (data is List) {
        return data.map((b) => BookingModel.fromJson(b)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get bookings');
    }
  }

  Future<BookingModel?> getBookingById(String id) async {
    try {
      final response = await _dio.get('/bookings/$id');
      if (response.data['data'] != null) {
        return BookingModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get booking');
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _dio.patch('/bookings/$id/status', data: {
        'status': 'cancelled',
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to cancel booking');
    }
  }

  // ─── Wallet ───

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dio.get('/wallet');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get wallet');
    }
  }

  Future<void> redeemPoints(int points) async {
    try {
      await _dio.post('/wallet/redeem', data: {
        'points': points,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to redeem points');
    }
  }

  Future<void> withdraw(double amount) async {
    try {
      await _dio.post('/wallet/withdraw', data: {
        'amount': amount,
      });
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to withdraw');
    }
  }

  Future<List<TransactionModel>> getTransactions({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null) params['type'] = type;

      final response =
          await _dio.get('/wallet/transactions', queryParameters: params);

      final data = response.data['data'];
      if (data is List) {
        return data.map((t) => TransactionModel.fromJson(t)).toList();
      }
      if (data != null && data['transactions'] != null) {
        return (data['transactions'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get transactions');
    }
  }

  // ─── Leaderboard ───

  Future<List<UserModel>> getLeaderboard({
    String? ward,
    int limit = 100,
  }) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (ward != null) params['ward'] = ward;

      final response =
          await _dio.get('/leaderboard', queryParameters: params);

      final data = response.data['data'];
      if (data is List) {
        return data.map((u) => UserModel.fromJson(u)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get leaderboard');
    }
  }

  Future<Map<String, dynamic>> getMyRank({String? ward}) async {
    try {
      final params = <String, dynamic>{};
      if (ward != null) params['ward'] = ward;

      final response =
          await _dio.get('/leaderboard/me', queryParameters: params);

      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get rank');
    }
  }

  // ─── Badges ───

  Future<List<UserBadgeModel>> getUserBadges() async {
    try {
      final response = await _dio.get('/badges/user');

      final data = response.data['data'];
      if (data is List) {
        return data.map((b) => UserBadgeModel.fromJson(b)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'Failed to get badges');
    }
  }
}
