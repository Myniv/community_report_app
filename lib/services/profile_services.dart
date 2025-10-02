import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_report_app/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ProfileService {
  final CollectionReference profiles = FirebaseFirestore.instance.collection(
    'users',
  );
  static const String baseUrl = "http://10.0.2.2:5088/Profile";

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createUserProfile(Profile profile) async {
    await profiles.doc(profile.uid).set(profile.toMap());
    await createProfileDB(profile);
  }

  Future<Profile> createProfileDB(Profile profile) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profile.toApi()),
      );

      print(profile.toApi());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Profile.fromMap(data);
      } else {
        throw Exception("Failed to create profile DB");
      }
    } catch (e) {
      print("Error creating profile DB: $e");
      throw Exception("Failed to create profile DB");
    }
  }

  Future<Profile?> getUserProfile(String uid) async {
    final doc = await profiles.doc(uid).get();
    if (doc.exists) {
      return Profile.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUserProfile(Profile profile) async {
    await profiles.doc(profile.uid).update(profile.toMap());
    await updateUserDB(profile);
  }

  Future<void> updateUserDB(Profile profile) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/${profile.uid}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(profile.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update profile DB");
      }
    } catch (e) {
      print("Error updating profile DB: $e");
      throw Exception("Failed to update profile");
    }
  }

  Future<bool> checkUserExists(String uid) async {
    final doc = await profiles.doc(uid).get();
    return doc.exists;
  }

  Future<String> uploadProfilePhoto(String uid, File file) async {
    final fileName = "$uid.jpg";

    // Upload ke Supabase Storage
    await _supabase.storage
        .from('profile_photos_community_app')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    // Ambil URL public
    final url = _supabase.storage
        .from('profile_photos_community_app')
        .getPublicUrl(fileName);

    // Update Firestore dengan URL foto
    await profiles.doc(uid).update({'photo': url});

    return url;
  }
}
