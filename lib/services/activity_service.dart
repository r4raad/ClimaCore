import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';

class ActivityService {
  CollectionReference getActivitiesCollection(String schoolId) {
    return FirebaseFirestore.instance.collection('schools').doc(schoolId).collection('activities');
  }

  Future<List<Activity>> getActivities(String schoolId) async {
    final snapshot = await getActivitiesCollection(schoolId).orderBy('date', descending: false).get();
    return snapshot.docs.map((doc) => Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> addActivity(String schoolId, Activity activity) async {
    await getActivitiesCollection(schoolId).doc(activity.id).set(activity.toMap());
  }

  Future<Activity?> getActivityById(String schoolId, String activityId) async {
    final doc = await getActivitiesCollection(schoolId).doc(activityId).get();
    if (doc.exists) {
      return Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }
} 