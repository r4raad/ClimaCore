import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ecore.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';

class ClimaGameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final UserService _userService = UserService();
  static final SchoolService _schoolService = SchoolService();

  // Get all active ecores
  static Future<List<Ecore>> getEcores() async {
    try {
      print('🗺️ Fetching ecores from Firebase...');
      final snapshot = await _firestore.collection('ecores').where('isActive', isEqualTo: true).get();
      
      final ecores = <Ecore>[];
      for (final doc in snapshot.docs) {
        try {
          final ecore = Ecore.fromMap(doc.id, doc.data());
          ecores.add(ecore);
        } catch (e) {
          print('❌ Error processing ecore ${doc.id}: $e');
        }
      }
      
      print('✅ Found ${ecores.length} active ecores');
      return ecores;
    } catch (e) {
      print('❌ Error fetching ecores: $e');
      return [];
    }
  }

  // Get ecore by ID
  static Future<Ecore?> getEcoreById(String ecoreId) async {
    try {
      final doc = await _firestore.collection('ecores').doc(ecoreId).get();
      if (doc.exists) {
        return Ecore.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching ecore: $e');
      return null;
    }
  }

  // Complete a mission
  static Future<bool> completeMission({
    required String ecoreId,
    required String missionId,
    required String userId,
    required String userName,
    required String proofImageUrl,
  }) async {
    try {
      print('🎯 Completing mission $missionId in ecore $ecoreId');
      
      // Get the ecore
      final ecore = await getEcoreById(ecoreId);
      if (ecore == null) {
        print('❌ Ecore not found');
        return false;
      }

      // Find the mission
      final missionIndex = ecore.missions.indexWhere((m) => m.id == missionId);
      if (missionIndex == -1) {
        print('❌ Mission not found');
        return false;
      }

      // Check if user has already completed 3 missions today
      final todayMissions = await _getUserTodayMissions(userId);
      if (todayMissions.length >= 3) {
        print('❌ User has already completed 3 missions today');
        return false;
      }

      // Update the mission
      final updatedMissions = List<EcoreMission>.from(ecore.missions);
      updatedMissions[missionIndex] = updatedMissions[missionIndex].copyWith(
        isCompleted: true,
        completedByUserId: userId,
        completedByUserName: userName,
        completedAt: DateTime.now(),
        proofImageUrl: proofImageUrl,
      );

      // Calculate total points
      final totalPoints = updatedMissions.fold(0, (sum, mission) => sum + mission.points);

      // Update the ecore
      await _firestore.collection('ecores').doc(ecoreId).update({
        'missions': updatedMissions.map((m) => m.toMap()).toList(),
        'totalPoints': totalPoints,
      });

      // Award points to user
      await _userService.addUserPoints(userId, updatedMissions[missionIndex].points);

      // Check if all missions are completed
      final allCompleted = updatedMissions.every((m) => m.isCompleted);
      if (allCompleted) {
        await _conquerEcore(ecoreId, userId);
      }

      print('✅ Mission completed successfully');
      return true;
    } catch (e) {
      print('❌ Error completing mission: $e');
      return false;
    }
  }

  // Conquer an ecore (when all missions are completed)
  static Future<bool> _conquerEcore(String ecoreId, String userId) async {
    try {
      print('🏆 Conquering ecore $ecoreId');
      
      // Get user and their school
      final user = await _userService.getUserById(userId);
      if (user == null || user.joinedSchoolId == null) {
        print('❌ User not found or not joined to a school');
        return false;
      }

      final school = await _schoolService.getSchoolById(user.joinedSchoolId!);
      if (school == null) {
        print('❌ School not found');
        return false;
      }

      // Get ecore to calculate total points
      final ecore = await getEcoreById(ecoreId);
      if (ecore == null) {
        print('❌ Ecore not found');
        return false;
      }

      // Set cooling time (30 minutes)
      final coolingTimeEnd = DateTime.now().add(Duration(minutes: 30));

      // Update ecore as conquered
      await _firestore.collection('ecores').doc(ecoreId).update({
        'conqueredBySchoolId': user.joinedSchoolId,
        'conqueredBySchoolName': school.name,
        'conqueredAt': DateTime.now(),
        'coolingTimeEnd': coolingTimeEnd,
      });

      // Award total points to the school (this would be handled by a separate service)
      // For now, we'll just log it
      print('🏆 Ecore conquered by ${school.name} for ${ecore.totalPoints} points');

      return true;
    } catch (e) {
      print('❌ Error conquering ecore: $e');
      return false;
    }
  }

  // Get user's missions completed today
  static Future<List<EcoreMission>> _getUserTodayMissions(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(Duration(days: 1));

      final snapshot = await _firestore
          .collection('ecores')
          .where('missions.completedByUserId', isEqualTo: userId)
          .get();

      final todayMissions = <EcoreMission>[];
      for (final doc in snapshot.docs) {
        final ecore = Ecore.fromMap(doc.id, doc.data());
        for (final mission in ecore.missions) {
          if (mission.completedByUserId == userId && 
              mission.completedAt != null &&
              mission.completedAt!.isAfter(startOfDay) &&
              mission.completedAt!.isBefore(endOfDay)) {
            todayMissions.add(mission);
          }
        }
      }

      return todayMissions;
    } catch (e) {
      print('❌ Error getting user today missions: $e');
      return [];
    }
  }

  // Get school rankings for ClimaGame
  static Future<List<Map<String, dynamic>>> getSchoolRankings() async {
    try {
      print('🏆 Fetching school rankings...');
      
      // Get all schools
      final schools = await _schoolService.getSchools();
      final rankings = <Map<String, dynamic>>[];

      for (final school in schools) {
        // Count conquered ecores for this school
        final conqueredEcores = await _firestore
            .collection('ecores')
            .where('conqueredBySchoolId', isEqualTo: school.id)
            .get();

        final conqueredCount = conqueredEcores.docs.length;
        
        if (conqueredCount > 0) {
                     rankings.add({
             'schoolId': school.id,
             'schoolName': school.name,
             'conqueredCount': conqueredCount,
             'schoolEmblem': school.imageUrl,
           });
        }
      }

      // Sort by conquered count (descending)
      rankings.sort((a, b) => b['conqueredCount'].compareTo(a['conqueredCount']));
      
      print('✅ Found ${rankings.length} schools with conquered ecores');
      return rankings;
    } catch (e) {
      print('❌ Error fetching school rankings: $e');
      return [];
    }
  }
} 