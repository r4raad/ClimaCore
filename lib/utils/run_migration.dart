import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/quiz_service.dart';
import '../models/quiz.dart';
import '../services/user_service.dart';

class RunMigration {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> migrateQuizProgress() async {
    try {
      print('🚀 Starting quiz progress migration...');

      await _migrateExistingData();

      await _showMigrationSummary();

      _showRecommendedIndexes();

      print('✅ Migration completed successfully!');
      print('💡 You can now delete the old quiz_progress collection');

    } catch (e) {
      print('❌ Migration failed: $e');
    }
  }

  static Future<void> _migrateExistingData() async {
    try {
      final snapshot = await _firestore.collection('quiz_progress').get();
      int migrated = 0;
      int errors = 0;

      print('📊 Found ${snapshot.docs.length} records to migrate');

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
          print('✅ Migrated: ${oldProgress.quizId} for user ${oldProgress.userId}');
        } catch (e) {
          errors++;
          print('❌ Error migrating ${doc.id}: $e');
        }
      }

      print('📈 Migration results:');
      print('   ✅ Successfully migrated: $migrated records');
      print('   ❌ Errors: $errors records');

    } catch (e) {
      print('❌ Error during migration: $e');
      rethrow;
    }
  }

  static Future<void> _showMigrationSummary() async {
    try {

      final oldSnapshot = await _firestore.collection('quiz_progress').get();

      int newRecords = 0;
      final usersSnapshot = await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final attemptsSnapshot = await userDoc.reference.collection('quiz_attempts').get();
        newRecords += attemptsSnapshot.docs.length;
      }

      print('📊 Migration Summary:');
      print('   📝 Old structure: ${oldSnapshot.docs.length} records');
      print('   📝 New structure: $newRecords records');
      print('   📝 Structure: users/{userId}/quiz_attempts/{attemptId}');

    } catch (e) {
      print('❌ Error showing summary: $e');
    }
  }

  static void _showRecommendedIndexes() {
    print('📋 Recommended Firestore Indexes:');
    print('');
    print('Collection: users/{userId}/quiz_attempts');
    print('Index 1: quizId (Ascending) + startedAt (Descending)');
    print('Index 2: isCompleted (Ascending) + completedAt (Descending)');
    print('Index 3: quizId (Ascending) + finalScore (Descending)');
    print('');
    print('💡 Go to Firebase Console > Firestore > Indexes to create these');
  }

  static Future<void> cleanupOldCollection() async {
    try {
      print('⚠️  WARNING: This will delete the old quiz_progress collection');
      print('   Make sure you have verified the migration first!');

      final snapshot = await _firestore.collection('quiz_progress').get();
      print('📊 Found ${snapshot.docs.length} records to delete');

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Successfully deleted old quiz_progress collection');

    } catch (e) {
      print('❌ Error cleaning up: $e');
    }
  }

  static Future<void> fixWeeklyPoints() async {
    try {
      print('🔧 RunMigration: Starting weekly points fix...');

      final userService = UserService();
      await userService.refreshWeeklyPointsForAllUsers();

      print('✅ RunMigration: Weekly points fix completed successfully!');
    } catch (e) {
      print('❌ RunMigration: Error fixing weekly points: $e');
    }
  }

  static Future<void> runAllMigrations() async {
    print('🚀 RunMigration: Starting all migrations...');

    await fixWeeklyPoints();

    print('✅ RunMigration: All migrations completed!');
  }
}