import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/email_auth_form.dart';
import '../constants.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
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
                Navigator.of(context).pushReplacementNamed('/home');
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
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(AppConstants.appLogoPath, height: 100),
                ),
                SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Welcome to '+ AppConstants.appName, 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]), 
                  ),
                ),
                SizedBox(height: 10),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Your all-in-one space to learn, act, and lead the way in climate action.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]), 
                  ),
                ),
                SizedBox(height: 30),
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: EmailAuthForm(showSuccessDialog: _showSuccessDialog, registerButtonTextStyle: TextStyle(color: Color(0xfff2f0ef))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}