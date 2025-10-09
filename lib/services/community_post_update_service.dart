import 'dart:convert';
import 'dart:io';
import 'package:community_report_app/models/community_post_update.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityPostUpdateService {
  static const String baseUrl = "http://10.0.2.2:5088/CommunityPostUpdate";
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadPhoto(int postId, File file) async {
    try {
      final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ext = path.extension(file.path);
      final fileName = "${postId}_$timeStamp$ext";

      await _supabase.storage
          .from('post_community_app_update')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage
          .from('post_community_app_update')
          .getPublicUrl(fileName);

      // await profiles.doc(uid).update({'profilePicturePath': url});

      return url;
    } catch (e) {
      print("Error in upload community update photo: $e");
      rethrow;
    }
  }

  Future<CommunityPostUpdate> createCommunityPostUpdate(
    CommunityPostUpdate communityPostUpdate,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(communityPostUpdate.toMap()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommunityPostUpdate.fromMap(data);
      } else {
        throw Exception("Failed to create community post update");
      }
    } catch (e) {
      print("Error creating community post update: $e");
      rethrow;
    }
  }

  Future<void> deleteCommunityPostUpdate(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode != 200) {
        throw Exception("Failed to delete community post update");
      }
    } catch (e) {
      print("Error deleting community post update: $e");
      throw Exception("Failed to delete community post update");
    }
  }

  // Future<Discussion?> getDiscussionbyId(int id) async {
  //   final response = await http.get(Uri.parse("$baseUrl/discussion/$id"));
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return Discussion.fromMap(data);
  //   } else {
  //     throw Exception("Failed to load discussion");
  //   }
  // }

  // Future<void> updateDiscussion(Discussion discussion, int discussionId) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse("$baseUrl/$discussionId"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(discussion.toMap()),
  //     );
  //     if (response.statusCode != 200) {
  //       throw Exception("Failed to update discussion");
  //     }
  //   } catch (e) {
  //     print("Error updating discussion: $e");
  //     throw Exception("Failed to update discussion");
  //   }
  // }
}
