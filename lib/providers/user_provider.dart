import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _firestoreService.getUserById(uid);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateUser(user);
      _currentUser = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPoints(int points, String description) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      points: _currentUser!.points + points,
    );

    await updateUser(updatedUser);
    await _firestoreService.addTransaction(
      userId: _currentUser!.uid,
      type: 'earned',
      points: points,
      description: description,
    );
  }

  Future<void> redeemPoints(int points) async {
    if (_currentUser == null || _currentUser!.points < points) return;

    final updatedUser = _currentUser!.copyWith(
      points: _currentUser!.points - points,
      walletBalance: _currentUser!.walletBalance + points,
    );

    await updateUser(updatedUser);
    await _firestoreService.addTransaction(
      userId: _currentUser!.uid,
      type: 'redeemed',
      points: points,
      description: 'Redeemed to wallet',
    );
  }

  Future<void> dailyCheckIn() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    final lastCheckIn = _currentUser!.lastCheckIn;

    // Check if already checked in today
    if (lastCheckIn != null &&
        lastCheckIn.year == now.year &&
        lastCheckIn.month == now.month &&
        lastCheckIn.day == now.day) {
      return;
    }

    // Calculate streak
    int newStreak = 1;
    if (lastCheckIn != null) {
      final difference = now.difference(lastCheckIn).inDays;
      if (difference == 1) {
        newStreak = _currentUser!.streak + 1;
      }
    }

    final updatedUser = _currentUser!.copyWith(
      streak: newStreak,
      lastCheckIn: now,
    );

    await updateUser(updatedUser);
    await addPoints(2, 'Daily check-in');
  }

  void logout() {
    _currentUser = null;
    _authService.signOut();
    notifyListeners();
  }
}
