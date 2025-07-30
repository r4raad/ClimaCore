import 'package:cloud_firestore/cloud_firestore.dart';

class Ecore {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? conqueredBySchoolId;
  final String? conqueredBySchoolName;
  final DateTime? conqueredAt;
  final DateTime? coolingTimeEnd;
  final List<EcoreMission> missions;
  final int totalPoints;
  final bool isActive;
  final DateTime createdAt;

  Ecore({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.conqueredBySchoolId,
    this.conqueredBySchoolName,
    this.conqueredAt,
    this.coolingTimeEnd,
    required this.missions,
    required this.totalPoints,
    required this.isActive,
    required this.createdAt,
  });

  bool get isConquered => conqueredBySchoolId != null;
  bool get isInCoolingTime => coolingTimeEnd != null && DateTime.now().isBefore(coolingTimeEnd!);
  bool get canBeConquered => !isConquered && !isInCoolingTime;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'conqueredBySchoolId': conqueredBySchoolId,
      'conqueredBySchoolName': conqueredBySchoolName,
      'conqueredAt': conqueredAt,
      'coolingTimeEnd': coolingTimeEnd,
      'missions': missions.map((m) => m.toMap()).toList(),
      'totalPoints': totalPoints,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  factory Ecore.fromMap(String id, Map<String, dynamic> data) {
    return Ecore(
      id: id,
      name: data['name'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      conqueredBySchoolId: data['conqueredBySchoolId'],
      conqueredBySchoolName: data['conqueredBySchoolName'],
      conqueredAt: data['conqueredAt'] is Timestamp 
          ? (data['conqueredAt'] as Timestamp).toDate()
          : null,
      coolingTimeEnd: data['coolingTimeEnd'] is Timestamp 
          ? (data['coolingTimeEnd'] as Timestamp).toDate()
          : null,
      missions: (data['missions'] as List<dynamic>? ?? [])
          .map((m) => EcoreMission.fromMap(m as Map<String, dynamic>))
          .toList(),
      totalPoints: data['totalPoints'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is Timestamp 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Ecore copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? conqueredBySchoolId,
    String? conqueredBySchoolName,
    DateTime? conqueredAt,
    DateTime? coolingTimeEnd,
    List<EcoreMission>? missions,
    int? totalPoints,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Ecore(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      conqueredBySchoolId: conqueredBySchoolId ?? this.conqueredBySchoolId,
      conqueredBySchoolName: conqueredBySchoolName ?? this.conqueredBySchoolName,
      conqueredAt: conqueredAt ?? this.conqueredAt,
      coolingTimeEnd: coolingTimeEnd ?? this.coolingTimeEnd,
      missions: missions ?? this.missions,
      totalPoints: totalPoints ?? this.totalPoints,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EcoreMission {
  final String id;
  final String title;
  final String description;
  final String summary;
  final List<String> tips;
  final List<String> categories;
  final int points;
  final String imageUrl;
  final bool isCompleted;
  final String? completedByUserId;
  final String? completedByUserName;
  final DateTime? completedAt;
  final String? proofImageUrl;

  EcoreMission({
    required this.id,
    required this.title,
    required this.description,
    required this.summary,
    required this.tips,
    required this.categories,
    required this.points,
    required this.imageUrl,
    this.isCompleted = false,
    this.completedByUserId,
    this.completedByUserName,
    this.completedAt,
    this.proofImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'summary': summary,
      'tips': tips,
      'categories': categories,
      'points': points,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'completedByUserId': completedByUserId,
      'completedByUserName': completedByUserName,
      'completedAt': completedAt,
      'proofImageUrl': proofImageUrl,
    };
  }

  factory EcoreMission.fromMap(Map<String, dynamic> data) {
    return EcoreMission(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      summary: data['summary'] ?? '',
      tips: List<String>.from(data['tips'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      points: data['points'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      completedByUserId: data['completedByUserId'],
      completedByUserName: data['completedByUserName'],
      completedAt: data['completedAt'] is Timestamp 
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      proofImageUrl: data['proofImageUrl'],
    );
  }

  EcoreMission copyWith({
    String? id,
    String? title,
    String? description,
    String? summary,
    List<String>? tips,
    List<String>? categories,
    int? points,
    String? imageUrl,
    bool? isCompleted,
    String? completedByUserId,
    String? completedByUserName,
    DateTime? completedAt,
    String? proofImageUrl,
  }) {
    return EcoreMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      summary: summary ?? this.summary,
      tips: tips ?? this.tips,
      categories: categories ?? this.categories,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      completedByUserId: completedByUserId ?? this.completedByUserId,
      completedByUserName: completedByUserName ?? this.completedByUserName,
      completedAt: completedAt ?? this.completedAt,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
    );
  }
} 