class AppUser {
  final String id;
  final String name;
  final String? joinedSchoolId;
  final int points;
  final List<String> savedPosts;
  final List<String> likedPosts;

  AppUser({
    required this.id,
    required this.name,
    this.joinedSchoolId,
    required this.points,
    required this.savedPosts,
    required this.likedPosts,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      joinedSchoolId: data['joinedSchoolId'],
      points: data['points'] ?? 0,
      savedPosts: List<String>.from(data['savedPosts'] ?? []),
      likedPosts: List<String>.from(data['likedPosts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'joinedSchoolId': joinedSchoolId,
      'points': points,
      'savedPosts': savedPosts,
      'likedPosts': likedPosts,
    };
  }
} 