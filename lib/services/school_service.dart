import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school.dart';
import '../utils/performance_monitor.dart';

class SchoolService {
  final CollectionReference schoolsCollection = FirebaseFirestore.instance.collection('schools');
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  static List<School>? _cachedSchools;
  static DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<List<School>> getSchools() async {
      if (_cachedSchools != null && _lastCacheTime != null) {
        final timeSinceLastCache = DateTime.now().difference(_lastCacheTime!);
        if (timeSinceLastCache < _cacheDuration) {
          return _cachedSchools!;
        }
      }

      try {
        print('🔍 Fetching schools from Firestore...');
        final snapshot = await schoolsCollection.get();
        print('📊 Found ${snapshot.docs.length} school documents');

        final schools = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          print('🏫 Processing school: ${doc.id}, has data: ${data != null && data.isNotEmpty}');

          if (data == null || data.isEmpty) {
            print('✅ Using document ID as school name: ${doc.id}');
            return School(
              id: doc.id,
              name: doc.id,
              imageUrl: null,
              memberCount: 0,
            );
          }

          String schoolName = '';
          for (String fieldName in data.keys) {
            if (fieldName != 'imageUrl' && fieldName != 'createdAt' && fieldName != 'updatedAt' && fieldName != 'name') {
              schoolName = fieldName.replaceAll(':', '').trim();
              break;
            }
          }

          if (schoolName.isEmpty) {
            schoolName = data['name'] ?? doc.id;
            print('✅ No school name field found, using document ID as school name: ${doc.id}');
          } else {
            print('✅ Found school name: "$schoolName" for document: ${doc.id}');
          }

          return School(
            id: doc.id,
            name: schoolName,
            imageUrl: data['imageUrl'],
            memberCount: 0,
          );
        }).toList();

        await _calculateMemberCounts(schools);

        print('🎉 Successfully processed ${schools.length} schools');

        _cachedSchools = schools;
        _lastCacheTime = DateTime.now();

        return schools;
      } catch (e) {
        print('Error fetching schools: $e');
        if (_cachedSchools != null) {
          return _cachedSchools!;
        }

        if (e.toString().contains('collection') || e.toString().contains('permission')) {
          print('Schools collection not found or permission denied. Returning empty list.');
          return [];
        }

        rethrow;
      }
    }

  Future<void> _calculateMemberCounts(List<School> schools) async {
    try {
      print('👥 Calculating real member counts for ${schools.length} schools...');

      for (int i = 0; i < schools.length; i++) {
        final school = schools[i];

        final usersSnapshot = await usersCollection
            .where('joinedSchoolId', isEqualTo: school.id)
            .get();

        final memberCount = usersSnapshot.docs.length;
        print('🏫 ${school.name}: ${memberCount} members');

        schools[i] = School(
          id: school.id,
          name: school.name,
          imageUrl: school.imageUrl,
          memberCount: memberCount,
        );
      }

      print('✅ Member counts calculated successfully');
    } catch (e) {
      print('❌ Error calculating member counts: $e');

    }
  }

  Future<void> addSchool(School school) async {
    try {
      await schoolsCollection.doc(school.id).set(school.toMap());
      _cachedSchools = null;
      _lastCacheTime = null;
    } catch (e) {
      print('Error adding school: $e');
      rethrow;
    }
  }

  Future<School?> getSchoolById(String id) async {
    try {
      final doc = await schoolsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null || data.isEmpty) {
          return School(
            id: doc.id,
            name: doc.id,
            imageUrl: null,
            memberCount: 0,
          );
        }

        String schoolName = '';
        if (data != null) {
          final dataMap = data as Map<String, dynamic>;
          for (String fieldName in dataMap.keys) {
            if (fieldName != 'imageUrl' && fieldName != 'createdAt' && fieldName != 'updatedAt' && fieldName != 'name') {
              schoolName = fieldName.replaceAll(':', '').trim();
              break;
            }
          }

          if (schoolName.isEmpty) {
            schoolName = dataMap['name'] ?? doc.id;
          }
        } else {
          schoolName = doc.id;
        }

        final usersSnapshot = await usersCollection
            .where('joinedSchoolId', isEqualTo: id)
            .get();

        final memberCount = usersSnapshot.docs.length;

        return School(
          id: doc.id,
          name: schoolName,
          imageUrl: data != null ? (data as Map<String, dynamic>)['imageUrl'] : null,
          memberCount: memberCount,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching school by ID: $e');
      rethrow;
    }
  }

  static void clearCache() {
    _cachedSchools = null;
    _lastCacheTime = null;
  }

  Future<void> updateSchoolData(String schoolId, String schoolName, String? imageUrl) async {
    try {
      await schoolsCollection.doc(schoolId).set({
        'name': schoolName,
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ School data updated for: $schoolId');
    } catch (e) {
      print('❌ Error updating school data: $e');
      rethrow;
    }
  }

  Future<void> setupSchoolsFromFirestore() async {
    try {

      final schoolsSnapshot = await schoolsCollection.get();

      if (schoolsSnapshot.docs.isEmpty) {
        print('⚠️ No schools found in Firestore');
        return;
      }

      print('📋 Found ${schoolsSnapshot.docs.length} schools in Firestore');

      for (final doc in schoolsSnapshot.docs) {
        final data = doc.data();
        final schoolId = doc.id;

        String schoolName = '';
        if (data != null) {
          final dataMap = data as Map<String, dynamic>;
          for (String fieldName in dataMap.keys) {
            if (fieldName != 'imageUrl' && fieldName != 'createdAt' && fieldName != 'updatedAt' && fieldName != 'name') {
              schoolName = fieldName.replaceAll(':', '').trim();
              break;
            }
          }

          if (schoolName.isEmpty) {
            schoolName = dataMap['name'] ?? schoolId;
          }
        } else {
          schoolName = schoolId;
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

        await schoolsCollection.doc(schoolId).set({
          'name': schoolName,
          'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('✅ Updated school: $schoolId -> "$schoolName" (image: $imageUrl)');
      }

      print('✅ All schools updated with proper Firestore structure');
    } catch (e) {
      print('❌ Error setting up schools from Firestore: $e');
      rethrow;
    }
  }
}