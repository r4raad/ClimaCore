class School {
  final String id;
  final String name;
  final String? imageUrl;
  final int memberCount;

  School({required this.id, required this.name, this.imageUrl, this.memberCount = 0});

  factory School.fromMap(String id, Map<String, dynamic> data) {
    return School(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      memberCount: data['memberCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
} 