import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/api_service.dart';

class ReportProvider with ChangeNotifier {
  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();

  Future<void> loadUserReports({String? status, int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _apiService.getReports(status: status, page: page);
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
      _reports = await _apiService.getReports(limit: 100);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createReport({
    required String issueType,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    File? image,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final report = await _apiService.createReport(
        issueType: issueType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        address: address,
        image: image,
      );
      if (report != null) {
        _reports.insert(0, report);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
