import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../models/quiz.dart';
import '../models/activity.dart';

class FirebaseSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeWithSampleData() async {
    try {
      print('🚀 FirebaseSetup: Initializing database with sample data...');

      await _createSampleUsers();

      await createSampleQuizzesFromJSON();

      await _createSampleActivities();

      print('✅ FirebaseSetup: Database initialized successfully!');
    } catch (e) {
      print('❌ FirebaseSetup: Error initializing database: $e');
      rethrow;
    }
  }

  static Future<void> createDummyUsers() async {
    try {
      print('👥 FirebaseSetup: Creating dummy users...');

      final dummyUsers = [
        {
          'id': 'user_1',
          'firstName': 'Alex',
          'lastName': 'Johnson',
          'points': 1250,
          'savedPosts': [],
          'likedPosts': [],
          'profilePic': null,
          'actions': 15,
          'streak': 5,
          'weekPoints': 180,
          'weekGoal': 800,
        },
        {
          'id': 'user_2',
          'firstName': 'Maria',
          'lastName': 'Garcia',
          'points': 980,
          'savedPosts': [],
          'likedPosts': [],
          'profilePic': null,
          'actions': 12,
          'streak': 3,
          'weekPoints': 120,
          'weekGoal': 600,
        },
        {
          'id': 'user_3',
          'firstName': 'David',
          'lastName': 'Chen',
          'points': 650,
          'savedPosts': [],
          'likedPosts': [],
          'profilePic': null,
          'actions': 8,
          'streak': 2,
          'weekPoints': 80,
          'weekGoal': 500,
        },
        {
          'id': 'user_4',
          'firstName': 'Sarah',
          'lastName': 'Williams',
          'points': 420,
          'savedPosts': [],
          'likedPosts': [],
          'profilePic': null,
          'actions': 6,
          'streak': 1,
          'weekPoints': 60,
          'weekGoal': 400,
        },
        {
          'id': 'user_5',
          'firstName': 'Michael',
          'lastName': 'Brown',
          'points': 320,
          'savedPosts': [],
          'likedPosts': [],
          'profilePic': null,
          'actions': 4,
          'streak': 1,
          'weekPoints': 40,
          'weekGoal': 300,
        },
      ];

      for (final userData in dummyUsers) {
        await _firestore.collection('users').doc(userData['id'] as String).set(userData);
      }

      print('✅ FirebaseSetup: Created ${dummyUsers.length} dummy users successfully!');
    } catch (e) {
      print('❌ FirebaseSetup: Error creating dummy users: $e');
      rethrow;
    }
  }

  static Future<void> _createSampleUsers() async {
    final users = [
      {
        'id': 'sample_user_1',
        'firstName': 'Alex',
        'lastName': 'Johnson',
        'points': 0,
        'savedPosts': [],
        'likedPosts': [],
        'profilePic': null,
        'actions': 0,
        'streak': 0,
        'weekPoints': 0,
        'weekGoal': 800,
      },
      {
        'id': 'sample_user_2',
        'firstName': 'Maria',
        'lastName': 'Garcia',
        'points': 0,
        'savedPosts': [],
        'likedPosts': [],
        'profilePic': null,
        'actions': 0,
        'streak': 0,
        'weekPoints': 0,
        'weekGoal': 800,
      },
      {
        'id': 'sample_user_3',
        'firstName': 'David',
        'lastName': 'Chen',
        'points': 0,
        'savedPosts': [],
        'likedPosts': [],
        'profilePic': null,
        'actions': 0,
        'streak': 0,
        'weekPoints': 0,
        'weekGoal': 600,
      },
    ];

    for (final userData in users) {
      await _firestore.collection('users').doc(userData['id'] as String).set(userData);
    }
    print('✅ Created ${users.length} sample users');
  }

  static Future<void> createSampleQuizzesFromJSON() async {
    try {
      print('📚 FirebaseSetup: Loading quizzes from JSON file...');
      final String jsonString = await rootBundle.loadString('assets/data/sample_quizzes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> quizzesData = jsonData['quizzes'];

      for (final quizData in quizzesData) {
        try {

          final quizDoc = {
            'id': quizData['id'],
            'title': quizData['title'],
            'description': quizData['description'],
            'author': quizData['author'],
            'category': quizData['category'],
            'questionCount': quizData['questionCount'],
            'timeLimit': quizData['timeLimit'],
            'points': quizData['points'],
            'rating': quizData['rating'],
            'imageUrl': quizData['imageUrl'],
            'videoUrl': quizData['videoUrl'],
            'isActive': true,
            'createdAt': Timestamp.now(),
          };

          final List<dynamic> questionsData = quizData['questions'] ?? [];
          quizDoc['questions'] = questionsData;

          await _firestore.collection('quizzes').doc(quizData['id']).set(quizDoc);

          print('✅ Created quiz: ${quizData['title']} with ${questionsData.length} questions');
        } catch (e) {
          print('❌ Error creating quiz ${quizData['id']}: $e');
        }
      }

      print('🎉 FirebaseSetup: Successfully created ${quizzesData.length} quizzes from JSON');
    } catch (e) {
      print('❌ FirebaseSetup: Error loading quizzes from JSON: $e');

      await _createSampleQuizzes();
    }
  }

  static Future<void> _createSampleQuizzes() async {
    final quizzes = [
      {
        'id': 'climate-basics',
        'title': 'Climate Change Basics',
        'description': 'Test your knowledge about climate change fundamentals',
        'author': 'ClimaCore Team',
        'category': 'Climate Science',
        'questionCount': 10,
        'timeLimit': 300,
        'points': 50,
        'rating': 4.5,
        'imageUrl': '',
        'videoUrl': '',
        'isActive': true,
      },
      {
        'id': 'carbon-footprint',
        'title': 'Carbon Footprint Quiz',
        'description': 'Learn about your carbon footprint and how to reduce it',
        'author': 'ClimaCore Team',
        'category': 'Sustainability',
        'questionCount': 8,
        'timeLimit': 240,
        'points': 40,
        'rating': 4.3,
        'imageUrl': '',
        'videoUrl': '',
        'isActive': true,
      },
    ];

    for (final quizData in quizzes) {
      await _firestore.collection('quizzes').doc(quizData['id'] as String).set(quizData);
    }
    print('✅ Created ${quizzes.length} sample quizzes');
  }

  static Future<void> _createSampleActivities() async {
    final activities = [
      {
        'id': 'tree-planting',
        'title': 'Community Tree Planting',
        'description': 'Join us in planting trees to combat climate change',
        'type': 'Environmental',
        'points': 100,
        'date': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
        'location': 'Central Park',
        'imageUrl': '',
        'schoolId': 'sample_school_1',
      },
      {
        'id': 'cleanup-drive',
        'title': 'Beach Cleanup Drive',
        'description': 'Help clean up our beaches and protect marine life',
        'type': 'Community',
        'points': 75,
        'date': Timestamp.fromDate(DateTime.now().add(Duration(days: 14))),
        'location': 'Beach Front',
        'imageUrl': '',
        'schoolId': 'sample_school_1',
      },
    ];

    for (final activityData in activities) {
      await _firestore.collection('activities').doc(activityData['id'] as String).set(activityData);
    }
    print('✅ Created ${activities.length} sample activities');
  }

  static Future<void> clearSampleData() async {
    try {
      print('🗑️ FirebaseSetup: Clearing sample data...');

      final userDocs = await _firestore.collection('users').get();
      for (final doc in userDocs.docs) {
        if (doc.id.startsWith('sample_') || doc.id.startsWith('dummy_')) {
          await doc.reference.delete();
        }
      }

      final quizDocs = await _firestore.collection('quizzes').get();
      for (final doc in quizDocs.docs) {
        if (doc.id.startsWith('sample_')) {
          await doc.reference.delete();
        }
      }

      final activityDocs = await _firestore.collection('activities').get();
      for (final doc in activityDocs.docs) {
        if (doc.id.startsWith('sample_')) {
          await doc.reference.delete();
        }
      }

      print('✅ FirebaseSetup: Sample data cleared successfully!');
    } catch (e) {
      print('❌ FirebaseSetup: Error clearing sample data: $e');
      rethrow;
    }
  }

  static Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ FirebaseSetup: Error getting user count: $e');
      return 0;
    }
  }

  static Future<bool> hasEnoughUsers({int minUsers = 3}) async {
    final count = await getUserCount();
    return count >= minUsers;
  }

  static Future<void> createSampleCases() async {
    try {
      print('🔥 FirebaseSetup: Creating sample cases...');

      final cases = [
        {
          'personName': 'Yoon-ho Kim',
          'story': 'Lost home in devastating flood that swept through Seoul',
          'climateEvent': 'Flooding',
          'location': 'Seoul, South Korea',
          'impact': 'Lost Home',
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
          'sourceUrl': 'https://example.com/flood-victim',
          'imageUrl': null,
          'severity': 'high',
          'source': 'Sample',
          'isReviewed': false,
          'description': 'A family of four lost everything in the recent floods that hit Seoul, highlighting the increasing frequency of extreme weather events.',
        },
        {
          'personName': 'Eun-kyung Park',
          'story': 'Displaced by wildfire that destroyed her community',
          'climateEvent': 'Wildfire',
          'location': 'California, USA',
          'impact': 'Displaced',
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
          'sourceUrl': 'https://example.com/wildfire-victim',
          'imageUrl': null,
          'severity': 'medium',
          'source': 'Sample',
          'isReviewed': false,
          'description': 'Eun-kyung was forced to evacuate her home as wildfires spread rapidly through her neighborhood, a situation becoming more common due to climate change.',
        },
        {
          'personName': 'Chul-soo Lee',
          'story': 'Family affected by extreme weather conditions',
          'climateEvent': 'Extreme Weather',
          'location': 'Texas, USA',
          'impact': 'Injured',
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
          'sourceUrl': 'https://example.com/extreme-weather-victim',
          'imageUrl': null,
          'severity': 'medium',
          'source': 'Sample',
          'isReviewed': false,
          'description': 'Chul-soo and his family were injured during a severe storm that brought unprecedented rainfall and flooding to their area.',
        },
        {
          'personName': 'Seong-min Choi',
          'story': 'Climate refugee forced to leave ancestral home',
          'climateEvent': 'Climate Migration',
          'location': 'Bangladesh',
          'impact': 'Displaced',
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 4))),
          'sourceUrl': 'https://example.com/climate-refugee',
          'imageUrl': null,
          'severity': 'high',
          'source': 'Sample',
          'isReviewed': false,
          'description': 'Seong-min became a climate refugee when rising sea levels made his coastal village uninhabitable, forcing him to relocate to a new area.',
        },
        {
          'personName': 'Min-jae Kim',
          'story': 'Lost livelihood due to drought affecting agriculture',
          'climateEvent': 'Drought',
          'location': 'Rural Korea',
          'impact': 'Lost Livelihood',
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
          'sourceUrl': 'https://example.com/drought-victim',
          'imageUrl': null,
          'severity': 'high',
          'source': 'Sample',
          'isReviewed': false,
          'description': 'Min-jae, a farmer for 20 years, lost his entire crop due to prolonged drought conditions, leaving his family without income.',
        },
        {
          'personName': 'Ji-yeon Park',
          'story': 'Family home destroyed by typhoon',
          'climateEvent': 'Typhoon',
          'location': 'Philippines',
          'impact': 'Lost Home',
          'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 6))),
          'sourceUrl': 'https://example.com/typhoon-victim',
          'imageUrl': null,
          'severity': 'high',
          'source': 'Sample',
          'isReviewed': false,
          'description': 'Ji-yeon\'s family home was completely destroyed when a powerful typhoon made landfall, leaving them homeless and in need of assistance.',
        },
      ];

      for (final caseData in cases) {
        await _firestore.collection('cases').add(caseData);
      }

      print('✅ FirebaseSetup: Created ${cases.length} sample cases');
    } catch (e) {
      print('❌ FirebaseSetup: Error creating sample cases: $e');
      rethrow;
    }
  }

  static Future<bool> hasCases() async {
    try {
      final snapshot = await _firestore.collection('cases').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ FirebaseSetup: Error checking cases: $e');
      return false;
    }
  }
}