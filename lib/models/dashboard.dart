class Dashboard {
  int totalProfile;
  int totalPost;
  Map<String, int> totalPostStatus;
  Map<String, int> totalPostCategory;
  Map<String, int> totalPostLocation;
  Map<String, int> totalPostUrgency;

  Dashboard({
    required this.totalProfile,
    required this.totalPost,
    required this.totalPostStatus,
    required this.totalPostCategory,
    required this.totalPostLocation,
    required this.totalPostUrgency,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalProfile': totalProfile,
      'totalPost': totalPost,
      'totalPostStatus': totalPostStatus,
      'totalPostCategory': totalPostCategory,
      'totalPostLocation': totalPostLocation,
      'totalPostUrgency': totalPostUrgency,
    };
  }

  factory Dashboard.fromMap(Map<String, dynamic> map) {
    return Dashboard(
      totalProfile: map['totalProfile'] ?? 0,
      totalPost: map['totalPost'] ?? 0,
      totalPostStatus: Map<String, int>.from(map['totalPostStatus'] ?? {}),
      totalPostCategory: Map<String, int>.from(map['totalPostCategory'] ?? {}),
      totalPostLocation: Map<String, int>.from(map['totalPostLocation'] ?? {}),
      totalPostUrgency: Map<String, int>.from(map['totalPostUrgency'] ?? {}),
    );
  }
}
