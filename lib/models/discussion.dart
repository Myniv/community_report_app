import 'package:community_report_app/models/community_post.dart';

class Discussion {
  final int? discussionId;
  final String? userId;
  final int? communityPostId;
  final String? message;
  final String? userPhoto;
  final String? username;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final CommunityPost? communityPost;

  Discussion({
    this.discussionId,
    this.userId,
    this.communityPostId,
    this.message,
    this.userPhoto,
    this.username,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.communityPost,
  });

  factory Discussion.fromMap(Map<String, dynamic> map) {
    return Discussion(
      discussionId: map['discussionId'] as int,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null,
      username: map['user']?['username'] ?? '',
      userPhoto: map['user']?['photo'] ?? '',
      userId: map['userId'] ?? '',
      communityPostId: map['communityPostId'] as int,
      message: map['message'] ?? '',
    );
  }

  factory Discussion.fromMapWithCommunityPost(Map<String, dynamic> map) {
    return Discussion(
      discussionId: map['discussionId'] as int,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null,
      userId: map['userId'] ?? '',
      communityPostId: map['communityPostId'] as int,
      message: map['message'] ?? '',
      communityPost: map['communityPost'] != null
          ? CommunityPost.fromAPIWithDiscussions(map['communityPost'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'communityPostId': communityPostId,
      'message': message,
    };
  }

  Discussion copyWith({
    int? discussionId,
    String? userId,
    int? communityPostId,
    String? message,
    String? userPhoto,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Discussion(
      discussionId: discussionId ?? this.discussionId,
      userId: userId ?? this.userId,
      communityPostId: communityPostId ?? this.communityPostId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      username: username ?? this.username,
      userPhoto: userPhoto ?? this.userPhoto,
      message: message ?? this.message,
    );
  }
}
