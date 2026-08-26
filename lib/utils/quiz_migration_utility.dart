import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/quiz_service.dart';
import '../models/quiz.dart';

class QuizMigrationUtility {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> migrateAllQuizProgress() async {
    try {
      print('🔄 Starting comprehensive quiz progress migration...');

      final snapshot = await _firestore.collection('quiz_progress').get();
      int migrated = 0;
      int errors = 0;

      print('📊 Found ${snapshot.docs.length} quiz progress records to migrate');

      for (final doc in snapshot.docs) {
        try {
          final oldProgress = QuizProgress.fromJson(doc.data());

          final attempt = QuizAttempt(
            id: oldProgress.id,
            quizId: oldProgress.quizId,
            userId: oldProgress.userId,
            attemptNumber: 1,
            startedAt: oldProgress.startedAt,
            completedAt: oldProgress.completedAt,
            finalScore: oldProgress.totalQuestions > 0
                ? (oldProgress.correctAnswers / oldProgress.totalQuestions * 100).round()
                : 0,
            timeSpent: oldProgress.timeSpent,
            isCompleted: oldProgress.isCompleted,
            totalQuestions: oldProgress.totalQuestions,
            correctAnswers: oldProgress.correctAnswers,
            questionResults: [],
          );

          await _firestore
              .collection('users')
              .doc(oldProgress.userId)
              .collection('quiz_attempts')
              .doc(attempt.id)
              .set(attempt.toJson());

          migrated++;
          print('✅ Migrated progress ${doc.id} for user ${oldProgress.userId}');
        } catch (e) {
          errors++;
          print('❌ Error migrating progress ${doc.id}: $e');
        }
      }

      print('🎉 Migration completed!');
      print('   ✅ Successfully migrated: $migrated records');
      print('   ❌ Errors: $errors records');

      if (migrated > 0) {
        print('💡 You can now safely delete the old quiz_progress collection');
        print('   The new structure uses: users/{userId}/quiz_attempts/{attemptId}');
      }
    } catch (e) {
      print('❌ Error during migration: $e');
    }
  }

  static Future<void> compareUserProgress(String userId) async {
    try {
      print('🔍 Comparing quiz progress for user: $userId');

      final oldSnapshot = await _firestore
          .collection('quiz_progress')
          .where('userId', isEqualTo: userId)
          .get();

      final newSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_attempts')
          .get();

      print('📊 Old structure: ${oldSnapshot.docs.length} records');
      print('📊 New structure: ${newSnapshot.docs.length} records');

      for (final doc in oldSnapshot.docs) {
        final oldProgress = QuizProgress.fromJson(doc.data());
        print('   📝 Old: Quiz ${oldProgress.quizId} - Score: ${oldProgress.score}/${oldProgress.totalQuestions}');
      }

      for (final doc in newSnapshot.docs) {
        final newAttempt = QuizAttempt.fromJson(doc.data());
        print('   📝 New: Quiz ${newAttempt.quizId} - Score: ${newAttempt.finalScore}% (Attempt #${newAttempt.attemptNumber})');
      }
    } catch (e) {
      print('❌ Error comparing progress: $e');
    }
  }

  static Future<void> cleanupOldQuizProgress() async {
    try {
      print('⚠️  WARNING: This will delete the old quiz_progress collection');
      print('   Make sure you have migrated all data first!');

      final snapshot = await _firestore.collection('quiz_progress').get();
      print('📊 Found ${snapshot.docs.length} records to delete');

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Successfully deleted old quiz_progress collection');
    } catch (e) {
      print('❌ Error cleaning up old progress: $e');
    }
  }

  static Future<void> createRecommendedIndexes() async {
    print('📋 Recommended Firestore indexes for new quiz structure:');
    print('');
    print('Collection: users/{userId}/quiz_attempts');
    print('Index 1: quizId (Ascending) + startedAt (Descending)');
    print('Index 2: isCompleted (Ascending) + completedAt (Descending)');
    print('Index 3: quizId (Ascending) + finalScore (Descending)');
    print('');
    print('💡 Go to Firebase Console > Firestore > Indexes to create these');
  }

  static Future<void> testNewStructure(String userId, String quizId) async {
    try {
      print('🧪 Testing new quiz structure...');

      final attempt = await QuizService.createQuizAttempt(userId, quizId, 5);
      print('✅ Created test attempt: ${attempt.id}');

      await QuizService.submitAnswerToAttempt(attempt, 'q1', 'a1', true, 30);
      await QuizService.submitAnswerToAttempt(attempt, 'q2', 'a2', false, 45);
      await QuizService.submitAnswerToAttempt(attempt, 'q3', 'a3', true, 20);

      final updatedAttempt = await QuizService.getUserLatestAttempt(userId, quizId);
      if (updatedAttempt != null) {
        print('✅ Test successful!');
        print('   📊 Score: ${updatedAttempt.finalScore}%');
        print('   📊 Correct: ${updatedAttempt.correctAnswers}/${updatedAttempt.totalQuestions}');
        print('   📊 Time: ${updatedAttempt.timeSpent} seconds');
        print('   📊 Progress: ${(updatedAttempt.progressPercentage * 100).round()}%');
      }
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
}