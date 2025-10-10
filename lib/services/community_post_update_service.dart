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
          .from('post_community_app')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage
          .from('post_community_app')
          .getPublicUrl(fileName);

      // await profiles.doc(uid).update({'profilePicturePath': url});

      return url;
    } catch (e) {
      print("Error in upload community update photo: $e");
      rethrow;
    }
  }

  Future<CommunityPostUpdate> getPostById(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$id"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommunityPostUpdate.fromMap(data);
      } else {
        throw Exception(
          "Failed to load post update. Status code: ${response.statusCode}, body: ${response.body}",
        );
      }
    } catch (e) {
      print("Error fetching post update: $e");
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

  Future<void> updateCommunityPostUpdate(
    CommunityPostUpdate communityPostUpdate,
    int communityPostUpdateId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$communityPostUpdateId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(communityPostUpdate.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to update community post update");
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

  Future<void> deleteOldComunityPostUpdatePhoto(String oldUrl) async {
    try {
      if (oldUrl.isEmpty) return;

      final uri = Uri.parse(oldUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 2) {
        final fileName = pathSegments.last;
        await _supabase.storage.from('post_community_app').remove([fileName]);
        print("Deleted old comunity post update photo: $fileName");
      }
    } catch (e) {
      print("Error deleting old profile photo: $e");
    }
  }
}
