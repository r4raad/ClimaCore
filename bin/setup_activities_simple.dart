import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  try {
    print('🚀 Starting activity setup for all schools...');
    
    // Initialize Firebase
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // List of all schools
    final schools = [
      'daegu-gongsan',
      'jungheung', 
      'nam-samsung',
      'posan',
      'yangdong'
    ];

    final aug9 = DateTime(2025, 8, 9);

    for (final schoolId in schools) {
      print('🏫 Setting up activities for school: $schoolId');
      
      // Clear existing activities
      final activitiesCollection = firestore.collection('schools').doc(schoolId).collection('activities');
      final snapshot = await activitiesCollection.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('🗑️ Cleared all activities for school: $schoolId');

      // Create unique activities for this school
      List<Map<String, dynamic>> activities = [];
      
      switch (schoolId) {
        case 'daegu-gongsan':
          activities = [
            {
              "id": "dg_river_cleanup_upcoming",
              "title": "Clean the Onchon-Chon River",
              "type": "Campaign - Restoration",
              "points": 800,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 3))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 3)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/river.png",
              "description": "Help restore the beauty of the Onchon-Chon River! Together, we'll remove waste, raise awareness about water pollution, and take a step toward a healthier environment.",
              "location": "Onchon-Chon River, Daegu",
              "communityName": "Daegu Community",
              "mapUrl": "https://maps.google.com/?q=Onchon-Chon+River+Daegu",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "dg_tree_planting_upcoming",
              "title": "Tree Plantation",
              "type": "Campaign - Greenery",
              "points": 600,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 10))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 10)).add(Duration(hours: 4))),
              "imageUrl": "assets/images/tree.png",
              "description": "Join us for a community tree planting event! Help us plant 100 trees in our local park and contribute to a greener environment.",
              "location": "Daegu Central Park",
              "communityName": "Daegu Community",
              "mapUrl": "https://maps.google.com/?q=Daegu+Central+Park",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "dg_climate_seminar_past",
              "title": "Climate Change Seminar",
              "type": "Seminar - Daegu High School",
              "points": 500,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.subtract(Duration(days: 5))),
              "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 5)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/seminar.png",
              "description": "An educational and interactive seminar where local experts discuss the causes, impacts, and solutions to climate change.",
              "location": "Daegu High School",
              "communityName": "Daegu Community",
              "mapUrl": "https://maps.google.com/?q=Daegu+High+School",
              "isUpcoming": false,
              "isCompleted": true,
              "schoolId": schoolId,
            },
          ];
          break;

        case 'jungheung':
          activities = [
            {
              "id": "jh_eco_workshop_upcoming",
              "title": "Eco-Friendly Living Workshop",
              "type": "Workshop - Education",
              "points": 450,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 5))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 5)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/planning.png",
              "description": "Learn practical ways to live more sustainably in your daily life. From reducing waste to energy conservation.",
              "location": "Jungheung Community Center",
              "communityName": "Jungheung Community",
              "mapUrl": "https://maps.google.com/?q=Jungheung+Community+Center",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "jh_park_cleanup_upcoming",
              "title": "Jungheung Park Cleanup",
              "type": "Campaign - Restoration",
              "points": 600,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 12))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 12)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/cleaning.png",
              "description": "Help keep our beautiful Jungheung Park clean and green! Join us for a community cleanup event.",
              "location": "Jungheung Park",
              "communityName": "Jungheung Community",
              "mapUrl": "https://maps.google.com/?q=Jungheung+Park",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "jh_cooking_class_past",
              "title": "Sustainable Cooking Workshop",
              "type": "Workshop - Practical",
              "points": 350,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.subtract(Duration(days: 3))),
              "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 3)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/cooking.png",
              "description": "Learn to cook delicious meals using local, seasonal ingredients while reducing food waste.",
              "location": "Jungheung Community Kitchen",
              "communityName": "Jungheung Community",
              "mapUrl": "https://maps.google.com/?q=Jungheung+Community+Kitchen",
              "isUpcoming": false,
              "isCompleted": true,
              "schoolId": schoolId,
            },
          ];
          break;

        case 'nam-samsung':
          activities = [
            {
              "id": "ns_community_garden_upcoming",
              "title": "Community Garden Day",
              "type": "Campaign - Greenery",
              "points": 500,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 4))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 4)).add(Duration(hours: 4))),
              "imageUrl": "assets/images/tree.png",
              "description": "Help maintain and expand our community garden. Learn about sustainable gardening practices and organic farming.",
              "location": "Nam Samsung Community Garden",
              "communityName": "Nam Samsung Community",
              "mapUrl": "https://maps.google.com/?q=Nam+Samsung+Community+Garden",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "ns_energy_audit_upcoming",
              "title": "Home Energy Audit Workshop",
              "type": "Workshop - Education",
              "points": 400,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 11))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 11)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/planning.png",
              "description": "Learn how to conduct an energy audit at home and discover ways to reduce your energy consumption and bills.",
              "location": "Nam Samsung Community Hall",
              "communityName": "Nam Samsung Community",
              "mapUrl": "https://maps.google.com/?q=Nam+Samsung+Community+Hall",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "ns_street_cleaning_past",
              "title": "Street Cleaning Campaign",
              "type": "Campaign - Restoration",
              "points": 350,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.subtract(Duration(days: 6))),
              "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 6)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/cleaning.png",
              "description": "Join our street cleaning campaign to help keep our community clean and green!",
              "location": "Nam Samsung District",
              "communityName": "Nam Samsung Community",
              "mapUrl": "https://maps.google.com/?q=Nam+Samsung+District",
              "isUpcoming": false,
              "isCompleted": true,
              "schoolId": schoolId,
            },
          ];
          break;

        case 'posan':
          activities = [
            {
              "id": "ps_eco_workshop_upcoming",
              "title": "Eco-Friendly Living Workshop",
              "type": "Workshop - Posan Center",
              "points": 450,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 6))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 6)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/planning.png",
              "description": "Learn about eco-friendly practices and sustainable living in this hands-on workshop.",
              "location": "Posan Community Center",
              "communityName": "Posan Community",
              "mapUrl": "https://maps.google.com/?q=Posan+Community+Center",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "ps_urban_farming_upcoming",
              "title": "Urban Farming Workshop",
              "type": "Workshop - Practical",
              "points": 500,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 13))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 13)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/tree.png",
              "description": "Learn how to grow your own food in small spaces. Perfect for apartment dwellers and urban residents.",
              "location": "Posan Community Garden",
              "communityName": "Posan Community",
              "mapUrl": "https://maps.google.com/?q=Posan+Community+Garden",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "ps_local_market_past",
              "title": "Local Farmers Market Visit",
              "type": "Education - Field Trip",
              "points": 200,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.subtract(Duration(days: 4))),
              "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 4)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/cooking.png",
              "description": "Explore local produce and learn about sustainable food systems at the farmers market.",
              "location": "Posan Farmers Market",
              "communityName": "Posan Community",
              "mapUrl": "https://maps.google.com/?q=Posan+Farmers+Market",
              "isUpcoming": false,
              "isCompleted": true,
              "schoolId": schoolId,
            },
          ];
          break;

        case 'yangdong':
          activities = [
            {
              "id": "yd_recycling_drive_upcoming",
              "title": "Recycling Awareness Drive",
              "type": "Campaign - Education",
              "points": 400,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 7))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 7)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/cleaning.png",
              "description": "Help spread awareness about proper recycling practices in our community. Learn what can and cannot be recycled.",
              "location": "Yangdong Community Hall",
              "communityName": "Yangdong Community",
              "mapUrl": "https://maps.google.com/?q=Yangdong+Community+Hall",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "yd_sustainable_fashion_upcoming",
              "title": "Sustainable Fashion Workshop",
              "type": "Workshop - Education",
              "points": 350,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 14))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 14)).add(Duration(hours: 2))),
              "imageUrl": "assets/images/planning.png",
              "description": "Discover how to make eco-conscious choices in your wardrobe and reduce textile waste.",
              "location": "Yangdong Community Center",
              "communityName": "Yangdong Community",
              "mapUrl": "https://maps.google.com/?q=Yangdong+Community+Center",
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
            {
              "id": "yd_beach_cleanup_past",
              "title": "Yangdong Beach Cleanup",
              "type": "Campaign - Restoration",
              "points": 700,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.subtract(Duration(days: 5))),
              "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 5)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/river.png",
              "description": "Join us to clean up the beautiful Yangdong Beach and protect marine life.",
              "location": "Yangdong Beach",
              "communityName": "Yangdong Community",
              "mapUrl": "https://maps.google.com/?q=Yangdong+Beach",
              "isUpcoming": false,
              "isCompleted": true,
              "schoolId": schoolId,
            },
          ];
          break;

        default:
          activities = [
            {
              "id": "default_activity",
              "title": "Community Environmental Day",
              "type": "Campaign - General",
              "points": 300,
              "participants": [],
              "participantCount": 0,
              "date": Timestamp.fromDate(aug9.add(Duration(days: 1))),
              "endDate": Timestamp.fromDate(aug9.add(Duration(days: 1)).add(Duration(hours: 3))),
              "imageUrl": "assets/images/cleaning.png",
              "description": "A general community environmental awareness and action day.",
              "location": "Community Center",
              "communityName": "Community",
              "mapUrl": null,
              "isUpcoming": true,
              "isCompleted": false,
              "schoolId": schoolId,
            },
          ];
      }
      
      // Add activities to Firebase
      for (final activity in activities) {
        await activitiesCollection.doc(activity["id"] as String).set(activity);
      }
      
      print('✅ Created ${activities.length} unique activities for school: $schoolId');
    }
    
    print('✅ Activity setup completed successfully!');
    print('📋 Summary:');
    print('   - daegu-gongsan: 3 unique activities');
    print('   - jungheung: 3 unique activities');
    print('   - nam-samsung: 3 unique activities');
    print('   - posan: 3 unique activities');
    print('   - yangdong: 3 unique activities');
    print('');
    print('🎯 Each school now has completely unique activities!');
  } catch (e) {
    print('❌ Error during activity setup: $e');
  }
} 