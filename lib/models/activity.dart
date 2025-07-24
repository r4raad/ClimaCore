import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final int points;
  final int participantCount;
  final String type;
  final bool isUpcoming;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
    required this.points,
    required this.participantCount,
    required this.type,
    required this.isUpcoming,
  });

  factory Activity.fromMap(String id, Map<String, dynamic> data) {
    return Activity(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      date: (data['date'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
      participantCount: data['participantCount'] ?? 0,
      type: data['type'] ?? '',
      isUpcoming: data['isUpcoming'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date,
      'points': points,
      'participantCount': participantCount,
      'type': type,
      'isUpcoming': isUpcoming,
    };
  }
} 