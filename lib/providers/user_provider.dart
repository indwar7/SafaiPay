import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateUser({String? name, String? ward, String? address}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateProfile(
        name: name,
        ward: ward,
        address: address,
      );
      if (updated != null) {
        _currentUser = updated;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendFcmToken(String fcmToken) async {
    try {
      await _apiService.updateProfile(fcmToken: fcmToken);
    } catch (e) {
      debugPrint('Failed to send FCM token: $e');
    }
  }

  Future<void> redeemPoints(int points) async {
    if (_currentUser == null || _currentUser!.points < points) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.redeemPoints(points);
      // Reload profile to get updated balances
      _currentUser = await _apiService.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> dailyCheckIn() async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.dailyCheckIn();
      if (updated != null) {
        _currentUser = updated;
      } else {
        // Reload profile to reflect check-in
        _currentUser = await _apiService.getProfile();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
