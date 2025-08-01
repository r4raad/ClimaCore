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

  // Create comprehensive sample game (2-month gameplay)
  static Future<void> createComprehensiveSampleGame() async {
    try {
      print('🎮 Creating comprehensive sample game...');
      
      // Clear existing data first
      await _clearExistingGameData();
      
      // Create schools for the game
      await _createSampleSchools();
      
      // Create comprehensive ecores with seasonal missions
      await _createSeasonalEcores();
      
      // Create dynamic events and challenges
      await _createGameEvents();
      
      // Set up initial game state
      await _setupGameState();
      
      print('✅ Comprehensive sample game created successfully!');
    } catch (e) {
      print('❌ Error creating sample game: $e');
      rethrow;
    }
  }

  // Clear existing game data
  static Future<void> _clearExistingGameData() async {
    try {
      final collections = ['ecores', 'schools', 'gameEvents', 'gameState'];
      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      print('🧹 Cleared existing game data');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  // Create sample schools for competition
  static Future<void> _createSampleSchools() async {
    final schools = [
      {
        'id': 'school_001',
        'name': 'Green Valley High',
        'motto': 'Sustainability First',
        'memberCount': 1250,
        'totalPoints': 8500,
        'conqueredEcores': 3,
        'imageUrl': '',
        'createdAt': DateTime.now(),
      },
      {
        'id': 'school_002',
        'name': 'EcoTech Academy',
        'motto': 'Innovation for Earth',
        'memberCount': 980,
        'totalPoints': 7200,
        'conqueredEcores': 2,
        'imageUrl': '',
        'createdAt': DateTime.now(),
      },
      {
        'id': 'school_003',
        'name': 'Nature Bridge School',
        'motto': 'Connecting with Nature',
        'memberCount': 750,
        'totalPoints': 5400,
        'conqueredEcores': 1,
        'imageUrl': '',
        'createdAt': DateTime.now(),
      },
      {
        'id': 'school_004',
        'name': 'Climate Champions Institute',
        'motto': 'Leading the Change',
        'memberCount': 1100,
        'totalPoints': 6800,
        'conqueredEcores': 2,
        'imageUrl': '',
        'createdAt': DateTime.now(),
      },
    ];

    for (final school in schools) {
      await _firestore.collection('schools').doc(school['id'] as String).set(school);
    }
    print('🏫 Created ${schools.length} competing schools');
  }

  // Create seasonal ecores with comprehensive missions
  static Future<void> _createSeasonalEcores() async {
    final ecores = [
      // SPRING SEASON (Month 1)
      {
        'id': 'ecore_spring_001',
        'name': 'Spring Renewal Core',
        'latitude': 37.7749,
        'longitude': -122.4194,
        'season': 'Spring',
        'month': 1,
        'missions': [
          {
            'id': 'mission_spring_001_001',
            'title': 'Spring Cleanup Drive',
            'description': 'Organize a community spring cleanup event',
            'summary': 'Spring is the perfect time to clean up our communities and prepare for new growth.',
            'tips': [
              'Coordinate with local authorities',
              'Provide safety equipment',
              'Document the cleanup',
              'Recycle collected materials'
            ],
            'categories': ['Community Service', 'Waste Reduction', 'Spring'],
            'points': 150,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': '4-6 hours',
          },
          {
            'id': 'mission_spring_001_002',
            'title': 'Plant Native Flowers',
            'description': 'Plant native wildflowers to support local pollinators',
            'summary': 'Native flowers provide essential food for bees, butterflies, and other pollinators.',
            'tips': [
              'Choose native species',
              'Plant in sunny locations',
              'Water regularly',
              'Avoid pesticides'
            ],
            'categories': ['Biodiversity', 'Spring', 'Local Ecosystem'],
            'points': 120,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Easy',
            'estimatedTime': '2-3 hours',
          },
          {
            'id': 'mission_spring_001_003',
            'title': 'Start a Compost Bin',
            'description': 'Create a compost system for organic waste',
            'summary': 'Composting reduces waste and creates nutrient-rich soil for gardens.',
            'tips': [
              'Choose a suitable location',
              'Layer green and brown materials',
              'Turn regularly',
              'Keep it moist'
            ],
            'categories': ['Waste Reduction', 'Soil Health', 'Spring'],
            'points': 100,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Easy',
            'estimatedTime': '1-2 hours',
          },
          {
            'id': 'mission_spring_001_004',
            'title': 'Energy Audit Challenge',
            'description': 'Conduct a comprehensive home energy audit',
            'summary': 'Identify energy inefficiencies and implement improvements.',
            'tips': [
              'Check for air leaks',
              'Inspect insulation',
              'Review appliance efficiency',
              'Create an action plan'
            ],
            'categories': ['Energy Efficiency', 'Cost Savings', 'Spring'],
            'points': 180,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Hard',
            'estimatedTime': '6-8 hours',
          },
          {
            'id': 'mission_spring_001_005',
            'title': 'Bike to Work Week',
            'description': 'Use cycling as primary transportation for one week',
            'summary': 'Reduce carbon emissions while improving health and saving money.',
            'tips': [
              'Plan safe routes',
              'Check weather forecasts',
              'Maintain your bike',
              'Track your progress'
            ],
            'categories': ['Transportation', 'Health', 'Spring'],
            'points': 200,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': '7 days',
          },
        ],
        'totalPoints': 750,
        'isActive': true,
        'createdAt': DateTime.now(),
        'conqueredBySchoolId': 'school_001',
        'conqueredBySchoolName': 'Green Valley High',
        'conqueredAt': DateTime.now().subtract(Duration(days: 5)),
      },
      
      // SUMMER SEASON (Month 2)
      {
        'id': 'ecore_summer_001',
        'name': 'Summer Sustainability Core',
        'latitude': 37.7849,
        'longitude': -122.4094,
        'season': 'Summer',
        'month': 2,
        'missions': [
          {
            'id': 'mission_summer_001_001',
            'title': 'Solar Energy Project',
            'description': 'Install or advocate for solar energy solutions',
            'summary': 'Harness the power of the sun to reduce fossil fuel dependence.',
            'tips': [
              'Research local incentives',
              'Calculate energy needs',
              'Choose reputable installers',
              'Monitor performance'
            ],
            'categories': ['Renewable Energy', 'Summer', 'Technology'],
            'points': 250,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Hard',
            'estimatedTime': '2-4 weeks',
          },
          {
            'id': 'mission_summer_001_002',
            'title': 'Water Conservation Campaign',
            'description': 'Implement comprehensive water-saving measures',
            'summary': 'Summer is peak water usage season - perfect time to conserve.',
            'tips': [
              'Fix leaky faucets',
              'Install water-efficient fixtures',
              'Collect rainwater',
              'Use drought-resistant plants'
            ],
            'categories': ['Water Conservation', 'Summer', 'Resource Management'],
            'points': 150,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': '3-5 days',
          },
          {
            'id': 'mission_summer_001_003',
            'title': 'Community Garden Initiative',
            'description': 'Start or participate in a community garden project',
            'summary': 'Community gardens provide fresh food and build stronger communities.',
            'tips': [
              'Find local garden groups',
              'Start with easy crops',
              'Share knowledge',
              'Organize work parties'
            ],
            'categories': ['Local Food', 'Community', 'Summer'],
            'points': 180,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': 'Ongoing',
          },
          {
            'id': 'mission_summer_001_004',
            'title': 'Zero Waste Challenge',
            'description': 'Achieve zero waste for one month',
            'summary': 'Eliminate all waste through reduction, reuse, and recycling.',
            'tips': [
              'Audit your waste',
              'Find bulk stores',
              'Compost everything',
              'Refuse single-use items'
            ],
            'categories': ['Waste Reduction', 'Summer', 'Lifestyle'],
            'points': 300,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Hard',
            'estimatedTime': '30 days',
          },
          {
            'id': 'mission_summer_001_005',
            'title': 'Climate Education Workshop',
            'description': 'Organize a climate change education event',
            'summary': 'Share knowledge and inspire action in your community.',
            'tips': [
              'Choose engaging topics',
              'Invite local experts',
              'Make it interactive',
              'Provide action steps'
            ],
            'categories': ['Education', 'Community', 'Summer'],
            'points': 200,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': '1-2 weeks',
          },
        ],
        'totalPoints': 1080,
        'isActive': true,
        'createdAt': DateTime.now(),
      },
      
      // ADDITIONAL CORES FOR GAME DEPTH
      {
        'id': 'ecore_urban_001',
        'name': 'Urban Green Core',
        'latitude': 37.7949,
        'longitude': -122.3994,
        'season': 'All Year',
        'month': 1,
        'missions': [
          {
            'id': 'mission_urban_001_001',
            'title': 'Green Roof Project',
            'description': 'Advocate for or implement green roof systems',
            'summary': 'Green roofs reduce urban heat island effect and improve air quality.',
            'points': 220,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Hard',
            'estimatedTime': '1-2 months',
          },
          {
            'id': 'mission_urban_001_002',
            'title': 'Public Transport Campaign',
            'description': 'Promote and increase public transportation usage',
            'summary': 'Reduce traffic congestion and emissions through better transit.',
            'points': 160,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': 'Ongoing',
          },
        ],
        'totalPoints': 380,
        'isActive': true,
        'createdAt': DateTime.now(),
      },
      
      {
        'id': 'ecore_ocean_001',
        'name': 'Ocean Protection Core',
        'latitude': 37.8049,
        'longitude': -122.3894,
        'season': 'All Year',
        'month': 2,
        'missions': [
          {
            'id': 'mission_ocean_001_001',
            'title': 'Beach Cleanup Initiative',
            'description': 'Organize regular beach cleanup events',
            'summary': 'Protect marine life by removing plastic and debris from beaches.',
            'points': 140,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Easy',
            'estimatedTime': '3-4 hours',
          },
          {
            'id': 'mission_ocean_001_002',
            'title': 'Plastic-Free Lifestyle',
            'description': 'Eliminate single-use plastics from daily life',
            'summary': 'Reduce plastic pollution that harms ocean ecosystems.',
            'points': 180,
            'imageUrl': '',
            'isCompleted': false,
            'difficulty': 'Medium',
            'estimatedTime': 'Ongoing',
          },
        ],
        'totalPoints': 320,
        'isActive': true,
        'createdAt': DateTime.now(),
      },
    ];

    for (final ecoreData in ecores) {
      await _firestore.collection('ecores').doc(ecoreData['id'] as String).set(ecoreData);
      print('✅ Created ecore: ${ecoreData['name']}');
    }
    print('🗺️ Created ${ecores.length} comprehensive ecores');
  }

  // Create dynamic game events
  static Future<void> _createGameEvents() async {
    final events = [
      {
        'id': 'event_001',
        'title': 'Spring Sustainability Challenge',
        'description': 'Complete 5 spring missions to unlock special rewards',
        'startDate': DateTime.now(),
        'endDate': DateTime.now().add(Duration(days: 30)),
        'reward': 'Special Spring Badge + 500 bonus points',
        'isActive': true,
        'participants': ['school_001', 'school_002', 'school_003'],
      },
      {
        'id': 'event_002',
        'title': 'Summer Innovation Contest',
        'description': 'Schools compete to create the most innovative climate solution',
        'startDate': DateTime.now().add(Duration(days: 35)),
        'endDate': DateTime.now().add(Duration(days: 65)),
        'reward': 'Innovation Trophy + 1000 bonus points',
        'isActive': false,
        'participants': ['school_001', 'school_002', 'school_003', 'school_004'],
      },
      {
        'id': 'event_003',
        'title': 'Community Impact Award',
        'description': 'Recognize schools making the biggest community impact',
        'startDate': DateTime.now().add(Duration(days: 70)),
        'endDate': DateTime.now().add(Duration(days: 100)),
        'reward': 'Community Impact Trophy + 750 bonus points',
        'isActive': false,
        'participants': ['school_001', 'school_002', 'school_003', 'school_004'],
      },
    ];

    for (final event in events) {
      await _firestore.collection('gameEvents').doc(event['id'] as String).set(event);
    }
    print('🎉 Created ${events.length} dynamic game events');
  }

  // Set up initial game state
  static Future<void> _setupGameState() async {
    final gameState = {
      'currentSeason': 'Spring',
      'currentMonth': 1,
      'totalDaysPlayed': 0,
      'activeSchools': 4,
      'totalMissionsCompleted': 0,
      'totalPointsAwarded': 0,
      'gameStartDate': DateTime.now(),
      'nextSeasonDate': DateTime.now().add(Duration(days: 30)),
      'leaderboardLastUpdated': DateTime.now(),
      'activeEvents': 1,
      'upcomingEvents': 2,
    };

    await _firestore.collection('gameState').doc('current').set(gameState);
    print('🎮 Game state initialized');
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

      // Get all ecores and filter locally since Firestore doesn't support array queries well
      final snapshot = await _firestore.collection('ecores').get();

      final todayMissions = <EcoreMission>[];
      for (final doc in snapshot.docs) {
        try {
          final ecore = Ecore.fromMap(doc.id, doc.data());
          for (final mission in ecore.missions) {
            if (mission.completedByUserId == userId && 
                mission.completedAt != null &&
                mission.completedAt!.isAfter(startOfDay) &&
                mission.completedAt!.isBefore(endOfDay)) {
              todayMissions.add(mission);
            }
          }
        } catch (e) {
          print('❌ Error processing ecore ${doc.id}: $e');
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
          'memberCount': school.memberCount,
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

  // Get game statistics
  static Future<Map<String, dynamic>> getGameStats() async {
    try {
      final stats = {
        'totalEcores': 0,
        'conqueredEcores': 0,
        'totalMissions': 0,
        'completedMissions': 0,
        'activeSchools': 0,
        'totalPoints': 0,
        'currentSeason': 'Spring',
        'daysInSeason': 0,
      };

      // Get ecore stats
      final ecores = await getEcores();
      stats['totalEcores'] = ecores.length;
      stats['conqueredEcores'] = ecores.where((e) => e.isConquered).length;
      
      // Get mission stats
      int totalMissions = 0;
      int completedMissions = 0;
      for (final ecore in ecores) {
        totalMissions += ecore.missions.length;
        completedMissions += ecore.missions.where((m) => m.isCompleted).length;
      }
      stats['totalMissions'] = totalMissions;
      stats['completedMissions'] = completedMissions;

      // Get school stats
      final schools = await _schoolService.getSchools();
      stats['activeSchools'] = schools.length;
      stats['totalPoints'] = schools.fold<int>(0, (sum, school) => sum + 0); // Schools don't have totalPoints field

      return stats;
    } catch (e) {
      print('❌ Error getting game stats: $e');
      return {};
    }
  }
} 