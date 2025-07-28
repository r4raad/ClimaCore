import 'package:cloud_firestore/cloud_firestore.dart';

class DisasterEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final String type;
  final DateTime date;
  final String casualties;
  final String damage;
  final String imageUrl;
  final String sourceUrl;
  final bool isActive;

  DisasterEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.date,
    required this.casualties,
    required this.damage,
    required this.imageUrl,
    required this.sourceUrl,
    this.isActive = true,
  });

  factory DisasterEvent.fromJson(Map<String, dynamic> json) {
    return DisasterEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] is Timestamp 
          ? (json['date'] as Timestamp).toDate()
          : DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      casualties: json['casualties'] ?? '',
      damage: json['damage'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      sourceUrl: json['sourceUrl'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'date': Timestamp.fromDate(date),
      'casualties': casualties,
      'damage': damage,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
      'isActive': isActive,
    };
  }

  DisasterEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? type,
    DateTime? date,
    String? casualties,
    String? damage,
    String? imageUrl,
    String? sourceUrl,
    bool? isActive,
  }) {
    return DisasterEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      date: date ?? this.date,
      casualties: casualties ?? this.casualties,
      damage: damage ?? this.damage,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isActive: isActive ?? this.isActive,
    );
  }
} 