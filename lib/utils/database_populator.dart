import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_setup.dart';

/// Utility class to populate the database with dummy data
/// This should be run manually when setting up the database
class DatabasePopulator {
  
  /// Populate the database with dummy users for testing
  /// Call this method manually when you need dummy data
  static Future<void> populateWithDummyUsers() async {
    try {
      print('🚀 DatabasePopulator: Starting to populate database...');
      
      // Check if we already have enough users
      final hasEnough = await FirebaseSetup.hasEnoughUsers();
      if (hasEnough) {
        print('ℹ️ DatabasePopulator: Database already has enough users');
        return;
      }
      
      // Create dummy users
      await FirebaseSetup.createDummyUsers();
      
      print('✅ DatabasePopulator: Database populated successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error populating database: $e');
      rethrow;
    }
  }
  
  /// Clear all dummy data from the database
  static Future<void> clearDummyData() async {
    try {
      print('🗑️ DatabasePopulator: Clearing dummy data...');
      await FirebaseSetup.clearSampleData();
      print('✅ DatabasePopulator: Dummy data cleared successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error clearing dummy data: $e');
      rethrow;
    }
  }
  
  /// Initialize the database with complete sample data
  static Future<void> initializeDatabase() async {
    try {
      print('🚀 DatabasePopulator: Initializing database with sample data...');
      await FirebaseSetup.initializeWithSampleData();
      print('✅ DatabasePopulator: Database initialized successfully!');
    } catch (e) {
      print('❌ DatabasePopulator: Error initializing database: $e');
      rethrow;
    }
  }
  
  /// Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    try {
      final userCount = await FirebaseSetup.getUserCount();
      
      // Get quiz count
      final quizSnapshot = await FirebaseFirestore.instance.collection('quizzes').get();
      final quizCount = quizSnapshot.docs.length;
      
      // Get activity count
      final activitySnapshot = await FirebaseFirestore.instance.collection('activities').get();
      final activityCount = activitySnapshot.docs.length;
      
      return {
        'users': userCount,
        'quizzes': quizCount,
        'activities': activityCount,
      };
    } catch (e) {
      print('❌ DatabasePopulator: Error getting database stats: $e');
      return {'users': 0, 'quizzes': 0, 'activities': 0};
    }
  }
} 