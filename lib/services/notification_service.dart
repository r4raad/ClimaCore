import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _notificationKey = 'notifications_enabled';

  Future<bool> isNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationKey) ?? true;
    } catch (e) {
      print('❌ NotificationService: Error checking notification status: $e');
      return true;
    }
  }

  Future<void> enableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, true);
      print('✅ NotificationService: Notifications enabled');
    } catch (e) {
      print('❌ NotificationService: Error enabling notifications: $e');
      rethrow;
    }
  }

  Future<void> disableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, false);
      print('✅ NotificationService: Notifications disabled');
    } catch (e) {
      print('❌ NotificationService: Error disabling notifications: $e');
      rethrow;
    }
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final isEnabled = await isNotificationsEnabled();
      if (!isEnabled) return;

      // In a real app, you would use flutter_local_notifications or firebase_messaging
      print('📱 NotificationService: Sending notification - $title: $body');
      
      // For now, just log the notification
      // TODO: Implement actual notification sending
    } catch (e) {
      print('❌ NotificationService: Error sending notification: $e');
    }
  }
} 