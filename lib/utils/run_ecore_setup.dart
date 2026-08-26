import 'ecore_setup.dart';

class RunEcoreSetup {
  static Future<void> runSetup() async {
    try {
      print('🎮 Starting ClimaGame eCore Setup...');
      print('📍 Setting up 3 eCores around Stanford Hotel Seoul');
      print('📋 Total missions: 15 (13 provided + 2 new)');

      await EcoreSetup.setupEcores();

      print('\n🎯 Setup Summary:');
      print('🏨 Stanford Hotel Lobby: 5 missions');
      print('🍽️ Stanford Hotel Restaurant: 5 missions');
      print('🌳 Near Stanford Hotel Park: 5 missions');
      print('\n✅ All eCores are ready for ClimaGame!');

    } catch (e) {
      print('❌ Error during eCore setup: $e');
      rethrow;
    }
  }

  static Future<void> updateMissionImage(String missionId, String imageUrl) async {
    try {
      print('🖼️ Updating mission image for: $missionId');
      await EcoreSetup.updateMissionImage(missionId, imageUrl);
      print('✅ Mission image updated successfully!');
    } catch (e) {
      print('❌ Error updating mission image: $e');
      rethrow;
    }
  }

  static Future<void> toggleEcoreStatus(String ecoreId, bool isActive) async {
    try {
      print('🔄 ${isActive ? 'Activating' : 'Deactivating'} eCore: $ecoreId');
      await EcoreSetup.updateEcoreStatus(ecoreId, isActive);
      print('✅ eCore status updated successfully!');
    } catch (e) {
      print('❌ Error updating eCore status: $e');
      rethrow;
    }
  }

  static Future<void> resetEcore(String ecoreId) async {
    try {
      print('🔄 Resetting conquest status for eCore: $ecoreId');
      await EcoreSetup.resetEcoreConquest(ecoreId);
      print('✅ eCore reset successfully!');
    } catch (e) {
      print('❌ Error resetting eCore: $e');
      rethrow;
    }
  }
}