import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/email_auth_form.dart';
import '../constants.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Column( 
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppConstants.appLogoPath, height: 80),
              SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Image.asset(AppConstants.appLogoPath, height: 100), 
                SizedBox(height: 20),
                Text(
                  'Welcome to '+ AppConstants.appName, 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]), 
                ),
                SizedBox(height: 10),
                Text(
                  'Your all-in-one space to learn, act, and lead the way in climate action.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]), 
                ),
                SizedBox(height: 30),
                EmailAuthForm(showSuccessDialog: _showSuccessDialog, registerButtonTextStyle: TextStyle(color: Color(0xfff2f0ef))), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}