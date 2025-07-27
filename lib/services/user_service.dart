import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

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

  Future<void> joinSchool(String userId, String schoolId) async {
    await usersCollection.doc(userId).update({'joinedSchoolId': schoolId});
  }

  Future<void> createDummyUsers() async {
    try {
      final dummyUsers = [
        AppUser(
          id: 'dummy_user_1',
          name: 'Emma Johnson',
          points: 1250,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
          actions: 15,
          streak: 7,
          weekPoints: 320,
          weekGoal: 500,
        ),
        AppUser(
          id: 'dummy_user_2',
          name: 'Alex Chen',
          points: 980,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
          actions: 12,
          streak: 5,
          weekPoints: 280,
          weekGoal: 400,
        ),
        AppUser(
          id: 'dummy_user_3',
          name: 'Sarah Williams',
          points: 2100,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
          actions: 25,
          streak: 12,
          weekPoints: 450,
          weekGoal: 600,
        ),
        AppUser(
          id: 'dummy_user_4',
          name: 'Michael Brown',
          points: 750,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
          actions: 8,
          streak: 3,
          weekPoints: 180,
          weekGoal: 300,
        ),
        AppUser(
          id: 'dummy_user_5',
          name: 'Lisa Garcia',
          points: 1650,
          savedPosts: [],
          likedPosts: [],
          profilePic: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
          actions: 18,
          streak: 9,
          weekPoints: 380,
          weekGoal: 450,
        ),
      ];

      for (final user in dummyUsers) {
        await addUser(user);
      }
      
      print('Dummy users created successfully');
    } catch (e) {
      print('Error creating dummy users: $e');
      rethrow;
    }
  }
} 