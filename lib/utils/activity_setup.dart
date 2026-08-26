import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitySetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> setupUniqueActivitiesForAllSchools() async {
    try {
      print('🔄 Starting unique activity setup for all schools...');

      final schools = [
        'daegu-gongsan',
        'jungheung',
        'nam-samsung',
        'posan',
        'yangdong'
      ];

      for (final schoolId in schools) {
        print('🏫 Setting up activities for school: $schoolId');
        await _clearAndSetupActivitiesForSchool(schoolId);
      }

      print('✅ Successfully set up unique activities for all schools');
    } catch (e) {
      print('❌ Error setting up unique activities: $e');
      rethrow;
    }
  }

  static Future<void> _clearAndSetupActivitiesForSchool(String schoolId) async {
    try {
      final activitiesCollection = _firestore.collection('schools').doc(schoolId).collection('activities');

      final snapshot = await activitiesCollection.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('🗑️ Cleared all activities for school: $schoolId');

      final activities = _getUniqueActivitiesForSchool(schoolId);

      for (final activity in activities) {
        await activitiesCollection.doc(activity["id"] as String).set(activity);
      }

      print('✅ Created ${activities.length} unique activities for school: $schoolId');
    } catch (e) {
      print('❌ Error setting up activities for school $schoolId: $e');
      rethrow;
    }
  }

  static List<Map<String, dynamic>> _getUniqueActivitiesForSchool(String schoolId) {
    final aug9 = DateTime(2025, 8, 9);

    switch (schoolId) {
      case 'daegu-gongsan':
        return [

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
            "description": "Help restore the beauty of the Onchon-Chon River! Together, we'll remove waste, raise awareness about water pollution, and take a step toward a healthier environment. Let's make a difference—one river at a time.",
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
            "id": "dg_workshop_upcoming",
            "title": "Planning upcoming activities",
            "type": "Workshop - Zoom",
            "points": 300,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.add(Duration(days: 15))),
            "endDate": Timestamp.fromDate(aug9.add(Duration(days: 15)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/planning.png",
            "description": "Planning and organizing upcoming community activities via Zoom. Join us to discuss and plan future environmental initiatives.",
            "location": "Online - Zoom",
            "communityName": "Daegu Community",
            "mapUrl": null,
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
            "description": "An educational and interactive seminar where local experts, activists, or educators discuss the causes, impacts, and solutions to climate change. Participants learn how their choices affect the environment and how they can contribute to climate action.",
            "location": "Daegu High School",
            "communityName": "Daegu Community",
            "mapUrl": "https://maps.google.com/?q=Daegu+High+School",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
          {
            "id": "dg_cooking_class_past",
            "title": "Green Cooking Class",
            "type": "Workshop - Zoom",
            "points": 350,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.subtract(Duration(days: 2))),
            "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 2)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/cooking.png",
            "description": "A fun and educational cooking class focused on sustainable and eco-friendly recipes. Learn to cook delicious meals while being environmentally conscious.",
            "location": "Online - Zoom",
            "communityName": "Daegu Community",
            "mapUrl": null,
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'jungheung':
        return [

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
            "description": "Learn practical ways to live more sustainably in your daily life. From reducing waste to energy conservation, discover simple changes that make a big impact.",
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
            "id": "jh_recycling_drive_upcoming",
            "title": "Recycling Awareness Drive",
            "type": "Campaign - Education",
            "points": 400,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.add(Duration(days: 18))),
            "endDate": Timestamp.fromDate(aug9.add(Duration(days: 18)).add(Duration(hours: 4))),
            "imageUrl": "assets/images/cleaning.png",
            "description": "Spread awareness about proper recycling practices in our community. Learn what can and cannot be recycled.",
            "location": "Jungheung District",
            "communityName": "Jungheung Community",
            "mapUrl": "https://maps.google.com/?q=Jungheung+District",
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
          {
            "id": "jh_street_cleaning_past",
            "title": "Street Cleaning Campaign",
            "type": "Campaign - Restoration",
            "points": 350,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.subtract(Duration(days: 7))),
            "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 7)).add(Duration(hours: 3))),
            "imageUrl": "assets/images/cleaning.png",
            "description": "Join our street cleaning campaign to help keep our community clean and green! Together we can make our streets beautiful.",
            "location": "Jungheung District",
            "communityName": "Jungheung Community",
            "mapUrl": "https://maps.google.com/?q=Jungheung+District",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'nam-samsung':
        return [

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
            "id": "ns_water_conservation_upcoming",
            "title": "Water Conservation Campaign",
            "type": "Campaign - Education",
            "points": 350,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.add(Duration(days: 16))),
            "endDate": Timestamp.fromDate(aug9.add(Duration(days: 16)).add(Duration(hours: 3))),
            "imageUrl": "assets/images/river.png",
            "description": "Learn about water conservation techniques and how to reduce water waste in your daily life.",
            "location": "Nam Samsung District",
            "communityName": "Nam Samsung Community",
            "mapUrl": "https://maps.google.com/?q=Nam+Samsung+District",
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
            "description": "Join our street cleaning campaign to help keep our community clean and green! Together we can make our streets beautiful.",
            "location": "Nam Samsung District",
            "communityName": "Nam Samsung Community",
            "mapUrl": "https://maps.google.com/?q=Nam+Samsung+District",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
          {
            "id": "ns_waste_audit_past",
            "title": "Household Waste Audit",
            "type": "Workshop - Education",
            "points": 300,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.subtract(Duration(days: 10))),
            "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 10)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/planning.png",
            "description": "Learn how to conduct a waste audit at home to understand your consumption habits and reduce waste.",
            "location": "Nam Samsung Community Hall",
            "communityName": "Nam Samsung Community",
            "mapUrl": "https://maps.google.com/?q=Nam+Samsung+Community+Hall",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'posan':
        return [

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
            "id": "ps_plastic_free_upcoming",
            "title": "Plastic-Free Living Challenge",
            "type": "Campaign - Education",
            "points": 400,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.add(Duration(days: 20))),
            "endDate": Timestamp.fromDate(aug9.add(Duration(days: 20)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/cleaning.png",
            "description": "Join our 30-day challenge to reduce plastic use in your daily life. Learn alternatives and share tips.",
            "location": "Posan Community Center",
            "communityName": "Posan Community",
            "mapUrl": "https://maps.google.com/?q=Posan+Community+Center",
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
          {
            "id": "ps_composting_basics_past",
            "title": "Composting Basics Workshop",
            "type": "Workshop - Practical",
            "points": 300,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.subtract(Duration(days: 9))),
            "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 9)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/cooking.png",
            "description": "Learn the fundamentals of composting and how to turn your organic waste into valuable soil.",
            "location": "Posan Community Garden",
            "communityName": "Posan Community",
            "mapUrl": "https://maps.google.com/?q=Posan+Community+Garden",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      case 'yangdong':
        return [

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
            "id": "yd_energy_efficiency_upcoming",
            "title": "Energy Efficiency Workshop",
            "type": "Workshop - Practical",
            "points": 450,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.add(Duration(days: 21))),
            "endDate": Timestamp.fromDate(aug9.add(Duration(days: 21)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/planning.png",
            "description": "Learn practical ways to make your home more energy efficient and reduce your carbon footprint.",
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
          {
            "id": "yd_green_tech_past",
            "title": "Green Technology Seminar",
            "type": "Seminar - Education",
            "points": 400,
            "participants": [],
            "participantCount": 0,
            "date": Timestamp.fromDate(aug9.subtract(Duration(days: 11))),
            "endDate": Timestamp.fromDate(aug9.subtract(Duration(days: 11)).add(Duration(hours: 2))),
            "imageUrl": "assets/images/seminar.png",
            "description": "Learn about the latest green technologies and how they can help reduce environmental impact.",
            "location": "Yangdong Community Hall",
            "communityName": "Yangdong Community",
            "mapUrl": "https://maps.google.com/?q=Yangdong+Community+Hall",
            "isUpcoming": false,
            "isCompleted": true,
            "schoolId": schoolId,
          },
        ];

      default:
        return [
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
  }
}