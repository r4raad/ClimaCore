import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'firebase_setup.dart';

class DatabasePopulator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeDatabase() async {
    try {
      print('🚀 DatabasePopulator: Initializing complete database...');

      await FirebaseSetup.initializeWithSampleData();

      print('✅ DatabasePopulator: Database initialization completed!');
    } catch (e) {
      print('❌ DatabasePopulator: Error initializing database: $e');
      rethrow;
    }
  }

  static Future<void> populateQuizzes() async {
    try {
      print('📚 DatabasePopulator: Populating quizzes from JSON...');
      await FirebaseSetup.createSampleQuizzesFromJSON();
      print('✅ DatabasePopulator: Quizzes populated successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error populating quizzes: $e');
      rethrow;
    }
  }

  static Future<void> populateUsers() async {
    try {
      print('👥 DatabasePopulator: Populating users...');
      await FirebaseSetup.createDummyUsers();
      print('✅ DatabasePopulator: Users populated successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error populating users: $e');
      rethrow;
    }
  }

  static Future<void> populateCases() async {
    try {
      print('📰 DatabasePopulator: Populating cases...');
      await FirebaseSetup.createSampleCases();
      print('✅ DatabasePopulator: Cases populated successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error populating cases: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final stats = <String, dynamic>{};

      final usersSnapshot = await _firestore.collection('users').get();
      stats['users'] = usersSnapshot.docs.length;

      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      stats['quizzes'] = quizzesSnapshot.docs.length;

      int totalQuestions = 0;
      for (final quizDoc in quizzesSnapshot.docs) {
        final questionsSnapshot = await quizDoc.reference.collection('questions').get();
        totalQuestions += questionsSnapshot.docs.length;
      }
      stats['totalQuestions'] = totalQuestions;

      final casesSnapshot = await _firestore.collection('cases').get();
      stats['cases'] = casesSnapshot.docs.length;

      final activitiesSnapshot = await _firestore.collection('activities').get();
      stats['activities'] = activitiesSnapshot.docs.length;

      int totalAttempts = 0;
      for (final userDoc in usersSnapshot.docs) {
        final attemptsSnapshot = await userDoc.reference.collection('quiz_attempts').get();
        totalAttempts += attemptsSnapshot.docs.length;
      }
      stats['quizAttempts'] = totalAttempts;

      print('📊 DatabasePopulator: Database stats: $stats');
      return stats;
    } catch (e) {
      print('❌ DatabasePopulator: Error getting database stats: $e');
      return {};
    }
  }

  static Future<void> clearDummyData() async {
    try {
      print('⚠️ DatabasePopulator: Clearing all dummy data...');

      final usersSnapshot = await _firestore.collection('users').get();
      for (final doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }

      final quizzesSnapshot = await _firestore.collection('quizzes').get();
      for (final doc in quizzesSnapshot.docs) {
        await doc.reference.delete();
      }

      final casesSnapshot = await _firestore.collection('cases').get();
      for (final doc in casesSnapshot.docs) {
        await doc.reference.delete();
      }

      final activitiesSnapshot = await _firestore.collection('activities').get();
      for (final doc in activitiesSnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ DatabasePopulator: All dummy data cleared successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error clearing dummy data: $e');
      rethrow;
    }
  }

  static Future<void> populateWithDummyUsers() async {
    try {
      print('👥 DatabasePopulator: Adding dummy users...');
      await FirebaseSetup.createDummyUsers();
      print('✅ DatabasePopulator: Dummy users added successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error adding dummy users: $e');
      rethrow;
    }
  }

  static Future<void> loadQuizzesFromJSON() async {
    try {
      print('📚 DatabasePopulator: Loading quizzes from JSON file...');
      final String jsonString = await rootBundle.loadString('assets/data/sample_quizzes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> quizzesData = jsonData['quizzes'];

      int createdQuizzes = 0;
      int createdQuestions = 0;

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
            'questions': quizData['questions'],
            'isActive': true,
            'createdAt': Timestamp.now(),
          };

          await _firestore.collection('quizzes').doc(quizData['id']).set(quizDoc);
          createdQuizzes++;

          final List<dynamic> questionsData = quizData['questions'] ?? [];
          createdQuestions += questionsData.length;

          print('✅ Created quiz: ${quizData['title']} with ${questionsData.length} questions');
        } catch (e) {
          print('❌ Error creating quiz ${quizData['id']}: $e');
        }
      }

      print('🎉 DatabasePopulator: Successfully created $createdQuizzes quizzes with $createdQuestions total questions');
    } catch (e) {
      print('❌ DatabasePopulator: Error loading quizzes from JSON: $e');
      rethrow;
    }
  }
}