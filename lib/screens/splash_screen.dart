import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkCurrentUser();
  }
  
  void _setupAnimations() {
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _logoController.forward();
    Future.delayed(Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });
  }

  _checkCurrentUser() async {
    await Future.delayed(Duration(seconds: 3)); 
    
    if (!mounted) return; // Check if widget is still mounted
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (!mounted) return; // Check again before navigation
      
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } else {
        // Create dummy users after authentication
        try {
          await UserService().ensureDummyUsersExist();
        } catch (e) {
          print('⚠️ Warning: Could not create dummy users: $e');
        }
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: Image.asset(AppConstants.appLogoPath, height: 150),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _textFade,
              child: Text(
                AppConstants.appName, 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            FadeTransition(
              opacity: _textFade,
              child: Text('Empowering Change From The Core'),
            ),
          ],
        ),
      ),
    );
  }
}