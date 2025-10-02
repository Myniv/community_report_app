import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  String uid;
  String email;
  String? username;
  String role;
  String? front_name;
  String? last_name;
  String? photo;
  String? phone;
  String? location;
  DateTime? created_at;
  DateTime? updated_at;
  DateTime? deleted_at;

  Profile({
    required this.uid,
    required this.email,
    this.username,
    required this.role,
    this.front_name,
    this.last_name,
    this.photo,
    this.phone,
    this.location,
    this.created_at,
    this.updated_at,
    this.deleted_at,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'front_name': front_name,
      'last_name': last_name,
      'role': role,
      'photo': photo,
      'phone': phone,
      'address': location,
      'created_at': created_at != null ? Timestamp.fromDate(created_at!) : null,
      'updated_at': updated_at != null ? Timestamp.fromDate(updated_at!) : null,
      'deleted_at': deleted_at != null ? Timestamp.fromDate(deleted_at!) : null,
    };
  }

  Map<String, dynamic> toApi() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'front_name': front_name,
      'last_name': last_name,
      'role': role,
      'photo': photo,
      'phone': phone,
      'address': location,
      'created_at': created_at?.toIso8601String(),
      'updated_at': updated_at?.toIso8601String(),
      'deleted_at': deleted_at?.toIso8601String(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate(); // Firestore
      if (value is String) return DateTime.tryParse(value); // API
      return null;
    }

    return Profile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'],
      role: map['role'] ?? '',
      front_name: map['front_name'],
      last_name: map['last_name'],
      photo: map['photo'],
      phone: map['phone'],
      location: map['address'],
      created_at: parseDate(map['created_at']),
      updated_at: parseDate(map['updated_at']),
      deleted_at: parseDate(map['deleted_at']),
    );
  }
}
