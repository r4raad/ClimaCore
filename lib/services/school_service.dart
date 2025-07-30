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
    return AsyncPerformanceMonitor.measure('getSchools', () async {
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
            if (fieldName != 'imageUrl' && fieldName != 'createdAt' && fieldName != 'updatedAt') {
              schoolName = fieldName.replaceAll(':', '').trim();
              break;
            }
          }
          
          if (schoolName.isEmpty) {
            print('✅ No school name field found, using document ID as school name: ${doc.id}');
            schoolName = doc.id;
          } else {
            print('✅ Found school name: "$schoolName" for document: ${doc.id}');
          }
          
          return School(
            id: doc.id,
            name: schoolName,
            imageUrl: data['imageUrl'],
            memberCount: 0, // Will be calculated separately
          );
        }).toList();
        
        // Calculate real member counts for each school
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
    });
  }

  Future<void> _calculateMemberCounts(List<School> schools) async {
    try {
      print('👥 Calculating real member counts for ${schools.length} schools...');
      
      for (int i = 0; i < schools.length; i++) {
        final school = schools[i];
        
        // Count users who have joined this school
        final usersSnapshot = await usersCollection
            .where('joinedSchoolId', isEqualTo: school.id)
            .get();
        
        final memberCount = usersSnapshot.docs.length;
        print('🏫 ${school.name}: ${memberCount} members');
        
        // Update the school object with real member count
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
      // If there's an error, keep member counts as 0
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
        for (String fieldName in data.keys) {
          if (fieldName != 'imageUrl' && fieldName != 'createdAt' && fieldName != 'updatedAt') {
            schoolName = fieldName.replaceAll(':', '').trim();
            break;
          }
        }
        
        if (schoolName.isEmpty) {
          schoolName = doc.id;
        }
        
        // Calculate real member count for this school
        final usersSnapshot = await usersCollection
            .where('joinedSchoolId', isEqualTo: id)
            .get();
        
        final memberCount = usersSnapshot.docs.length;
        
        return School(
          id: doc.id,
          name: schoolName,
          imageUrl: data['imageUrl'],
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

  Future<void> createSampleSchools() async {
    try {
      final sampleSchools = [
        School(
          id: 'school1',
          name: 'Yangdong Middle School',
          imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9e1?w=400',
          memberCount: 0, // Will be calculated from real user data
        ),
        School(
          id: 'school2',
          name: 'Eco Academy',
          imageUrl: 'https://images.unsplash.com/photo-1562774053-701939374585?w=400',
          memberCount: 0, // Will be calculated from real user data
        ),
        School(
          id: 'school3',
          name: 'Sustainable Learning Center',
          imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400',
          memberCount: 0, // Will be calculated from real user data
        ),
        School(
          id: 'school4',
          name: 'Green Valley High School',
          imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400',
          memberCount: 0, // Will be calculated from real user data
        ),
      ];

      for (final school in sampleSchools) {
        await addSchool(school);
      }
      
      print('Sample schools created successfully');
    } catch (e) {
      print('Error creating sample schools: $e');
      rethrow;
    }
  }
} 