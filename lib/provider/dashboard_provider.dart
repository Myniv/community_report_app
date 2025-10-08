import 'package:community_report_app/models/dashboard.dart';
import 'package:community_report_app/services/dashboard_services.dart';
import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier{
  Dashboard? _dashboardData;
  Dashboard? get dashboardData => _dashboardData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final DashboardServices _dashboardServices = DashboardServices();

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _dashboardData = await _dashboardServices.getDashboardDataByAdmin();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}