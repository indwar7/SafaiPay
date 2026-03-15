import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> loadUserBookings({String? status, int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _apiService.getBookings(status: status, page: page);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBooking({
    required String wasteType,
    required DateTime bookingDate,
    required String timeSlot,
    required String address,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final booking = await _apiService.createBooking(
        wasteType: wasteType,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      if (booking != null) {
        _bookings.insert(0, booking);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _apiService.cancelBooking(bookingId);
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
