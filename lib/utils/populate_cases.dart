import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case.dart';

class PopulateCases {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> populateWithSampleCases() async {
    try {
      print('🔥 PopulateCases: Starting to populate Firebase with sample cases...');

      final hasCases = await _checkIfCasesExist();
      if (hasCases) {
        print('ℹ️ PopulateCases: Cases already exist in Firebase');
        return;
      }

      final cases = _getSampleCases();

      for (final caseData in cases) {
        await _firestore.collection('cases').add(caseData);
      }

      print('✅ PopulateCases: Successfully added ${cases.length} sample cases to Firebase');
    } catch (e) {
      print('❌ PopulateCases: Error populating cases: $e');
      rethrow;
    }
  }

  static Future<bool> _checkIfCasesExist() async {
    try {
      final snapshot = await _firestore.collection('cases').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ PopulateCases: Error checking cases: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> _getSampleCases() {
    return [
      {
        'personName': 'Yoon-ho Kim',
        'story': 'Lost home in devastating flood that swept through Seoul',
        'climateEvent': 'Flooding',
        'location': 'Seoul, South Korea',
        'impact': 'Lost Home',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
        'sourceUrl': 'https://example.com/flood-victim',
        'imageUrl': null,
        'severity': 'high',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'A family of four lost everything in the recent floods that hit Seoul, highlighting the increasing frequency of extreme weather events.',
      },
      {
        'personName': 'Eun-kyung Park',
        'story': 'Displaced by wildfire that destroyed her community',
        'climateEvent': 'Wildfire',
        'location': 'California, USA',
        'impact': 'Displaced',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 2))),
        'sourceUrl': 'https://example.com/wildfire-victim',
        'imageUrl': null,
        'severity': 'medium',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Eun-kyung was forced to evacuate her home as wildfires spread rapidly through her neighborhood, a situation becoming more common due to climate change.',
      },
      {
        'personName': 'Chul-soo Lee',
        'story': 'Family affected by extreme weather conditions',
        'climateEvent': 'Extreme Weather',
        'location': 'Texas, USA',
        'impact': 'Injured',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 3))),
        'sourceUrl': 'https://example.com/extreme-weather-victim',
        'imageUrl': null,
        'severity': 'medium',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Chul-soo and his family were injured during a severe storm that brought unprecedented rainfall and flooding to their area.',
      },
      {
        'personName': 'Seong-min Choi',
        'story': 'Climate refugee forced to leave ancestral home',
        'climateEvent': 'Climate Migration',
        'location': 'Bangladesh',
        'impact': 'Displaced',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 4))),
        'sourceUrl': 'https://example.com/climate-refugee',
        'imageUrl': null,
        'severity': 'high',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Seong-min became a climate refugee when rising sea levels made his coastal village uninhabitable, forcing him to relocate to a new area.',
      },
      {
        'personName': 'Min-jae Kim',
        'story': 'Lost livelihood due to drought affecting agriculture',
        'climateEvent': 'Drought',
        'location': 'Rural Korea',
        'impact': 'Lost Livelihood',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 5))),
        'sourceUrl': 'https://example.com/drought-victim',
        'imageUrl': null,
        'severity': 'high',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Min-jae, a farmer for 20 years, lost his entire crop due to prolonged drought conditions, leaving his family without income.',
      },
      {
        'personName': 'Ji-yeon Park',
        'story': 'Family home destroyed by typhoon',
        'climateEvent': 'Typhoon',
        'location': 'Philippines',
        'impact': 'Lost Home',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 6))),
        'sourceUrl': 'https://example.com/typhoon-victim',
        'imageUrl': null,
        'severity': 'high',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Ji-yeon\'s family home was completely destroyed when a powerful typhoon made landfall, leaving them homeless and in need of assistance.',
      },
      {
        'personName': 'Hye-jin Lee',
        'story': 'Business destroyed by extreme heat wave',
        'climateEvent': 'Extreme Heat',
        'location': 'Seoul, South Korea',
        'impact': 'Lost Livelihood',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 7))),
        'sourceUrl': 'https://example.com/heat-victim',
        'imageUrl': null,
        'severity': 'medium',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Hye-jin\'s small restaurant business was severely impacted by the extreme heat wave, causing significant financial losses.',
      },
      {
        'personName': 'Dong-hyun Park',
        'story': 'Family displaced by rising sea levels',
        'climateEvent': 'Sea Level Rise',
        'location': 'Coastal Korea',
        'impact': 'Displaced',
        'date': Timestamp.fromDate(DateTime.now().subtract(Duration(days: 8))),
        'sourceUrl': 'https://example.com/sea-level-victim',
        'imageUrl': null,
        'severity': 'high',
        'source': 'Sample',
        'isReviewed': false,
        'description': 'Dong-hyun\'s family had to leave their coastal home due to rising sea levels, becoming climate refugees in their own country.',
      },
    ];
  }

  static Future<void> clearAllCases() async {
    try {
      print('🗑️ PopulateCases: Clearing all cases...');
      final snapshot = await _firestore.collection('cases').get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ PopulateCases: All cases cleared successfully');
    } catch (e) {
      print('❌ PopulateCases: Error clearing cases: $e');
      rethrow;
    }
  }

  static Future<int> getCaseCount() async {
    try {
      final snapshot = await _firestore.collection('cases').get();
      return snapshot.docs.length;
    } catch (e) {
      print('❌ PopulateCases: Error getting case count: $e');
      return 0;
    }
  }
}