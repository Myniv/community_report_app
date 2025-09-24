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

  factory Profile.fromMap(Map<String, dynamic> map) {
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
      created_at: map['created_at'] != null ? map['created_at'].toDate() : null,
      updated_at: map['updated_at'] != null ? map['updated_at'].toDate() : null,
      deleted_at: map['deleted_at'] != null ? map['deleted_at'].toDate() : null,
    );
  }
}
