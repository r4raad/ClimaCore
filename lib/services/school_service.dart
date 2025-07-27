import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/school.dart';
import '../utils/performance_monitor.dart';

class SchoolService {
  final CollectionReference schoolsCollection = FirebaseFirestore.instance.collection('schools');
  
  // Simple in-memory cache
  static List<School>? _cachedSchools;
  static DateTime? _lastCacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  Future<List<School>> getSchools() async {
    return AsyncPerformanceMonitor.measure('getSchools', () async {
      // Check if we have valid cached data
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
          
          // If document has no fields, use document ID as school name
          if (data == null || data.isEmpty) {
            print('✅ Using document ID as school name: ${doc.id}');
            return School(
              id: doc.id,
              name: doc.id, // Use document ID as school name
              imageUrl: null,
            );
          }
          
          // Check if the name field is empty or null
          String schoolName = data['name'] ?? '';
          if (schoolName.isEmpty) {
            // If name is empty, use document ID as school name
            print('✅ Name field is empty, using document ID as school name: ${doc.id}');
            schoolName = doc.id;
          }
          
          print('✅ Using document data for school: ${doc.id}, name: "$schoolName"');
          return School(
            id: doc.id,
            name: schoolName,
            imageUrl: data['imageUrl'],
          );
        }).toList();
        
        print('🎉 Successfully processed ${schools.length} schools');
        
        // Update cache
        _cachedSchools = schools;
        _lastCacheTime = DateTime.now();
        
        return schools;
      } catch (e) {
        print('Error fetching schools: $e');
        // Return cached data if available, even if expired
        if (_cachedSchools != null) {
          return _cachedSchools!;
        }
        
        // If no cached data and it's a collection not found error, return empty list
        if (e.toString().contains('collection') || e.toString().contains('permission')) {
          print('Schools collection not found or permission denied. Returning empty list.');
          return [];
        }
        
        rethrow;
      }
    });
  }

  Future<void> addSchool(School school) async {
    try {
      await schoolsCollection.doc(school.id).set(school.toMap());
      // Clear cache when new school is added
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
        
        // If document has no fields, use document ID as school name
        if (data == null || data.isEmpty) {
          return School(
            id: doc.id,
            name: doc.id, // Use document ID as school name
            imageUrl: null,
          );
        }
        
        // Check if the name field is empty or null
        String schoolName = data['name'] ?? '';
        if (schoolName.isEmpty) {
          // If name is empty, use document ID as school name
          schoolName = doc.id;
        }
        
        return School(
          id: doc.id,
          name: schoolName,
          imageUrl: data['imageUrl'],
        );
      }
      return null;
    } catch (e) {
      print('Error fetching school by ID: $e');
      rethrow;
    }
  }

  // Clear cache method for manual cache invalidation
  static void clearCache() {
    _cachedSchools = null;
    _lastCacheTime = null;
  }

  // Method to create sample schools for testing
  Future<void> createSampleSchools() async {
    try {
      final sampleSchools = [
        School(
          id: 'school1',
          name: 'Green Valley High School',
          imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9e1?w=400',
        ),
        School(
          id: 'school2',
          name: 'Eco Academy',
          imageUrl: 'https://images.unsplash.com/photo-1562774053-701939374585?w=400',
        ),
        School(
          id: 'school3',
          name: 'Sustainable Learning Center',
          imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400',
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