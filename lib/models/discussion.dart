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
}
