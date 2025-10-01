import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  int? id;
  String? user_id;
  String? title;
  String? description;
  String? photo;
  double? longitude;
  double? latitude;
  String? location;
  String? status;
  String? category;
  bool? is_report;
  String? urgency;
  DateTime? created_at;
  DateTime? updated_at;
  DateTime? deleted_at;

  CommunityPost({
    this.id,
    this.user_id,
    this.title,
    this.description,
    this.photo,
    this.longitude,
    this.latitude,
    this.location,
    this.status,
    this.category,
    this.is_report,
    this.urgency,
    this.created_at,
    this.updated_at,
    this.deleted_at,
  });

  CommunityPost copyWith({
    int? id,
    String? user_id,
    String? title,
    String? description,
    String? photo,
    double? longitude,
    double? latitude,
    String? location,
    String? status,
    String? category,
    bool? is_report,
    String? urgency,
    DateTime? created_at,
    DateTime? updated_at,
    DateTime? deleted_at,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      location: location ?? this.location,
      status: status ?? this.status,
      category: category ?? this.category,
      is_report: is_report ?? this.is_report,
      urgency: urgency ?? this.urgency,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      deleted_at: deleted_at ?? this.deleted_at,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': user_id,
      'title': title,
      'description': description,
      'photo': photo,
      'longitude': longitude,
      'latitude': latitude,
      'location': location,
      'status': status,
      'category': category,
      'is_report': is_report,
      'urgency': urgency,
      'created_at': created_at != null ? Timestamp.fromDate(created_at!) : null,
      'updated_at': updated_at != null ? Timestamp.fromDate(updated_at!) : null,
      'deleted_at': deleted_at != null ? Timestamp.fromDate(deleted_at!) : null,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      user_id: map['user_id'],
      title: map['title'],
      description: map['description'],
      photo: map['photo'],
      longitude: map['longitude'],
      latitude: map['latitude'],
      location: map['location'],
      status: map['status'],
      category: map['category'],
      is_report: map['is_report'],
      urgency: map['urgency'],
      created_at: map['created_at'] != null
          ? (map['created_at'] as Timestamp).toDate()
          : null,
      updated_at: map['updated_at'] != null
          ? (map['updated_at'] as Timestamp).toDate()
          : null,
      deleted_at: map['deleted_at'] != null
          ? (map['deleted_at'] as Timestamp).toDate()
          : null,
    );
  }
}
