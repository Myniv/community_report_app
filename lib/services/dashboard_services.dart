import 'dart:convert';

import 'package:community_report_app/models/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class DashboardServices {
  static const String baseUrl = "http://10.0.2.2:5088/Dashboard";

  Future<Dashboard> getDashboardDataByAdmin() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Dashboard.fromMap(data);
      } else {
        throw Exception("Failed to load dashboard data");
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      rethrow;
    }
  }
}
