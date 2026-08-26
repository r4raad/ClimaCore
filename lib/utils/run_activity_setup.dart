import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_setup.dart';

class RunActivitySetup {
  static Future<void> main() async {
    try {
      print('🚀 Starting activity setup for all schools...');

      await FirebaseFirestore.instance;

      await ActivitySetup.setupUniqueActivitiesForAllSchools();

      print('✅ Activity setup completed successfully!');
    } catch (e) {
      print('❌ Error during activity setup: $e');
    }
  }
}