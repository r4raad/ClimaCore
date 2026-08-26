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
      Query query = getActivitiesCollection(schoolId).orderBy('date', descending: true);

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
      print('❌ ActivityService: Error fetching upcoming activities: $e');
      return [];
    }
  }

  Future<List<Activity>> getRecentActivities(String schoolId, {int limit = 10}) async {
    try {
      final now = DateTime.now();
      final snapshot = await getActivitiesCollection(schoolId)
          .where('date', isLessThan: now)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) =>
        Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('❌ ActivityService: Error fetching recent activities: $e');
      return [];
    }
  }

  Future<void> addActivity(String schoolId, Activity activity) async {
    try {
      await getActivitiesCollection(schoolId).doc(activity.id).set(activity.toMap());
    } catch (e) {
      print('❌ ActivityService: Error adding activity: $e');
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
      print('❌ ActivityService: Error fetching activity by ID: $e');
      return null;
    }
  }

  Future<void> createSchoolSpecificActivities(String schoolId) async {
    try {
      final activitiesCollection = getActivitiesCollection(schoolId);
      final snapshot = await activitiesCollection.get();
      if (snapshot.docs.isNotEmpty) {
        print('✅ ActivityService: Activities already exist for school $schoolId');
        return;
      }

      print('📝 ActivityService: Creating school-specific activities for $schoolId');

      final activities = _getSchoolSpecificActivities(schoolId);

      for (final activity in activities) {
        await activitiesCollection.doc(activity["id"] as String).set(activity);
      }

      print('✅ ActivityService: Created ${activities.length} activities for school $schoolId');
    } catch (e) {
      print('❌ ActivityService: Error creating school activities: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _getSchoolSpecificActivities(String schoolId) {
    final aug9 = DateTime(2025, 8, 9);

    switch (schoolId) {
      case 'daegu-gongsan':
        return [

          {
            "id": "dg_river_cleanup_upcoming",
            "title": "Clean the Onchon-Chon River",
            "type": "Campaign - Restoration",
            "points": 800,
            "participants": [],
            "date": aug9.add(Duration(days: 3)),
            "endDate": aug9.add(Duration(days: 3)).add(Duration(hours: 3)),
            "imageUrl": "assets/images/river.png",
            "description": "Help restore the beauty of the Onchon-Chon River! Together, we'll remove waste, raise awareness about water pollution, and take a step toward a healthier environment. Let's make a difference—one river at a time.",
            "location": "Onchon-Chon River, Daegu",
            "communityName": "Daegu Community",
            "mapUrl": "https://maps.google.com/?q=Onchon-Chon+River+Daegu",
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "dg_tree_planting_upcoming",
            "title": "Tree Plantation",
            "type": "Campaign - Greenery",
            "points": 600,
            "participants": [],
            "date": aug9.add(Duration(days: 10)),
            "endDate": aug9.add(Duration(days: 10)).add(Duration(hours: 4)),
            "imageUrl": "assets/images/tree.png",
            "description": "Join us for a community tree planting event! Help us plant 100 trees in our local park and contribute to a greener environment.",
            "location": "Daegu Central Park",
            "communityName": "Daegu Community",
            "mapUrl": "https://maps.google.com/?q=Daegu+Central+Park",
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "dg_workshop_upcoming",
            "title": "Planning upcoming activities",
            "type": "Workshop - Zoom",
            "points": 300,
            "participants": [],
            "date": aug9.add(Duration(days: 15)),
            "endDate": aug9.add(Duration(days: 15)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/planning.png",
            "description": "Planning and organizing upcoming community activities via Zoom. Join us to discuss and plan future environmental initiatives.",
            "location": "Online - Zoom",
            "communityName": "Daegu Community",
            "mapUrl": null,
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },

          {
            "id": "dg_climate_seminar_past",
            "title": "Climate Change Seminar",
            "type": "Seminar - Daegu High School",
            "points": 500,
            "participants": [],
            "date": aug9.subtract(Duration(days: 5)),
            "endDate": aug9.subtract(Duration(days: 5)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/seminar.png",
            "description": "An educational and interactive seminar where local experts, activists, or educators discuss the causes, impacts, and solutions to climate change. Participants learn how their choices affect the environment and how they can contribute to climate action.",
            "location": "Daegu High School",
            "communityName": "Daegu Community",
            "mapUrl": "https://maps.google.com/?q=Daegu+High+School",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
          {
            "id": "dg_cooking_class_past",
            "title": "Green Cooking Class",
            "type": "Workshop - Zoom",
            "points": 350,
            "participants": [],
            "date": aug9.subtract(Duration(days: 2)),
            "endDate": aug9.subtract(Duration(days: 2)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/cooking.png",
            "description": "A fun and educational cooking class focused on sustainable and eco-friendly recipes. Learn to cook delicious meals while being environmentally conscious.",
            "location": "Online - Zoom",
            "communityName": "Daegu Community",
            "mapUrl": null,
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'jungheung':
        return [
          {
            "id": "jh_workshop_planning",
            "title": "Planning Upcoming Activities",
            "type": "Workshop - Zoom",
            "points": 300,
            "participants": [],
            "date": aug9.add(Duration(days: 5)),
            "endDate": aug9.add(Duration(days: 5)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/planning.png",
            "description": "Planning and organizing upcoming community activities via Zoom. Join us to discuss and plan future environmental initiatives.",
            "location": "Online - Zoom",
            "communityName": "Jungheung Community",
            "mapUrl": null,
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "jh_cooking_class",
            "title": "Green Cooking Class",
            "type": "Workshop - Zoom",
            "points": 350,
            "participants": [],
            "date": aug9.subtract(Duration(days: 3)),
            "endDate": aug9.subtract(Duration(days: 3)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/cooking.png",
            "description": "A fun and educational cooking class focused on sustainable and eco-friendly recipes. Learn to cook delicious meals while being environmentally conscious.",
            "location": "Online - Zoom",
            "communityName": "Jungheung Community",
            "mapUrl": null,
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
          {
            "id": "jh_street_cleaning",
            "title": "Street Cleaning Campaign",
            "type": "Campaign - Restoration",
            "points": 350,
            "participants": [],
            "date": aug9.subtract(Duration(days: 7)),
            "endDate": aug9.subtract(Duration(days: 7)).add(Duration(hours: 3)),
            "imageUrl": "assets/images/cleaning.png",
            "description": "Join our street cleaning campaign to help keep our community clean and green! Together we can make our streets beautiful.",
            "location": "Jungheung District",
            "communityName": "Jungheung Community",
            "mapUrl": "https://maps.google.com/?q=Jungheung+District",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'nam-samsung':
        return [
          {
            "id": "ns_street_cleaning",
            "title": "Street Cleaning Campaign",
            "type": "Campaign - Restoration",
            "points": 350,
            "participants": [],
            "date": aug9.add(Duration(days: 4)),
            "endDate": aug9.add(Duration(days: 4)).add(Duration(hours: 3)),
            "imageUrl": "assets/images/cleaning.png",
            "description": "Join our street cleaning campaign to help keep our community clean and green! Together we can make our streets beautiful.",
            "location": "Nam Samsung District",
            "communityName": "Nam Samsung Community",
            "mapUrl": "https://maps.google.com/?q=Nam+Samsung+District",
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "ns_community_garden",
            "title": "Community Garden Day",
            "type": "Campaign - Greenery",
            "points": 400,
            "participants": [],
            "date": aug9.add(Duration(days: 8)),
            "endDate": aug9.add(Duration(days: 8)).add(Duration(hours: 4)),
            "imageUrl": "assets/images/tree.png",
            "description": "Help maintain and expand our community garden. Learn about sustainable gardening practices.",
            "location": "Nam Samsung Community Garden",
            "communityName": "Nam Samsung Community",
            "mapUrl": "https://maps.google.com/?q=Nam+Samsung+Community+Garden",
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "ns_waste_audit",
            "title": "Household Waste Audit",
            "type": "Workshop - Education",
            "points": 300,
            "participants": [],
            "date": aug9.subtract(Duration(days: 6)),
            "endDate": aug9.subtract(Duration(days: 6)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/planning.png",
            "description": "Learn how to conduct a waste audit at home to understand your consumption habits and reduce waste.",
            "location": "Nam Samsung Community Hall",
            "communityName": "Nam Samsung Community",
            "mapUrl": "https://maps.google.com/?q=Nam+Samsung+Community+Hall",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'posan':
        return [
          {
            "id": "ps_eco_workshop",
            "title": "Eco-Friendly Workshop",
            "type": "Workshop - Posan Center",
            "points": 450,
            "participants": [],
            "date": aug9.add(Duration(days: 6)),
            "endDate": aug9.add(Duration(days: 6)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/planning.png",
            "description": "Learn about eco-friendly practices and sustainable living in this hands-on workshop.",
            "location": "Posan Community Center",
            "communityName": "Posan Community",
            "mapUrl": "https://maps.google.com/?q=Posan+Community+Center",
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "ps_local_market_visit",
            "title": "Local Farmers Market Visit",
            "type": "Education - Field Trip",
            "points": 200,
            "participants": [],
            "date": aug9.subtract(Duration(days: 4)),
            "endDate": aug9.subtract(Duration(days: 4)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/cooking.png",
            "description": "Explore local produce and learn about sustainable food systems at the farmers market.",
            "location": "Posan Farmers Market",
            "communityName": "Posan Community",
            "mapUrl": "https://maps.google.com/?q=Posan+Farmers+Market",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
          {
            "id": "ps_composting_basics",
            "title": "Composting Basics Workshop",
            "type": "Workshop - Practical",
            "points": 300,
            "participants": [],
            "date": aug9.subtract(Duration(days: 9)),
            "endDate": aug9.subtract(Duration(days: 9)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/cooking.png",
            "description": "Learn the fundamentals of composting and how to turn your organic waste into valuable soil.",
            "location": "Posan Community Garden",
            "communityName": "Posan Community",
            "mapUrl": "https://maps.google.com/?q=Posan+Community+Garden",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'yangdong':
        return [
          {
            "id": "yd_recycling_drive",
            "title": "Recycling Awareness Drive",
            "type": "Campaign - Education",
            "points": 400,
            "participants": [],
            "date": aug9.add(Duration(days: 7)),
            "endDate": aug9.add(Duration(days: 7)).add(Duration(hours: 3)),
            "imageUrl": "assets/images/cleaning.png",
            "description": "Help spread awareness about recycling and waste management in our community.",
            "location": "Yangdong Community Hall",
            "communityName": "Yangdong Community",
            "mapUrl": "https://maps.google.com/?q=Yangdong+Community+Hall",
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
          {
            "id": "yd_beach_cleanup",
            "title": "Yangdong Beach Cleanup",
            "type": "Campaign - Restoration",
            "points": 700,
            "participants": [],
            "date": aug9.subtract(Duration(days: 5)),
            "endDate": aug9.subtract(Duration(days: 5)).add(Duration(hours: 3)),
            "imageUrl": "assets/images/river.png",
            "description": "Join us to clean up the beautiful Yangdong Beach and protect marine life.",
            "location": "Yangdong Beach",
            "communityName": "Yangdong Community",
            "mapUrl": "https://maps.google.com/?q=Yangdong+Beach",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
          {
            "id": "yd_sustainable_fashion",
            "title": "Sustainable Fashion Workshop",
            "type": "Workshop - Education",
            "points": 350,
            "participants": [],
            "date": aug9.subtract(Duration(days: 11)),
            "endDate": aug9.subtract(Duration(days: 11)).add(Duration(hours: 2)),
            "imageUrl": "assets/images/planning.png",
            "description": "Discover how to make eco-conscious choices in your wardrobe and reduce textile waste.",
            "location": "Yangdong Community Center",
            "communityName": "Yangdong Community",
            "mapUrl": "https://maps.google.com/?q=Yangdong+Community+Center",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      default:
        return [
          {
            "id": "default_activity",
            "title": "Community Environmental Day",
            "type": "Campaign - General",
            "points": 300,
            "participants": [],
            "date": aug9.add(Duration(days: 1)),
            "endDate": aug9.add(Duration(days: 1)).add(Duration(hours: 3)),
            "imageUrl": "assets/images/planning.png",
            "description": "A general community environmental awareness and action day.",
            "location": "Community Center",
            "communityName": "Community",
            "mapUrl": null,
            "isUpcoming": true,
            "isCompleted": false,
            "schoolId": schoolId,
          },
        ];
    }
  }

  Future<void> joinActivity(String schoolId, String activityId, String userId) async {
    try {
      print('🎯 ActivityService: User $userId joining activity $activityId');

      final activityDoc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }

      final activityData = activityDoc.data() as Map<String, dynamic>;
      final points = activityData['points'] ?? 0;

      print('💰 ActivityService: Activity offers $points points');

      await getActivitiesCollection(schoolId).doc(activityId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'participantCount': FieldValue.increment(1),
      });

      await _userService.addUserPoints(userId, points);
      await _userService.addUserAction(userId);
      await _userService.updateUserStreakFromDailyActivity(userId);

      print('✅ ActivityService: User $userId successfully joined activity and earned $points points');
    } catch (e) {
      print('❌ ActivityService: Error joining activity: $e');
      rethrow;
    }
  }

  Future<void> leaveActivity(String schoolId, String activityId, String userId) async {
    try {
      print('🚪 ActivityService: User $userId leaving activity $activityId');

      final activityDoc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }

      final activityData = activityDoc.data() as Map<String, dynamic>;
      final points = activityData['points'] ?? 0;

      print('💰 ActivityService: Activity offers $points points, removing from user');

      await getActivitiesCollection(schoolId).doc(activityId).update({
        'participants': FieldValue.arrayRemove([userId]),
        'participantCount': FieldValue.increment(-1),
      });

      await _userService.addUserPoints(userId, -points);

      print('✅ ActivityService: User $userId successfully left activity and lost $points points');
    } catch (e) {
      print('❌ ActivityService: Error leaving activity: $e');
      rethrow;
    }
  }

  Future<bool> isUserJoinedActivity(String schoolId, String activityId, String userId) async {
    try {
      final doc = await getActivitiesCollection(schoolId).doc(activityId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final participants = List<String>.from(data['participants'] ?? []);

      return participants.contains(userId);
    } catch (e) {
      print('❌ ActivityService: Error checking if user joined activity: $e');
      return false;
    }
  }

  Future<void> resetActivitiesWithCustomDates(String schoolId) async {
    final activitiesCollection = getActivitiesCollection(schoolId);
    final snapshot = await activitiesCollection.get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    print('🗑️ All activities deleted for $schoolId');

    final activities = _getSchoolSpecificActivities(schoolId);
    for (final activity in activities) {
      await activitiesCollection.doc(activity["id"] as String).set(activity);
    }
    print('✅ Recreated ${activities.length} activities for school $schoolId with new dates.');
  }
}