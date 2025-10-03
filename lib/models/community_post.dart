import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_report_app/models/discussion.dart';

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
  String? username;
  String? user_photo;
  List<Discussion> discussions;

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
    this.username,
    this.user_photo,
    this.discussions = const [],
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
    String? username,
    String? user_photo,
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
      username: username ?? this.username,
      user_photo: user_photo ?? this.user_photo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': user_id,
      'title': title,
      'description': description,
      'photo': photo,
      'longitude': longitude,
      'latitude': latitude,
      'location': location,
      'status': status,
      'category': category,
      'isReport': is_report ?? true,
      'urgency': urgency,
      // 'createdAt': created_at != null ? Timestamp.fromDate(created_at!) : null,
      // 'updatedAt': updated_at != null ? Timestamp.fromDate(updated_at!) : null,
      // 'deletedAt': deleted_at != null ? Timestamp.fromDate(deleted_at!) : null,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      user_id: map['userId'] ?? map['user_id'],
      title: map['title'],
      description: map['description'],
      photo: map['photo'],
      longitude: map['longitude']?.toDouble(),
      latitude: map['latitude']?.toDouble(),
      location: map['location'],
      status: map['status'],
      category: map['category'],
      is_report: _parseBool(map['isReport']),
      urgency: map['urgency'],
      username: map['username'],
      created_at: _parseDateTime(map['createdAt'] ?? map['created_at']),
      updated_at: _parseDateTime(map['updatedAt'] ?? map['updated_at']),
      deleted_at: _parseDateTime(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  factory CommunityPost.fromAPIWithUsernamePhoto(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      user_id: map['userId'] ?? map['user_id'],
      title: map['title'],
      description: map['description'],
      photo: map['photo'] == null || map['photo'] == '' ? null : map['photo'],
      longitude: map['longitude']?.toDouble(),
      latitude: map['latitude']?.toDouble(),
      location: map['location'],
      status: map['status'],
      category: map['category'],
      is_report: _parseBool(map['isReport']),
      urgency: map['urgency'],
      username: map['username'],
      user_photo: map['userPhoto'],
      created_at: _parseDateTime(map['createdAt'] ?? map['created_at']),
      updated_at: _parseDateTime(map['updatedAt'] ?? map['updated_at']),
      deleted_at: _parseDateTime(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  factory CommunityPost.fromAPIWithDiscussions(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      user_id: map['userId'] ?? map['user_id'],
      title: map['title'],
      description: map['description'],
      photo: map['photo'] == null || map['photo'] == '' ? null : map['photo'],
      longitude: map['longitude']?.toDouble(),
      latitude: map['latitude']?.toDouble(),
      location: map['location'],
      status: map['status'],
      category: map['category'],
      is_report: _parseBool(map['isReport']),
      urgency: map['urgency'],
      username: map['username'],
      user_photo: map['userPhoto'],
      discussions: map['discussions'] != null
          ? List<Discussion>.from(
              (map['discussions'] as List).map(
                (x) => Discussion.fromMap(x as Map<String, dynamic>),
              ),
            )
          : [],
      created_at: _parseDateTime(map['createdAt'] ?? map['created_at']),
      updated_at: _parseDateTime(map['updatedAt'] ?? map['updated_at']),
      deleted_at: _parseDateTime(map['deletedAt'] ?? map['deleted_at']),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return null;
  }
}
