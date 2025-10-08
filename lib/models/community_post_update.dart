class CommunityPostUpdate {
  final int? communityPostUpdateId;
  final String? userId;
  final int? communityPostId;
  final String? title;
  final String? description;
  final String? photo;
  final bool? isResolved;
  final String? userPhoto;
  final String? username;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  CommunityPostUpdate({
    this.communityPostUpdateId,
    this.userId,
    this.communityPostId,
    this.title,
    this.description,
    this.photo,
    this.isResolved,
    this.userPhoto,
    this.username,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CommunityPostUpdate.fromMap(Map<String, dynamic> map) {
    return CommunityPostUpdate(
      communityPostUpdateId: map['communityPostUpdateId'] as int,
      communityPostId: map['postId'] as int,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photo: map['photo'] ?? '',
      isResolved: map['isResolved'] ?? false,
      username: map['user']?['username'] ?? '',
      userPhoto: map['user']?['photo'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': communityPostId,
      'userId': userId,
      'title': title,
      'description': description,
      'photo': photo,
      'isResolved': isResolved,
    };
  }

  CommunityPostUpdate copyWith({
    int? communityPostUpdateId,
    String? userId,
    int? communityPostId,
    String? title,
    String? description,
    String? photo,
    bool? isResolved,
    String? userPhoto,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return CommunityPostUpdate(
      communityPostUpdateId:
          communityPostUpdateId ?? this.communityPostUpdateId,
      userId: userId ?? this.userId,
      communityPostId: communityPostId ?? this.communityPostId,
      title: title ?? this.title,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      isResolved: isResolved ?? this.isResolved,
      userPhoto: userPhoto ?? this.userPhoto,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
