import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';

class ActivityService {
  CollectionReference getActivitiesCollection(String schoolId) {
    return FirebaseFirestore.instance.collection('schools').doc(schoolId).collection('activities');
  }

  Future<List<Activity>> getActivities(String schoolId, {int limit = 20, DocumentSnapshot? startAfter}) async {
    try {
      Query query = getActivitiesCollection(schoolId).orderBy('date', descending: false);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.limit(limit);
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => 
        Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
    } catch (e) {
      print('Error fetching activities: $e');
      rethrow;
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

  Future<void> joinActivity(String schoolId, String activityId, String userId) async {
    try {
      await getActivitiesCollection(schoolId).doc(activityId).update({
        'participants': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Error joining activity: $e');
      rethrow;
    }
  }

  Future<void> leaveActivity(String schoolId, String activityId, String userId) async {
    try {
      await getActivitiesCollection(schoolId).doc(activityId).update({
        'participants': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Error leaving activity: $e');
      rethrow;
    }
  }
} 