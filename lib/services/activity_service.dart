import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';
import '../services/user_service.dart';

class ActivityService {
  final UserService _userService = UserService();
  
  CollectionReference getActivitiesCollection(String schoolId) {
    return FirebaseFirestore.instance.collection('schools').doc(schoolId).collection('activities');
  }

  Future<List<Activity>> getActivities(String schoolId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      print('📊 ActivityService: Fetching activities for school $schoolId');
      Query query = getActivitiesCollection(schoolId).orderBy('date', descending: false);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);
      
      final snapshot = await query.get();
      final activities = snapshot.docs.map((doc) => 
        Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
      
      print('✅ ActivityService: Successfully fetched ${activities.length} activities');
      return activities;
    } catch (e) {
      print('❌ ActivityService: Error fetching activities: $e');
      // Return empty list instead of throwing to prevent app crashes
      return [];
    }
  }

  Future<List<Activity>> getUpcomingActivities(String schoolId, {int limit = 10}) async {
    try {
      final now = DateTime.now();
      final snapshot = await getActivitiesCollection(schoolId)
          .where('date', isGreaterThan: now)
          .orderBy('date', descending: false)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => 
        Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Error fetching upcoming activities: $e');
      rethrow;
    }
  }

  Future<void> addActivity(String schoolId, Activity activity) async {
    try {
      await getActivitiesCollection(schoolId).doc(activity.id).set(activity.toMap());
    } catch (e) {
      print('Error adding activity: $e');
      rethrow;
    }
  }

  Future<Activity?> getActivityById(String schoolId, String activityId) async {
    try {
      final doc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (doc.exists) {
        return Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching activity by ID: $e');
      rethrow;
    }
  }

  Future<void> createSampleActivities(String schoolId) async {
    final activitiesCollection = getActivitiesCollection(schoolId);
    final snapshot = await activitiesCollection.get();
    if (snapshot.docs.isNotEmpty) return;

    final sampleActivities = [
      {
        "id": "activity_1",
        "title": "Clean the Onchon-Chon River",
        "type": "Campaign - Restoration",
        "points": 800,
        "participantCount": 30,
        "date": DateTime.parse("2025-05-04T09:00:00Z"),
        "imageUrl": "https://your-image-url.com/river.png",
        "description": "Help restore the beauty of the Onchon-Chon River! Together, we'll remove waste, raise awareness about water pollution, and take a step toward a healthier environment."
      },
      {
        "id": "activity_2",
        "title": "Tree Plantation",
        "type": "Campaign - Greenery",
        "points": 600,
        "participantCount": 80,
        "date": DateTime.parse("2025-05-19T09:00:00Z"),
        "imageUrl": "https://your-image-url.com/tree.png",
        "description": "Join us for a community tree planting event! Help us plant 100 trees in our local park."
      },
      {
        "id": "activity_3",
        "title": "Planning upcoming activities",
        "type": "Workshop - Zoom",
        "points": 300,
        "participantCount": 300,
        "date": DateTime.parse("2025-05-22T09:00:00Z"),
        "imageUrl": "https://your-image-url.com/workshop.png",
        "description": "Planning and organizing upcoming community activities via Zoom."
      },
      {
        "id": "activity_4",
        "title": "Climate Change Seminar",
        "type": "Seminar - Busan High School",
        "points": 500,
        "participantCount": 87,
        "date": DateTime.parse("2025-04-30T11:00:00Z"),
        "imageUrl": "https://your-image-url.com/seminar.png",
        "description": "An educational and interactive seminar where local experts, activists, or educators discuss the causes, impacts, and solutions to climate change."
      },
      {
        "id": "activity_5",
        "title": "Green Cooking Class",
        "type": "Workshop - Zoom",
        "points": 350,
        "participantCount": 500,
        "date": DateTime.parse("2025-04-28T09:00:00Z"),
        "imageUrl": "https://your-image-url.com/cooking.png",
        "description": "A fun and educational cooking class focused on sustainable and eco-friendly recipes."
      },
      {
        "id": "activity_6",
        "title": "Street Cleaning Campaign",
        "type": "Campaign - Restoration",
        "points": 350,
        "participantCount": 896,
        "date": DateTime.parse("2025-04-15T09:00:00Z"),
        "imageUrl": "https://your-image-url.com/cleaning.png",
        "description": "Join our street cleaning campaign to help keep our community clean and green!"
      },
    ];

    for (final activity in sampleActivities) {
      await activitiesCollection.doc(activity["id"] as String).set({
        ...activity,
        "date": activity["date"],
        "imageUrl": activity["imageUrl"] as String,
      });
    }
  }

  Future<void> joinActivity(String schoolId, String activityId, String userId) async {
    try {
      print('🎯 ActivityService: User $userId joining activity $activityId');
      
      // Get activity details to know the points
      final activityDoc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }
      
      final activityData = activityDoc.data() as Map<String, dynamic>;
      final points = activityData['points'] ?? 0;
      
      print('💰 ActivityService: Activity offers $points points');
      
      // Update activity participants
      await getActivitiesCollection(schoolId).doc(activityId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'participantCount': FieldValue.increment(1),
      });
      
      // Add points to user
      await _userService.addUserPoints(userId, points);
      await _userService.addWeekPoints(userId, points);
      await _userService.addUserAction(userId);
      
      print('✅ ActivityService: User $userId successfully joined activity and earned $points points');
    } catch (e) {
      print('❌ ActivityService: Error joining activity: $e');
      rethrow;
    }
  }

  Future<void> leaveActivity(String schoolId, String activityId, String userId) async {
    try {
      print('🚪 ActivityService: User $userId leaving activity $activityId');
      
      // Get activity details to know the points to deduct
      final activityDoc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }
      
      final activityData = activityDoc.data() as Map<String, dynamic>;
      final points = activityData['points'] ?? 0;
      
      print('💰 ActivityService: Activity had $points points, deducting from user');
      
      // Update activity participants
      await getActivitiesCollection(schoolId).doc(activityId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'participantCount': FieldValue.increment(-1),
      });
      
      // Deduct points from user (negative points to subtract)
      await _userService.addUserPoints(userId, -points);
      await _userService.addWeekPoints(userId, -points);
      // Note: We don't decrement actions when leaving, as the action was already taken
      
      print('✅ ActivityService: User $userId successfully left activity and lost $points points');
    } catch (e) {
      print('❌ ActivityService: Error leaving activity: $e');
      rethrow;
    }
  }

  Future<bool> isUserJoined(String schoolId, String activityId, String userId) async {
    try {
      final doc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants'] ?? []);
      return participants.contains(userId);
    } catch (e) {
      print('Error checking if user joined: $e');
      return false;
    }
  }
} 