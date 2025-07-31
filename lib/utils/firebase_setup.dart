import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/quiz.dart';
import '../models/activity.dart';

class FirebaseSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firebase with realistic sample data
  /// This should be run manually when setting up the database
  static Future<void> initializeWithSampleData() async {
    try {
      print('🚀 FirebaseSetup: Initializing database with sample data...');
      
      // Create sample users
      await _createSampleUsers();
      
      // Create sample quizzes
      await _createSampleQuizzes();
      
      // Create sample activities
      await _createSampleActivities();
      
      print('✅ FirebaseSetup: Database initialized successfully!');
    } catch (e) {
      print('❌ FirebaseSetup: Error initializing database: $e');
      rethrow;
    }
  }

  /// Create dummy users in Firestore
  /// This method can be called manually to populate the database
  static Future<void> createDummyUsers() async {
    try {
      print('👥 FirebaseSetup: Creating dummy users...');
      
      final dummyUsers = [
        {
          'id': 'dummy_user_1',
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
          'id': 'dummy_user_2',
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
          'id': 'dummy_user_3',
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
        {
          'id': 'dummy_user_4',
          'firstName': 'Sarah',
          'lastName': 'Williams',
          'points': 0,
          'savedPosts': [],
          'likedPosts': [],
          'profilePic': null,
          'actions': 0,
          'streak': 0,
          'weekPoints': 0,
          'weekGoal': 600,
        },
        {
          'id': 'dummy_user_5',
          'firstName': 'Michael',
          'lastName': 'Brown',
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

  /// Clear all sample data from Firebase
  /// Use this to reset the database
  static Future<void> clearSampleData() async {
    try {
      print('🗑️ FirebaseSetup: Clearing sample data...');
      
      // Clear users
      final userDocs = await _firestore.collection('users').get();
      for (final doc in userDocs.docs) {
        if (doc.id.startsWith('sample_') || doc.id.startsWith('dummy_')) {
          await doc.reference.delete();
        }
      }
      
      // Clear quizzes
      final quizDocs = await _firestore.collection('quizzes').get();
      for (final doc in quizDocs.docs) {
        if (doc.id.startsWith('sample_')) {
          await doc.reference.delete();
        }
      }
      
      // Clear activities
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

  /// Get the current number of users in the database
  static Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ FirebaseSetup: Error getting user count: $e');
      return 0;
    }
  }

  /// Check if database has enough users for testing
  static Future<bool> hasEnoughUsers({int minUsers = 3}) async {
    final count = await getUserCount();
    return count >= minUsers;
  }
} 