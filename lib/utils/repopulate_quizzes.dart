import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class RepopulateQuizzes {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> repopulateQuizzes() async {
    try {
      print('🔄 RepopulateQuizzes: Starting quiz repopulation...');

      final existingQuizzes = await _firestore.collection('quizzes').get();
      for (final doc in existingQuizzes.docs) {
        await doc.reference.delete();
        print('🗑️ Deleted existing quiz: ${doc.id}');
      }

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
            'questions': quizData['questions'],
          };

          await _firestore.collection('quizzes').doc(quizData['id']).set(quizDoc);

          print('✅ Created quiz: ${quizData['title']} with ${quizData['questions'].length} questions');

          final savedDoc = await _firestore.collection('quizzes').doc(quizData['id']).get();
          if (savedDoc.exists) {
            final savedData = savedDoc.data()!;
            final savedQuestions = savedData['questions'] as List<dynamic>? ?? [];
            print('  ✅ Verification: Quiz saved with ${savedQuestions.length} questions');
          } else {
            print('  ❌ Verification: Quiz was not saved properly');
          }
        } catch (e) {
          print('❌ Error creating quiz ${quizData['id']}: $e');
        }
      }

      print('🎉 RepopulateQuizzes: Successfully repopulated ${quizzesData.length} quizzes');
    } catch (e) {
      print('❌ RepopulateQuizzes: Error repopulating quizzes: $e');
      rethrow;
    }
  }
}