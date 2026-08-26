import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;
  final DateTime? endDate;
  final int points;
  final int participantCount;
  final List<String> participants;
  final String type;
  final String location;
  final String? communityName;
  final String? mapUrl;
  final bool isUpcoming;
  final bool isCompleted;
  final String? schoolId;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.date,
    this.endDate,
    required this.points,
    required this.participantCount,
    required this.participants,
    required this.type,
    required this.location,
    this.communityName,
    this.mapUrl,
    required this.isUpcoming,
    required this.isCompleted,
    this.schoolId,
  });

  factory Activity.fromMap(String id, Map<String, dynamic> data) {
    final now = DateTime.now();
    final activityDate = (data['date'] as Timestamp).toDate();
    final isUpcoming = activityDate.isAfter(now);
    final isCompleted = data['isCompleted'] ?? false;

    final participants = List<String>.from(data['participants'] ?? []);

    return Activity(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      date: activityDate,
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
      points: data['points'] ?? 0,
      participantCount: participants.length,
      participants: participants,
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      communityName: data['communityName'],
      mapUrl: data['mapUrl'],
      isUpcoming: isUpcoming,
      isCompleted: isCompleted,
      schoolId: data['schoolId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'points': points,
      'participantCount': participants.length,
      'participants': participants,
      'type': type,
      'location': location,
      'communityName': communityName,
      'mapUrl': mapUrl,
      'isUpcoming': isUpcoming,
      'isCompleted': isCompleted,
      'schoolId': schoolId,
    };
  }

  bool get isPast => date.isBefore(DateTime.now());
  bool get isOngoing => !isPast && !isUpcoming;
  bool get canJoin => isUpcoming && !isCompleted;

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}, ${date.year}';
  }

  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get fullDateTime => '$formattedDate @$formattedTime';

  bool isUserJoined(String userId) {
    return participants.contains(userId);
  }
}