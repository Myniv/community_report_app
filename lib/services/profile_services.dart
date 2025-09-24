import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_report_app/models/profile.dart';

class ProfileService {
  final CollectionReference profiles = FirebaseFirestore.instance.collection(
    'users',
  );

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
}
