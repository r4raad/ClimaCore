import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ecore.dart';

class EcoreSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double USER_LOCATION_LAT = 37.582478;
  static const double USER_LOCATION_LNG = 126.8869776;

  static const double NEARBY_LOCATION_LAT = 37.583478;
  static const double NEARBY_LOCATION_LNG = 126.8879776;

  static List<EcoreMission> getAllMissions() {
    return [

      EcoreMission(
        id: 'using_tumbler',
        title: 'Using Tumbler',
        description: 'Use a reusable tumbler instead of disposable cups',
        summary: 'Using a tumbler is a great way to reduce the use of disposable products. If you bring your own, you can save money too — no need to keep buying single-use cups!',
        tips: [
          'Please take pictures by showing the tumbler.',
          'You can use a tumbler to drink water or take out drinks.'
        ],
        categories: ['waste_reduction', 'sustainable_living'],
        points: 50,
        imageUrl: 'assets/images/missions/using_tumbler.png',
      ),

      EcoreMission(
        id: 'riding_bike',
        title: 'Riding a Bike',
        description: 'Use a bicycle for transportation',
        summary: 'Riding a bike is great for both you and the Earth. It\'s even more eco-friendly than taking the bus or subway, and it gives off about the same amount of carbon as walking! Additionally, it\'s a great way to maintain your health.',
        tips: [
          'Take a picture that shows you are riding a bike.',
          'You can ride it when going to school or just for exercise!',
          'If you do not own a bike, you can purchase one affordably second-hand.'
        ],
        categories: ['transportation', 'health'],
        points: 75,
        imageUrl: 'assets/images/missions/riding_bike.png',
      ),

      EcoreMission(
        id: 'separate_recycling',
        title: 'Separate Recycling',
        description: 'Properly sort and recycle waste materials',
        summary: 'Recycling helps save resources and protects the environment. By sorting out recyclables, we can reduce pollution and cut down on the carbon emissions from landfills and incineration. It also uses less energy compared to making new products from scratch.',
        tips: [
          'Take a picture showing you are recycling.',
          'You can ask your parents to give you anything to separate the recyclables (or trash).'
        ],
        categories: ['waste_reduction', 'recycling'],
        points: 60,
        imageUrl: 'assets/images/missions/separate_recycling.png',
      ),

      EcoreMission(
        id: 'walking',
        title: 'Walking',
        description: 'Walk instead of using motorized transportation',
        summary: 'Walking helps reduce air pollution and greenhouse gas emissions. Also, it helps to promote health. It is an activity that helps solve environmental problems and promote health at the same time.',
        tips: [
          'Take a picture that shows outside, also showing you wearing shoes.',
          'There are many apps that measure the number of steps.',
          'Start by walking to school or somewhere near!'
        ],
        categories: ['transportation', 'health'],
        points: 40,
        imageUrl: 'assets/images/missions/walking.png',
      ),

      EcoreMission(
        id: 'emptying_trays',
        title: 'Emptying Trays',
        description: 'Finish all your food to reduce waste',
        summary: 'Emptying Trays, which means eating all your breakfast, lunch, or dinner can reduce food processing costs. It also helps to reduce greenhouse gas emissions generated during food waste disposal.',
        tips: [
          'Take a picture of an emptied tray.',
          'Before the meal, you can take a smaller portion at first.'
        ],
        categories: ['food_waste', 'sustainable_living'],
        points: 45,
        imageUrl: 'assets/images/missions/emptying_trays.png',
      ),

      EcoreMission(
        id: 'turning_off_lights',
        title: 'Turning Off Lights',
        description: 'Turn off unnecessary lights to save energy',
        summary: 'Turning off unnecessary lights is a very simple way to save electricity. Reducing electricity use helps lower greenhouse gas emissions, too!',
        tips: [
          'Take a picture of the lights off.',
          'Make it a habit to turn off the lights when leaving a room.',
          'Try to use natural sunlight as much as possible.'
        ],
        categories: ['energy_conservation', 'sustainable_living'],
        points: 35,
        imageUrl: 'assets/images/missions/turning_off_lights.png',
      ),

      EcoreMission(
        id: 'unplugging_devices',
        title: 'Unplugging Devices',
        description: 'Unplug unused electronic devices',
        summary: 'Unplugging unused electronic devices helps reduce standby power, which saves energy. It\'s a small action, but doing it regularly can make a big difference.',
        tips: [
          'Take a picture of the unplugged plug and its outlet or power strip.',
          'Get into the habit of unplugging devices when you\'re not using them.',
          'Turning off the power switch on a power strip works well too!'
        ],
        categories: ['energy_conservation', 'sustainable_living'],
        points: 40,
        imageUrl: 'assets/images/missions/unplugging_devices.png',
      ),

      EcoreMission(
        id: 'meatless_meals',
        title: 'Meatless Meals',
        description: 'Eat plant-based meals to reduce carbon footprint',
        summary: 'Eating meals without meat and instead using vegetables, beans, or grains can significantly reduce greenhouse gas emissions caused by livestock farming. It\'s good for both the environment and your health.',
        tips: [
          'Take a picture of your meal with vegetables instead of meat!',
          'Try eating mostly plant-based meals.',
          'Dishes like soy meat or mushroom steak are a great way to start!'
        ],
        categories: ['food', 'health', 'carbon_reduction'],
        points: 80,
        imageUrl: 'assets/images/missions/meatless_meals.png',
      ),

      EcoreMission(
        id: 'setting_ac_temperature',
        title: 'Setting Air Conditioner Temperature',
        description: 'Set AC to moderate temperature (24-26°C)',
        summary: 'Not setting the air conditioner to very low temperatures can save a lot of energy. Maintaining a moderate indoor temperature benefits both the Earth and your comfort.',
        tips: [
          'Take a picture of an air conditioner that is 24–26°C (75–79°F).',
          'Keep the air conditioner set between 24–26°C (75–79°F).',
          'Use it together with a fan for better efficiency.'
        ],
        categories: ['energy_conservation', 'sustainable_living'],
        points: 50,
        imageUrl: 'assets/images/missions/setting_ac_temperature.png',
      ),

      EcoreMission(
        id: 'turning_off_faucet',
        title: 'Turning Off the Faucet',
        description: 'Turn off water when not actively using it',
        summary: 'Turning off the faucet while brushing your teeth or washing your hands can save a lot of water. Saving water is an important first step to protecting our planet.',
        tips: [
          'Take a picture of a closed faucet.',
          'Try using a cup while brushing your teeth.',
          'Avoid leaving the water running while washing your hands or doing dishes.'
        ],
        categories: ['water_conservation', 'sustainable_living'],
        points: 30,
        imageUrl: 'assets/images/missions/turning_off_faucet.png',
      ),

      EcoreMission(
        id: 'using_public_transportation',
        title: 'Using Public Transportation',
        description: 'Take bus or subway instead of driving',
        summary: 'Taking the bus or subway emits far less carbon than driving a car. It\'s a convenient and eco-friendly way to get around.',
        tips: [
          'Take a picture of a bus or subway.',
          'Use public transportation for short and long trips.',
          'Try it together with your family on outings!'
        ],
        categories: ['transportation', 'carbon_reduction'],
        points: 65,
        imageUrl: 'assets/images/missions/using_public_transportation.png',
      ),

      EcoreMission(
        id: 'using_bag_instead_of_plastic',
        title: 'Using a Bag Instead of Plastic Bags',
        description: 'Use reusable shopping bags',
        summary: 'Using a reusable shopping bag or eco-bag helps reduce plastic waste. It\'s a very simple but effective way to help the environment.',
        tips: [
          'Take a picture holding a reusable bag.',
          'Carry a reusable bag with you at all times.',
          'Use your own bag instead of plastic ones when shopping.'
        ],
        categories: ['waste_reduction', 'plastic_reduction'],
        points: 45,
        imageUrl: 'assets/images/missions/using_bag_instead_of_plastic.png',
      ),

      EcoreMission(
        id: 'growing_plants',
        title: 'Growing Plants',
        description: 'Care for indoor or outdoor plants',
        summary: 'Plants absorb carbon dioxide and produce oxygen, helping to clean the air indoors. Taking care of plants is a healthy habit and connects you with nature.',
        tips: [
          'Take a picture of your plant.',
          'Water your plants regularly and make sure they get sunlight.',
          'Keep a plant growth journal for a month to observe their changes.'
        ],
        categories: ['nature', 'air_quality', 'health'],
        points: 70,
        imageUrl: 'assets/images/missions/growing_plants.png',
      ),

      EcoreMission(
        id: 'using_stairs',
        title: 'Using Stairs Instead of Elevator',
        description: 'Choose stairs over elevators for short distances',
        summary: 'Using stairs instead of elevators for short distances saves electricity and provides great exercise. It\'s a simple way to reduce energy consumption while improving your health.',
        tips: [
          'Take a picture of yourself using the stairs.',
          'Start with 1-2 floors and gradually increase.',
          'Make it a habit for short trips between floors.'
        ],
        categories: ['energy_conservation', 'health', 'transportation'],
        points: 55,
        imageUrl: 'assets/images/missions/using_stairs.png',
      ),

      EcoreMission(
        id: 'digital_detox',
        title: 'Digital Detox Hour',
        description: 'Spend one hour without electronic devices',
        summary: 'Taking breaks from electronic devices not only saves energy but also improves mental health and reduces digital waste. It\'s a great way to reconnect with the real world.',
        tips: [
          'Take a picture of your devices turned off.',
          'Use this time to read a book, go outside, or talk with family.',
          'Try to do this daily for at least one hour.'
        ],
        categories: ['energy_conservation', 'mental_health', 'sustainable_living'],
        points: 60,
        imageUrl: 'assets/images/missions/digital_detox.png',
      ),
    ];
  }

  static List<Ecore> getAllEcores() {
    final allMissions = getAllMissions();

    return [

      Ecore(
        id: 'nearby_ecore',
        name: 'Nearby eCore',
        latitude: USER_LOCATION_LAT + 0.0001,
        longitude: USER_LOCATION_LNG + 0.0001,
        missions: allMissions.take(5).toList(),
        totalPoints: allMissions.take(5).fold(0, (sum, mission) => sum + mission.points),
        isActive: true,
        isDiscovered: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  static Future<void> setupEcores() async {
    try {
      print('🚀 Starting eCore setup...');

      final existingSnapshot = await _firestore.collection('ecores').get();
      if (existingSnapshot.docs.isNotEmpty) {
        print('⚠️ eCores already exist in database. Skipping setup.');
        print('📊 Found ${existingSnapshot.docs.length} existing eCores:');
        for (final doc in existingSnapshot.docs) {
          final data = doc.data();
          print('  - ${data['name']} (ID: ${doc.id})');
        }
        return;
      }

      final ecores = getAllEcores();

      for (final ecore in ecores) {
        await _firestore.collection('ecores').doc(ecore.id).set(ecore.toMap());
        print('✅ Created eCore: ${ecore.name} with ${ecore.missions.length} missions');
      }

      print('🎉 All eCores setup completed successfully!');
      print('📊 Total eCores: ${ecores.length}');
      print('📋 Total missions: ${getAllMissions().length}');

    } catch (e) {
      print('❌ Error setting up eCores: $e');
      rethrow;
    }
  }

  static Future<void> updateMissionImage(String missionId, String imageUrl) async {
    try {

      final ecores = getAllEcores();

      for (final ecore in ecores) {
        final missionIndex = ecore.missions.indexWhere((m) => m.id == missionId);
        if (missionIndex != -1) {
          final updatedMissions = List<EcoreMission>.from(ecore.missions);
          updatedMissions[missionIndex] = updatedMissions[missionIndex].copyWith(
            imageUrl: imageUrl,
          );

          await _firestore.collection('ecores').doc(ecore.id).update({
            'missions': updatedMissions.map((m) => m.toMap()).toList(),
          });

          print('✅ Updated mission image for: $missionId in ${ecore.name}');
        }
      }
    } catch (e) {
      print('❌ Error updating mission image: $e');
      rethrow;
    }
  }

  static Future<void> updateEcoreStatus(String ecoreId, bool isActive) async {
    try {
      await _firestore.collection('ecores').doc(ecoreId).update({
        'isActive': isActive,
      });
      print('✅ Updated eCore status: $ecoreId -> isActive: $isActive');
    } catch (e) {
      print('❌ Error updating eCore status: $e');
      rethrow;
    }
  }

  static Future<void> resetEcoreConquest(String ecoreId) async {
    try {
      await _firestore.collection('ecores').doc(ecoreId).update({
        'conqueredBySchoolId': null,
        'conqueredBySchoolName': null,
        'conqueredAt': null,
        'coolingTimeEnd': null,
      });
      print('✅ Reset conquest status for eCore: $ecoreId');
    } catch (e) {
      print('❌ Error resetting eCore conquest: $e');
      rethrow;
    }
  }

  static Future<void> createSampleEcores() async {
    try {
      print('🚀 Creating sample eCores...');
      await setupEcores();
      print('✅ Sample eCores created successfully!');
    } catch (e) {
      print('❌ Error creating sample eCores: $e');
      rethrow;
    }
  }

  static Future<void> clearAllEcores() async {
    try {
      print('🗑️ Clearing all eCores...');

      final querySnapshot = await _firestore.collection('ecores').get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ All eCores cleared successfully!');
    } catch (e) {
      print('❌ Error clearing eCores: $e');
      rethrow;
    }
  }

  static Future<void> listAllEcores() async {
    try {
      print('📋 Listing all eCores...');

      final querySnapshot = await _firestore.collection('ecores').get();

      if (querySnapshot.docs.isEmpty) {
        print('📭 No eCores found in database');
        return;
      }

      print('📊 Found ${querySnapshot.docs.length} eCores:');
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        print('  - ${data['name']} (ID: ${doc.id})');
        print('    Missions: ${(data['missions'] as List).length}');
        print('    Total Points: ${data['totalPoints']}');
        print('    Active: ${data['isActive']}');
        print('');
      }
    } catch (e) {
      print('❌ Error listing eCores: $e');
      rethrow;
    }
  }
}