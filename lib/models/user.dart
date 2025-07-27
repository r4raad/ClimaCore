class AppUser {
  final String id;
  final String name;
  final String? joinedSchoolId;
  final int points;
  final List<String> savedPosts;
  final List<String> likedPosts;
  final String? profilePic;
  final int actions;
  final int streak;
  final int weekPoints;
  final int weekGoal;

  AppUser({
    required this.id,
    required this.name,
    this.joinedSchoolId,
    required this.points,
    required this.savedPosts,
    required this.likedPosts,
    this.profilePic,
    required this.actions,
    required this.streak,
    required this.weekPoints,
    required this.weekGoal,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      joinedSchoolId: data['joinedSchoolId'],
      points: data['points'] ?? 0,
      savedPosts: List<String>.from(data['savedPosts'] ?? []),
      likedPosts: List<String>.from(data['likedPosts'] ?? []),
      profilePic: data['profilePic'],
      actions: data['actions'] ?? 0,
      streak: data['streak'] ?? 0,
      weekPoints: data['weekPoints'] ?? 0,
      weekGoal: data['weekGoal'] ?? 800,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'joinedSchoolId': joinedSchoolId,
      'points': points,
      'savedPosts': savedPosts,
      'likedPosts': likedPosts,
      'profilePic': profilePic,
      'actions': actions,
      'streak': streak,
      'weekPoints': weekPoints,
      'weekGoal': weekGoal,
    };
  }
} 