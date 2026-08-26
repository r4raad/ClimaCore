import 'database_populator.dart';

class RunQuizSetup {

  static Future<void> setupCompleteDatabase() async {
    try {
      print('🚀 RunQuizSetup: Setting up complete database with new quiz questions...');
      await DatabasePopulator.initializeDatabase();
      print('✅ RunQuizSetup: Complete database setup finished!');
    } catch (e) {
      print('❌ RunQuizSetup: Error setting up database: $e');
    }
  }

  static Future<void> setupQuizzesOnly() async {
    try {
      print('📚 RunQuizSetup: Setting up quizzes with new questions...');
      await DatabasePopulator.loadQuizzesFromJSON();
      print('✅ RunQuizSetup: Quizzes setup finished!');
    } catch (e) {
      print('❌ RunQuizSetup: Error setting up quizzes: $e');
    }
  }

  static Future<void> showDatabaseStats() async {
    try {
      print('📊 RunQuizSetup: Getting database statistics...');
      final stats = await DatabasePopulator.getDatabaseStats();
      print('📈 Database Statistics:');
      print('   👥 Users: ${stats['users']}');
      print('   📚 Quizzes: ${stats['quizzes']}');
      print('   ❓ Total Questions: ${stats['totalQuestions']}');
      print('   📰 Cases: ${stats['cases']}');
      print('   🎯 Activities: ${stats['activities']}');
      print('   🏆 Quiz Attempts: ${stats['quizAttempts']}');
    } catch (e) {
      print('❌ RunQuizSetup: Error getting database stats: $e');
    }
  }

  static Future<void> resetDatabase() async {
    try {
      print('⚠️ RunQuizSetup: Resetting database (this will delete all data)...');
      await DatabasePopulator.clearDummyData();
      print('✅ RunQuizSetup: Database reset completed!');
    } catch (e) {
      print('❌ RunQuizSetup: Error resetting database: $e');
    }
  }
}