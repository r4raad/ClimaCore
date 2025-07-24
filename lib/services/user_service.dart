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
} 