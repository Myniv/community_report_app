import 'dart:convert';
import 'package:community_report_app/models/discussion.dart';
import 'package:http/http.dart' as http;

class DiscussionService {
  static const String baseUrl = "http://10.0.2.2:5088/Discussion";

  Future<List<Discussion>> getDiscussions({String? userId}) async {
    try {
      final queryParams = {if (userId != null) 'userId': userId};

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Discussion.fromMap(e)).toList();
      } else {
        throw Exception("Failed to load disscussions");
      }
    } catch (e) {
      print("Error fetching discussions: $e");
      throw Exception("Failed to load discussions");
    }
  }

  Future<Discussion> createDiscussion(Discussion discussion) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(discussion.toMap()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Discussion.fromMap(data);
      } else {
        throw Exception("Failed to create discussion");
      }
    } catch (e) {
      print("Error creating discussion: $e");
      rethrow;
    }
  }

  Future<Discussion?> getDiscussionbyId(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/discussion/$id"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Discussion.fromMap(data);
    } else {
      throw Exception("Failed to load discussion");
    }
  }

  Future<Discussion?> getDiscussionbyIdWithCommunityPost(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/discussion/$id"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return Discussion.fromMapWithCommunityPost(data);
    } else {
      throw Exception("Failed to load discussion");
    }
  }

  Future<void> updateDiscussion(Discussion discussion, int discussionId) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$discussionId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(discussion.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to update discussion");
      }
    } catch (e) {
      print("Error updating discussion: $e");
      throw Exception("Failed to update discussion");
    }
  }

  Future<void> deleteDiscussion(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode != 200) {
        throw Exception("Failed to delete discussion");
      }
    } catch (e) {
      print("Error deleting discussion: $e");
      throw Exception("Failed to delete discussion");
    }
  }
}
