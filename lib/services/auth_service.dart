import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/storage.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final SecureStorageHelper _storage = SecureStorageHelper();

  Future<void> sendOtp({
    required String phone,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'phone_number': phone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess();
      } else {
        onError(response.data['message'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        onError('Too many attempts. Please try again later.');
      } else {
        onError(e.response?.data?['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<UserModel?> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'phone_number': phone,
        'otp': otp,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final token = data['token'] as String;
        await _storage.saveToken(token);

        if (data['user'] != null) {
          return UserModel.fromJson(data['user']);
        }
      }
      return null;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['message'] ?? 'OTP verification failed');
    }
  }

  Future<void> signOut() async {
    await _storage.clearToken();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }
}
