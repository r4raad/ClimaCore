import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/utils/activity_setup.dart';

void main() async {
  try {
    print('🚀 Starting activity setup for all schools...');
    
    // Initialize Firebase
    await FirebaseFirestore.instance;
    
    // Run the activity setup
    await ActivitySetup.setupUniqueActivitiesForAllSchools();
    
    print('✅ Activity setup completed successfully!');
    print('📋 Summary:');
    print('   - daegu-gongsan: 5 unique activities');
    print('   - jungheung: 5 unique activities');
    print('   - nam-samsung: 5 unique activities');
    print('   - posan: 5 unique activities');
    print('   - yangdong: 5 unique activities');
    print('');
    print('🎯 Each school now has completely unique activities!');
  } catch (e) {
    print('❌ Error during activity setup: $e');
  }
} 