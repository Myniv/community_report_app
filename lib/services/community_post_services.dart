import 'dart:convert';
import 'dart:io';

import 'package:community_report_app/models/community_post.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityPostServices {
  static const String baseUrl = "http://10.0.2.2:5088/CommunityPost";
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CommunityPost>> getPosts({
    String? userId,
    String? status,
    String? category,
    String? location,
    bool? isReport,
    String? urgency,
  }) async {
    try {
      final queryParams = {
        if (userId != null) 'userId': userId,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
        if (location != null) 'location': location,
        if (isReport != null) 'isReport': isReport.toString(),
        if (urgency != null) 'urgency': urgency,
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => CommunityPost.fromAPIWithUsernamePhoto(e))
            .toList();
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      print("Error fetching posts: $e");
      throw Exception("Failed to load posts");
    }
  }

  Future<CommunityPost> getPostById(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/post/$id"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommunityPost.fromAPIWithDiscussions(data);
      } else {
        throw Exception("Failed to load post");
      }
    } catch (e) {
      print("Error fetching post: $e");
      rethrow;
    }
  }

  Future<CommunityPost> createPost(CommunityPost post) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(post.toMap()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CommunityPost.fromMap(data);
      } else {
        throw Exception("Failed to create post");
      }
    } catch (e) {
      print("Error creating post: $e");
      throw Exception("Failed to create post");
    }
  }

  Future<void> updatePost(CommunityPost post) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/${post.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(post.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to update post");
      }
    } catch (e) {
      print("Error updating post: $e");
      throw Exception("Failed to update post");
    }
  }

  Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$id"));
      if (response.statusCode != 200) {
        throw Exception("Failed to delete post");
      }
    } catch (e) {
      print("Error deleting post: $e");
      throw Exception("Failed to delete post");
    }
  }

  Future<String> uploadProfilePhoto(
    int postId,
    File file,
    String oldUrl,
  ) async {
    try {
      final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ext = path.extension(file.path);
      final fileName = "${postId}_$timeStamp$ext";

      await deleteOldProfilePhoto(oldUrl);

      await _supabase.storage
          .from('post_community_app')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final url = _supabase.storage
          .from('post_community_app')
          .getPublicUrl(fileName);

      // await profiles.doc(uid).update({'profilePicturePath': url});

      return url;
    } catch (e) {
      print("Error in uploadProfilePhoto: $e");
      rethrow;
    }
  }

  Future<void> deleteOldProfilePhoto(String oldUrl) async {
    try {
      if (oldUrl.isEmpty) return;

      final uri = Uri.parse(oldUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length >= 2) {
        final fileName = pathSegments.last;
        await _supabase.storage.from('profile_photos').remove([fileName]);
        print("Deleted old profile photo: $fileName");
      }
    } catch (e) {
      print("Error deleting old profile photo: $e");
    }
  }
}
