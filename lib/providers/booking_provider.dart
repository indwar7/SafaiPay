import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _firestoreService.getUserBookings(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.createBooking(booking);
      _bookings.insert(0, booking);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestoreService.updateBookingStatus(bookingId, 'cancelled');
      _bookings = _bookings
          .map((b) => b.id == bookingId
              ? BookingModel(
                  id: b.id,
                  userId: b.userId,
                  userName: b.userName,
                  phoneNumber: b.phoneNumber,
                  address: b.address,
                  wasteType: b.wasteType,
                  bookingDate: b.bookingDate,
                  timeSlot: b.timeSlot,
                  status: 'cancelled',
                  createdAt: b.createdAt,
                )
              : b)
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
