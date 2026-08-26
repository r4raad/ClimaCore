import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../models/ecore.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';

class ClimaGameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final UserService _userService = UserService();
  static final SchoolService _schoolService = SchoolService();

  static Future<List<Ecore>> getVisibleEcores() async {
    try {
      print('🗺️ Fetching visible ecores from Firebase...');
      final snapshot = await _firestore
          .collection('ecores')
          .where('isActive', isEqualTo: true)
          .where('isDiscovered', isEqualTo: true)
          .get();

      final ecores = <Ecore>[];
      for (final doc in snapshot.docs) {
        try {
          final ecore = Ecore.fromMap(doc.id, doc.data());
          ecores.add(ecore);
        } catch (e) {
          print('❌ Error processing ecore ${doc.id}: $e');
        }
      }

      print('✅ Found ${ecores.length} visible ecores');
      return ecores;
    } catch (e) {
      print('❌ Error fetching visible ecores: $e');
      return [];
    }
  }

  static Future<List<Ecore>> getAllEcores() async {
    try {
      print('🗺️ Fetching all ecores from Firebase...');
      final snapshot = await _firestore
          .collection('ecores')
          .where('isActive', isEqualTo: true)
          .get();

      final ecores = <Ecore>[];
      for (final doc in snapshot.docs) {
        try {
          final ecore = Ecore.fromMap(doc.id, doc.data());
          ecores.add(ecore);
        } catch (e) {
          print('❌ Error processing ecore ${doc.id}: $e');
        }
      }

      print('✅ Found ${ecores.length} total ecores');
      return ecores;
    } catch (e) {
      print('❌ Error fetching all ecores: $e');
      return [];
    }
  }

  static Future<List<Ecore>> checkAndDiscoverEcores({
    required String userId,
    required double userLatitude,
    required double userLongitude,
    double proximityThreshold = 100.0,
  }) async {
    try {
      print('🔍 Checking for undiscovered ecores near user...');

      final snapshot = await _firestore
          .collection('ecores')
          .where('isActive', isEqualTo: true)
          .where('isDiscovered', isEqualTo: false)
          .get();

      final discoveredEcores = <Ecore>[];

      for (final doc in snapshot.docs) {
        final ecore = Ecore.fromMap(doc.id, doc.data());

        final distance = _calculateDistance(
          userLatitude,
          userLongitude,
          ecore.latitude,
          ecore.longitude,
        );

        if (distance <= proximityThreshold) {
          print('🎯 Discovering ecore ${ecore.id} at distance ${distance.toStringAsFixed(2)}m');

          final user = await _userService.getUserById(userId);
          final schoolId = user?.joinedSchoolId;

          if (schoolId != null) {

            await _firestore.collection('ecores').doc(ecore.id).update({
              'isDiscovered': true,
              'discoveredAt': FieldValue.serverTimestamp(),
              'discoveredBySchoolId': schoolId,
            });

            discoveredEcores.add(ecore.copyWith(
              isDiscovered: true,
              discoveredAt: DateTime.now(),
              discoveredBySchoolId: schoolId,
            ));
          }
        }
      }

      print('✅ Discovered ${discoveredEcores.length} new ecores');
      return discoveredEcores;

    } catch (e) {
      print('❌ Error checking for undiscovered ecores: $e');
      return [];
    }
  }

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

  static Future<List<Map<String, dynamic>>> getSchoolRankings() async {
    try {
      print('🏆 Fetching school rankings...');

      final futures = await Future.wait([
        _firestore.collection('schools').get(),
        _firestore.collection('ecores').where('conqueredBySchoolId', isNull: false).get(),
      ]);

      final schoolsSnapshot = futures[0];
      final conqueredEcoresSnapshot = futures[1];

      final schoolConqueredCounts = <String, int>{};
      for (final ecoreDoc in conqueredEcoresSnapshot.docs) {
        final schoolId = ecoreDoc.data()['conqueredBySchoolId'] as String?;
        if (schoolId != null) {
          schoolConqueredCounts[schoolId] = (schoolConqueredCounts[schoolId] ?? 0) + 1;
        }
      }

      final rankings = <Map<String, dynamic>>[];

      for (final schoolDoc in schoolsSnapshot.docs) {
        final schoolId = schoolDoc.id;
        final schoolData = schoolDoc.data();
        final conqueredCount = schoolConqueredCounts[schoolId] ?? 0;

        rankings.add({
          'schoolId': schoolId,
          'schoolName': schoolData['name'] ?? 'Unknown School',
          'conqueredEcores': conqueredCount,
          'schoolImage': schoolData['imageUrl'],
        });
      }

      rankings.sort((a, b) => (b['conqueredEcores'] as int).compareTo(a['conqueredEcores'] as int));

      print('✅ Found ${rankings.length} schools in rankings');
      return rankings;

    } catch (e) {
      print('❌ Error fetching school rankings: $e');
      return [];
    }
  }

  static Future<bool> canUserDoMission(String userId) async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dailyMissions')
          .doc(todayKey)
          .get();

      if (!doc.exists) return true;

      final data = doc.data()!;
      final missionCount = data['missionCount'] ?? 0;

      return missionCount < 3;
    } catch (e) {
      print('❌ Error checking user mission limit: $e');
      return false;
    }
  }

  static Future<int> getUserDailyMissionCount(String userId) async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dailyMissions')
          .doc(todayKey)
          .get();

      if (!doc.exists) return 0;

      final data = doc.data()!;
      return data['missionCount'] ?? 0;
    } catch (e) {
      print('❌ Error getting user daily mission count: $e');
      return 0;
    }
  }

  static Future<bool> completeMission({
    required String userId,
    required String userName,
    required String ecoreId,
    required String missionId,
    String? proofImageUrl,
  }) async {
    try {
      print('🎯 Completing mission $missionId in ecore $ecoreId');

      final ecore = await getEcoreById(ecoreId);
      if (ecore == null) {
        print('❌ Ecore not found');
        return false;
      }

      final missionIndex = ecore.missions.indexWhere((m) => m.id == missionId);
      if (missionIndex == -1) {
        print('❌ Mission not found');
        return false;
      }

      final todayMissions = await _getUserTodayMissions(userId);
      if (todayMissions.length >= 3) {
        print('❌ User has already completed 3 missions today');
        return false;
      }

      final user = await _userService.getUserById(userId);
      if (user == null || user.joinedSchoolId == null) {
        print('❌ User not found or not joined to a school');
        return false;
      }

      final updatedMissions = List<EcoreMission>.from(ecore.missions);
      updatedMissions[missionIndex] = updatedMissions[missionIndex].copyWith(
        isCompleted: true,
        completedByUserId: userId,
        completedByUserName: userName,
        completedAt: DateTime.now(),
        proofImageUrl: proofImageUrl,
      );

      final totalPoints = updatedMissions.fold(0, (sum, mission) => sum + mission.points);

      await _firestore.collection('ecores').doc(ecoreId).update({
        'missions': updatedMissions.map((m) => m.toMap()).toList(),
        'totalPoints': totalPoints,
      });

      await _userService.addUserPoints(userId, updatedMissions[missionIndex].points);
      await _userService.updateUserStreakFromDailyActivity(userId);

      await _updateUserDailyMissionCount(userId);

      final allCompleted = updatedMissions.every((m) => m.isCompleted);
      if (allCompleted) {

        final winningSchoolId = await _determineCompetitionWinner(ecoreId);
        if (winningSchoolId != null) {
          await _conquerEcore(ecoreId, winningSchoolId);
        }
      }

      print('✅ Mission completed successfully');
      return true;

    } catch (e) {
      print('❌ Error completing mission: $e');
      return false;
    }
  }

  static Future<String?> _determineCompetitionWinner(String ecoreId) async {
    try {
      final ecore = await getEcoreById(ecoreId);
      if (ecore == null) return null;

      final schoolMissionCounts = <String, int>{};
      final schoolLastCompletion = <String, DateTime>{};

      for (final mission in ecore.missions) {
        if (mission.isCompleted && mission.completedByUserId != null) {

          final user = await _userService.getUserById(mission.completedByUserId!);
          if (user?.joinedSchoolId != null) {
            final schoolId = user!.joinedSchoolId!;
            schoolMissionCounts[schoolId] = (schoolMissionCounts[schoolId] ?? 0) + 1;

            if (mission.completedAt != null) {
              final currentLast = schoolLastCompletion[schoolId];
              if (currentLast == null || mission.completedAt!.isAfter(currentLast)) {
                schoolLastCompletion[schoolId] = mission.completedAt!;
              }
            }
          }
        }
      }

      int maxMissions = 0;
      String? winningSchoolId;
      DateTime? winningLastCompletion;

      for (final entry in schoolMissionCounts.entries) {
        if (entry.value > maxMissions) {
          maxMissions = entry.value;
          winningSchoolId = entry.key;
          winningLastCompletion = schoolLastCompletion[entry.key];
        } else if (entry.value == maxMissions && winningLastCompletion != null) {

          final thisLastCompletion = schoolLastCompletion[entry.key];
          if (thisLastCompletion != null && thisLastCompletion.isAfter(winningLastCompletion)) {
            winningSchoolId = entry.key;
            winningLastCompletion = thisLastCompletion;
          }
        }
      }

      if (maxMissions == 5) {
        return winningSchoolId;
      }

      return null;
    } catch (e) {
      print('❌ Error determining competition winner: $e');
      return null;
    }
  }

  static Future<void> _conquerEcore(String ecoreId, String schoolId) async {
    try {
      print('🏆 School $schoolId conquering ecore $ecoreId');

      final school = await _schoolService.getSchoolById(schoolId);
      final schoolName = school?.name ?? 'Unknown School';

      final coolingTimeEnd = DateTime.now().add(Duration(minutes: 30));

      await _firestore.collection('ecores').doc(ecoreId).update({
        'conqueredBySchoolId': schoolId,
        'conqueredBySchoolName': schoolName,
        'conqueredAt': FieldValue.serverTimestamp(),
        'coolingTimeEnd': Timestamp.fromDate(coolingTimeEnd),
      });

      print('✅ Ecore conquered successfully');
    } catch (e) {
      print('❌ Error conquering ecore: $e');
    }
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  static Future<List<String>> _getUserTodayMissions(String userId) async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('dailyMissions')
          .doc(todayKey)
          .get();

      if (!doc.exists) return [];

      final data = doc.data()!;
      return List<String>.from(data['completedMissions'] ?? []);
    } catch (e) {
      print('❌ Error getting user today missions: $e');
      return [];
    }
  }

  static Future<void> _updateUserDailyMissionCount(String userId) async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('dailyMissions')
          .doc(todayKey)
          .set({
        'missionCount': FieldValue.increment(1),
        'lastMissionAt': FieldValue.serverTimestamp(),
        'date': todayKey,
      }, SetOptions(merge: true));

    } catch (e) {
      print('❌ Error updating user daily mission count: $e');
    }
  }
}