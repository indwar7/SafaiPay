import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportProvider with ChangeNotifier {
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> loadUserReports(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _firestoreService.getUserReports(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _firestoreService.getAllReports();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReport(ReportModel report) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.createReport(report);
      _reports.insert(0, report);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
