class AppUser {
  final String id;
  final String firstName;
  final String lastName;
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
    required this.firstName,
    required this.lastName,
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

  // Getter for full name (backward compatibility)
  String get fullName => '$firstName $lastName'.trim();
  
  // Getter for first name only
  String get displayName => firstName;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    // Handle backward compatibility - if 'name' exists, split it
    String firstName = '';
    String lastName = '';
    
    if (data['firstName'] != null && data['lastName'] != null) {
      // New format with separate fields
      firstName = data['firstName'] ?? '';
      lastName = data['lastName'] ?? '';
    } else if (data['name'] != null) {
      // Old format - split the name
      final nameParts = (data['name'] as String).trim().split(' ');
      firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }
    
    return AppUser(
      id: id,
      firstName: firstName,
      lastName: lastName,
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
      'firstName': firstName,
      'lastName': lastName,
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