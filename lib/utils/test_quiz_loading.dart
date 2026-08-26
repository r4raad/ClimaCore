import '../services/quiz_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestQuizLoading {
  static Future<void> testQuizLoading() async {
    try {
      print('🧪 TestQuizLoading: Starting comprehensive quiz loading test...');

      print('\n📊 Test 1 - Direct Firestore Check:');
      final firestore = FirebaseFirestore.instance;
      final quizzesSnapshot = await firestore.collection('quizzes').get();
      print('  Found ${quizzesSnapshot.docs.length} quiz documents in Firestore');

      for (final doc in quizzesSnapshot.docs) {
        final data = doc.data();
        print('  Quiz: ${doc.id}');
        print('    Document keys: ${data.keys.toList()}');

        if (data.containsKey('questions')) {
          final questionsData = data['questions'] as List<dynamic>? ?? [];
          print('    Questions in document: ${questionsData.length}');

          if (questionsData.isNotEmpty) {
            final firstQuestion = questionsData.first;
            print('    First question structure: ${firstQuestion.keys.toList()}');
            if (firstQuestion.containsKey('answers')) {
              final answers = firstQuestion['answers'] as List<dynamic>? ?? [];
              print('    First question has ${answers.length} answers');
            }
          }
        } else {
          print('    ❌ No questions field found in document');
        }
      }

      print('\n📊 Test 2 - QuizService.getQuizzes():');
      final quizzes = await QuizService.getQuizzes();
      print('  Total quizzes loaded: ${quizzes.length}');

      for (final quiz in quizzes) {
        print('  Quiz: ${quiz.title}');
        print('    Questions: ${quiz.questions.length}');
        print('    Expected: ${quiz.questionCount}');

        if (quiz.questions.length != quiz.questionCount) {
          print('    ❌ MISMATCH: Expected ${quiz.questionCount} questions, got ${quiz.questions.length}');
        } else {
          print('    ✅ MATCH: Questions count is correct');
        }

        for (int i = 0; i < quiz.questions.length && i < 3; i++) {
          final question = quiz.questions[i];
          final correctAnswer = question.answers.where((a) => a.id == question.correctAnswerId).firstOrNull;
          if (correctAnswer == null) {
            print('    ❌ ERROR: Question "${question.question}" has no correct answer with ID ${question.correctAnswerId}');
          } else {
            print('    ✅ Question "${question.question}" has correct answer: ${correctAnswer.text}');
          }
        }
      }

      if (quizzes.isNotEmpty) {
        print('\n📊 Test 3 - Specific Quiz Loading:');
        final firstQuiz = quizzes.first;
        final loadedQuiz = await QuizService.getQuizById(firstQuiz.id);
        if (loadedQuiz != null) {
          print('  ✅ SUCCESS: Specific quiz loading works');
          print('    Questions: ${loadedQuiz.questions.length}');
          print('    Expected: ${loadedQuiz.questionCount}');
        } else {
          print('  ❌ FAILED: Specific quiz loading returned null');
        }
      }

      if (quizzes.isNotEmpty) {
        print('\n📊 Test 4 - Quiz Scoring Logic:');
        final testQuiz = quizzes.first;
        print('  Testing quiz: ${testQuiz.title}');
        print('    Total questions: ${testQuiz.questions.length}');

        int correctAnswers = 0;
        int totalQuestions = testQuiz.questions.length;

        for (final question in testQuiz.questions) {
          final correctAnswer = question.answers.where((a) => a.id == question.correctAnswerId).firstOrNull;
          if (correctAnswer != null) {
            correctAnswers++;
          }
        }

        final score = (correctAnswers / totalQuestions * 100).round();
        final pointsEarned = (score / 100 * testQuiz.points).round();

        print('    Perfect score simulation:');
        print('      Correct answers: $correctAnswers');
        print('      Total questions: $totalQuestions');
        print('      Score percentage: $score%');
        print('      Points earned: $pointsEarned');

        if (score == 100 && pointsEarned == testQuiz.points) {
          print('    ✅ SUCCESS: Scoring logic works correctly');
        } else {
          print('    ❌ ERROR: Scoring logic has issues');
        }
      }

      print('\n🎉 TestQuizLoading: All tests completed!');
    } catch (e) {
      print('❌ TestQuizLoading: Error during testing: $e');
    }
  }
}