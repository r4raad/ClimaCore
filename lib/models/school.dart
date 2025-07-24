class School {
  final String id;
  final String name;
  final String? imageUrl;

  School({required this.id, required this.name, this.imageUrl});

  factory School.fromMap(String id, Map<String, dynamic> data) {
    return School(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
} 