import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_report_app/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final CollectionReference profiles = FirebaseFirestore.instance.collection(
    'users',
  );

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createUserProfile(Profile profile) async {
    await profiles.doc(profile.uid).set(profile.toMap());
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
