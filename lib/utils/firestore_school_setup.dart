import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSchoolSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> updateAllSchools() async {
    try {
      print('🔄 Starting Firestore school setup...');

      final schoolsSnapshot = await _firestore.collection('schools').get();

      if (schoolsSnapshot.docs.isEmpty) {
        print('⚠️ No schools found in Firestore');
        return;
      }

      print('📋 Found ${schoolsSnapshot.docs.length} schools in Firestore');

      for (final doc in schoolsSnapshot.docs) {
        final data = doc.data();
        final schoolId = doc.id;

        print('🏫 Processing school: $schoolId');

        String schoolName = '';
        for (String fieldName in data.keys) {
          if (fieldName != 'imageUrl' && fieldName != 'createdAt' && fieldName != 'updatedAt' && fieldName != 'name') {
            schoolName = fieldName.replaceAll(':', '').trim();
            break;
          }
        }

        if (schoolName.isEmpty) {
          schoolName = data['name'] ?? schoolId;
        }

        String? imageUrl;
        switch (schoolId) {
          case 'daegu-gongsan':
            imageUrl = 'assets/images/school1.png';
            break;
          case 'jungheung':
            imageUrl = 'assets/images/school2.png';
            break;
          case 'nam-samsung':
            imageUrl = 'assets/images/school3.png';
            break;
          case 'posan':
            imageUrl = 'assets/images/school4.png';
            break;
          case 'yangdong':
            imageUrl = 'assets/images/school5.png';
            break;
          default:
            imageUrl = null;
        }

        await _firestore.collection('schools').doc(schoolId).set({
          'name': schoolName,
          'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('✅ Updated school: $schoolId -> "$schoolName" (image: $imageUrl)');
      }

      print('✅ All schools updated with proper Firestore structure');
    } catch (e) {
      print('❌ Error updating schools: $e');
      rethrow;
    }
  }

  static Future<void> updateSchool(String schoolId, String schoolName, String? imageUrl) async {
    try {
      await _firestore.collection('schools').doc(schoolId).set({
        'name': schoolName,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ Updated school: $schoolId -> "$schoolName" (image: $imageUrl)');
    } catch (e) {
      print('❌ Error updating school $schoolId: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getSchoolData(String schoolId) async {
    try {
      final doc = await _firestore.collection('schools').doc(schoolId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting school data for $schoolId: $e');
      return null;
    }
  }

  static Future<void> listAllSchools() async {
    try {
      final schoolsSnapshot = await _firestore.collection('schools').get();

      print('📋 Current schools in Firestore:');
      for (final doc in schoolsSnapshot.docs) {
        final data = doc.data();
        print('🏫 ${doc.id}:');
        print('   Data: $data');
      }
    } catch (e) {
      print('❌ Error listing schools: $e');
    }
  }
}