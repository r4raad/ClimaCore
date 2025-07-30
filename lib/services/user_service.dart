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

  Future<void> createDummyUsers() async {
    try {
      // Get current user information
      final currentUser = FirebaseAuth.instance.currentUser;
      String currentUserFirstName = 'User';
      String currentUserLastName = '';
      
      if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
        final nameParts = currentUser.displayName!.trim().split(' ');
        currentUserFirstName = nameParts.first;
        currentUserLastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      }
      
      final dummyUsers = [
        AppUser(
          id: currentUser?.uid ?? 'dummy_user_1',
          firstName: currentUserFirstName,
          lastName: currentUserLastName,
          points: 4245,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
          actions: 6,
          streak: 24,
          weekPoints: 400,
          weekGoal: 800,
        ),
        AppUser(
          id: 'dummy_user_2',
          firstName: 'Angelica',
          lastName: 'Gomes',
          points: 5600,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
          actions: 85,
          streak: 18,
          weekPoints: 650,
          weekGoal: 800,
        ),
        AppUser(
          id: 'dummy_user_3',
          firstName: 'Gong',
          lastName: 'Yoo',
          points: 5560,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          actions: 80,
          streak: 15,
          weekPoints: 580,
          weekGoal: 800,
        ),
        AppUser(
          id: 'dummy_user_4',
          firstName: 'Son',
          lastName: 'Heung-min',
          points: 1160,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
          actions: 16,
          streak: 8,
          weekPoints: 1160,
          weekGoal: 800,
        ),
        AppUser(
          id: 'dummy_user_5',
          firstName: 'Christine',
          lastName: 'Gomes',
          points: 3800,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
          actions: 45,
          streak: 12,
          weekPoints: 320,
          weekGoal: 600,
        ),
        AppUser(
          id: 'dummy_user_6',
          firstName: 'Christalia',
          lastName: 'Larson',
          points: 3695,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
          actions: 42,
          streak: 10,
          weekPoints: 310,
          weekGoal: 600,
        ),
      ];

      for (final user in dummyUsers) {
        await addUser(user);
      }
      
      print('✅ Dummy users created successfully in Firebase');
    } catch (e) {
      print('❌ Error creating dummy users: $e');
      rethrow;
    }
  }

  Future<void> ensureDummyUsersExist() async {
    try {
      print('🔍 UserService: Checking if dummy users exist...');
      final snapshot = await usersCollection.get();
      
      if (snapshot.docs.length < 3) {
        print('📝 UserService: Not enough users found, creating dummy users...');
        await createDummyUsers();
      } else {
        print('✅ UserService: Sufficient users already exist in Firebase');
      }
    } catch (e) {
      print('❌ UserService: Error ensuring dummy users exist: $e');
      rethrow;
    }
  }
} 