import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/ecore.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/school_service.dart';

class ClimaGameService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();
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

  // Create sample ecores for testing
  static Future<void> createSampleEcores() async {
    try {
      print('🎮 Creating sample ecores...');
      
      final sampleEcores = [
        {
          'name': 'Core 001',
          'latitude': 37.7749,
          'longitude': -122.4194,
          'missions': [
            {
              'id': 'mission_001_1',
              'title': 'Plogging',
              'description': 'Pick up trash while walking or jogging',
              'summary': 'Plogging is a combination of jogging and picking up litter. It\'s a great way to exercise while helping the environment.',
              'tips': [
                'Bring a reusable bag for collecting trash',
                'Wear gloves for safety',
                'Start with a short route',
                'Invite friends to join you'
              ],
              'categories': ['Reduce Waste', 'Improve Health', 'Community Action'],
              'points': 100,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
              'id': 'mission_001_2',
              'title': 'Plant a Tree',
              'description': 'Plant a native tree in your community',
              'summary': 'Trees absorb carbon dioxide and provide oxygen. Planting native trees helps local ecosystems thrive.',
              'tips': [
                'Choose native species for your area',
                'Plant in appropriate locations',
                'Water regularly after planting',
                'Consider joining a community planting event'
              ],
              'categories': ['Reduce Emissions', 'Improve Air Quality', 'Biodiversity'],
              'points': 150,
              'imageUrl': 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=400',
            },
            {
              'id': 'mission_001_3',
              'title': 'Use Public Transport',
              'description': 'Take public transportation instead of driving',
              'summary': 'Public transportation reduces carbon emissions and traffic congestion while saving money on fuel.',
              'tips': [
                'Plan your route in advance',
                'Download transit apps for real-time updates',
                'Consider walking or biking for short trips',
                'Share rides with classmates when possible'
              ],
              'categories': ['Reduce Emissions', 'Save Money', 'Improve Health'],
              'points': 75,
              'imageUrl': 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400',
            },
            {
              'id': 'mission_001_4',
              'title': 'Reduce Plastic Use',
              'description': 'Replace single-use plastics with reusable alternatives',
              'summary': 'Plastic pollution is a major environmental issue. Switching to reusable items helps reduce waste.',
              'tips': [
                'Use a reusable water bottle',
                'Bring your own shopping bags',
                'Choose products with less packaging',
                'Support businesses that use eco-friendly packaging'
              ],
              'categories': ['Reduce Waste', 'Ocean Protection', 'Sustainable Living'],
              'points': 80,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
              'id': 'mission_001_5',
              'title': 'Energy Conservation',
              'description': 'Reduce energy consumption at home or school',
              'summary': 'Conserving energy reduces greenhouse gas emissions and saves money on utility bills.',
              'tips': [
                'Turn off lights when leaving rooms',
                'Unplug electronics when not in use',
                'Use energy-efficient appliances',
                'Adjust thermostat settings appropriately'
              ],
              'categories': ['Reduce Emissions', 'Save Money', 'Climate Action'],
              'points': 90,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
          ],
        },
        {
          'name': 'Core 002',
          'latitude': 37.7849,
          'longitude': -122.4094,
          'missions': [
            {
              'id': 'mission_002_1',
              'title': 'Start Composting',
              'description': 'Begin composting organic waste',
              'summary': 'Composting reduces methane emissions from landfills and creates nutrient-rich soil.',
              'tips': [
                'Start with kitchen scraps',
                'Use a small bin for indoor composting',
                'Learn what can and cannot be composted',
                'Share compost with community gardens'
              ],
              'categories': ['Reduce Waste', 'Soil Health', 'Circular Economy'],
              'points': 120,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
              'id': 'mission_002_2',
              'title': 'Support Local Farmers',
              'description': 'Buy produce from local farmers markets',
              'summary': 'Local food reduces transportation emissions and supports your community\'s economy.',
              'tips': [
                'Find farmers markets in your area',
                'Plan meals around seasonal produce',
                'Ask farmers about their growing practices',
                'Share the experience with friends'
              ],
              'categories': ['Reduce Emissions', 'Support Local Economy', 'Healthy Eating'],
              'points': 85,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
              'id': 'mission_002_3',
              'title': 'Educate Others',
              'description': 'Share climate knowledge with friends and family',
              'summary': 'Education is key to climate action. Sharing knowledge helps others make informed decisions.',
              'tips': [
                'Start conversations about climate change',
                'Share reliable information sources',
                'Lead by example with your actions',
                'Be patient and respectful in discussions'
              ],
              'categories': ['Education', 'Community Action', 'Climate Awareness'],
              'points': 60,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
              'id': 'mission_002_4',
              'title': 'Reduce Water Usage',
              'description': 'Implement water-saving practices',
              'summary': 'Water conservation helps preserve this precious resource and reduces energy used in water treatment.',
              'tips': [
                'Fix leaky faucets and pipes',
                'Take shorter showers',
                'Use water-efficient appliances',
                'Collect rainwater for plants'
              ],
              'categories': ['Water Conservation', 'Resource Management', 'Sustainability'],
              'points': 70,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
            {
              'id': 'mission_002_5',
              'title': 'Join Climate Action',
              'description': 'Participate in climate advocacy or community events',
              'summary': 'Collective action is powerful. Joining climate initiatives amplifies your impact.',
              'tips': [
                'Find local climate action groups',
                'Attend community meetings',
                'Write to local representatives',
                'Participate in climate strikes or events'
              ],
              'categories': ['Community Action', 'Advocacy', 'Climate Justice'],
              'points': 110,
              'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
            },
          ],
        },
      ];

      for (final ecoreData in sampleEcores) {
        final ecoreId = _uuid.v4();
        final missions = (ecoreData['missions'] as List).map((m) => EcoreMission.fromMap(m)).toList();
        final totalPoints = missions.fold(0, (sum, mission) => sum + mission.points);

                 final ecore = Ecore(
           id: ecoreId,
           name: ecoreData['name'] as String,
           latitude: (ecoreData['latitude'] as num).toDouble(),
           longitude: (ecoreData['longitude'] as num).toDouble(),
           missions: missions,
           totalPoints: totalPoints,
           isActive: true,
           createdAt: DateTime.now(),
         );

        await _firestore.collection('ecores').doc(ecoreId).set(ecore.toMap());
      }

      print('✅ Sample ecores created successfully');
    } catch (e) {
      print('❌ Error creating sample ecores: $e');
      rethrow;
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