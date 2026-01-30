import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/report_model.dart';
import '../models/transaction_model.dart';
import '../models/collector_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc =
          await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Booking operations
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .add(booking.toMap());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(bookingId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Report operations
  Future<void> createReport(ReportModel report) async {
    try {
      await _firestore
          .collection(AppConstants.reportsCollection)
          .add(report.toMap());
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  Future<List<ReportModel>> getUserReports(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get reports: $e');
    }
  }

  Future<List<ReportModel>> getAllReports() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.reportsCollection)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get all reports: $e');
    }
  }

  // Transaction operations
  Future<void> addTransaction({
    required String userId,
    required String type,
    required int points,
    required String description,
  }) async {
    try {
      final transaction = TransactionModel(
        id: '',
        userId: userId,
        type: type,
        points: points,
        description: description,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.transactionsCollection)
          .add(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  // Collector operations
  Future<List<CollectorModel>> getAvailableCollectors(String ward) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.collectorsCollection)
          .where('ward', isEqualTo: ward)
          .where('isAvailable', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => CollectorModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get collectors: $e');
    }
  }

  // Leaderboard
  Future<List<UserModel>> getLeaderboard({String? ward, int limit = 10}) async {
    try {
      Query query = _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('points', descending: true)
          .limit(limit);

      if (ward != null) {
        query = query.where('ward', isEqualTo: ward);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }
}
