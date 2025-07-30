import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/notification_service.dart';
import '../services/language_service.dart';
import 'edit_profile_screen.dart';
import 'privacy_screen.dart';
import 'support_screen.dart';
import 'contact_screen.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppUser user;

  const SettingsScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English(US)';
  final NotificationService _notificationService = NotificationService();
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final notificationsEnabled = await _notificationService.isNotificationsEnabled();
      final currentLanguage = await _languageService.getCurrentLanguage();
      
      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _selectedLanguage = currentLanguage;
      });
    } catch (e) {
      print('❌ SettingsScreen: Error loading settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.questrial(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Account',
              children: [
                _buildSettingItem(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: widget.user),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildSection(
              title: 'General',
              children: [
                _buildToggleItem(
                  icon: Icons.notifications,
                  title: 'Notification',
                  value: _notificationsEnabled,
                  onChanged: (value) => _toggleNotifications(value),
                ),
                _buildSettingItem(
                  icon: Icons.lock,
                  title: 'Privacy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingItem(
                  icon: Icons.language,
                  title: 'Change Language',
                  subtitle: _selectedLanguage,
                  onTap: () => _showLanguageDialog(),
                ),
                _buildSettingItem(
                  icon: Icons.favorite_border,
                  title: 'Support Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupportScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingItem(
                  icon: Icons.contact_support,
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.questrial(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[200],
                      indent: 60,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.questrial(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.questrial(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.questrial(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
        activeTrackColor: Colors.green.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Logout',
          style: GoogleFonts.questrial(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    try {
      setState(() => _notificationsEnabled = value);
      
      if (value) {
        await _notificationService.enableNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications enabled'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _notificationService.disableNotifications();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications disabled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('❌ SettingsScreen: Error toggling notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update notifications'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: GoogleFonts.questrial(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English(US)', 'English(US)'),
            _buildLanguageOption('한국어', 'Korean'),
            _buildLanguageOption('Español', 'Spanish'),
            _buildLanguageOption('Français', 'French'),
            _buildLanguageOption('Deutsch', 'German'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.questrial(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.questrial(
          fontSize: 16,
        ),
      ),
      trailing: _selectedLanguage == value
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () async {
        try {
          await _languageService.setLanguage(value);
          setState(() => _selectedLanguage = value);
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Language changed to $title'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('❌ SettingsScreen: Error changing language: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change language'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ),
        (route) => false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ SettingsScreen: Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 