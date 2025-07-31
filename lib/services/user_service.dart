import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Future<AppUser?> getUserById(String id) async {
    final doc = await usersCollection.doc(id).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> addUser(AppUser user) async {
    await usersCollection.doc(user.id).set(user.toMap());
  }

  Future<void> updateUserPoints(String userId, int points) async {
    await usersCollection.doc(userId).update({'points': points});
  }

  Future<void> addUserPoints(String userId, int pointsToAdd) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      final currentPoints = (doc.data() as Map<String, dynamic>)['points'] ?? 0;
      await usersCollection.doc(userId).update({'points': currentPoints + pointsToAdd});
    }
  }

  Future<void> updateUserActions(String userId, int actions) async {
    await usersCollection.doc(userId).update({'actions': actions});
  }

  Future<void> addUserAction(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      final currentActions = (doc.data() as Map<String, dynamic>)['actions'] ?? 0;
      await usersCollection.doc(userId).update({'actions': currentActions + 1});
    }
  }

  Future<void> updateUserStreak(String userId, int streak) async {
    await usersCollection.doc(userId).update({'streak': streak});
  }

  Future<void> updateWeekPoints(String userId, int weekPoints) async {
    await usersCollection.doc(userId).update({'weekPoints': weekPoints});
  }

  Future<void> addWeekPoints(String userId, int pointsToAdd) async {
    final doc = await usersCollection.doc(userId).get();
    if (doc.exists) {
      final currentWeekPoints = (doc.data() as Map<String, dynamic>)['weekPoints'] ?? 0;
      await usersCollection.doc(userId).update({'weekPoints': currentWeekPoints + pointsToAdd});
    }
  }

  Future<void> joinSchool(String userId, String schoolId) async {
    await usersCollection.doc(userId).update({'joinedSchoolId': schoolId});
  }

  Future<void> updateUserProfilePic(String userId, String profilePicUrl) async {
    await usersCollection.doc(userId).update({'profilePic': profilePicUrl});
  }

  Future<void> ensureDummyUsersExist() async {
    try {
      print('🔍 UserService: Checking if dummy users exist...');
      final snapshot = await usersCollection.get();
      
      if (snapshot.docs.length < 3) {
        print('📝 UserService: Not enough users found. Please add users directly to Firebase Firestore.');
        print('📝 UserService: You can add users through the Firebase Console or create them programmatically.');
      } else {
        print('✅ UserService: Sufficient users already exist in Firebase');
      }
    } catch (e) {
      print('❌ UserService: Error checking users: $e');
      rethrow;
    }
  }
} 