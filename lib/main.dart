
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'screens/splash_screen.dart'; 
import 'screens/auth_screen.dart'; 
import 'screens/main_screen.dart';
import 'screens/climasights_screen.dart';
import 'screens/quiz_detail_screen.dart';
import 'screens/profile_picture_upload_screen.dart'; // Added import
import 'models/quiz.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/user_service.dart';
import 'utils/database_populator.dart'; // Added import for database population utility
import 'utils/supabase_config.dart'; // Added import for Supabase configuration
import 'utils/env_config.dart'; // Added import for environment configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Environment variables are now hardcoded in EnvConfig
  print('✅ Using hardcoded API configuration');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase for image storage - with better error handling
  try {
    if (EnvConfig.isSupabaseConfigured) {
      await SupabaseConfig.initialize();
      print('✅ Supabase initialized successfully');
    } else {
      print('⚠️ Supabase not configured. Image uploads will not work.');
    }
  } catch (e) {
    print('⚠️ Error initializing Supabase: $e');
    print('⚠️ Image uploads will not work.');
  }

  // Note: All data comes from Firebase Firestore
  // No hardcoded data is used in the app
  // Set up your Firebase database with real data before running the app

  // Automatically create dummy users if database is empty (runs only once)
  await DatabasePopulator.populateWithDummyUsers();

  runApp(ClimaCore());
}

class ClimaCore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClimaCore',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => SplashScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
            );
          case '/auth':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 400),
            );
          case '/home':
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 400),
            );
          case '/quiz-detail':
            final args = settings.arguments;
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) {
                if (args is Map<String, dynamic>) {
                  return QuizDetailScreen(
                    quiz: args['quiz'],
                    progress: args['progress'],
                  );
                } else if (args is Quiz) {
                  return QuizDetailScreen(quiz: args);
                } else {
                  // Fallback to a default quiz or show error
                  return Scaffold(
                    appBar: AppBar(title: Text('Error')),
                    body: Center(child: Text('Invalid quiz data')),
                  );
                }
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 400),
            );
          case '/profile-picture-upload':
            final args = settings.arguments;
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) {
                if (args is Map<String, dynamic>) {
                  return ProfilePictureUploadScreen(
                    user: args['user'],
                    isFromRegistration: args['isFromRegistration'] ?? false,
                  );
                } else {
                  return Scaffold(
                    appBar: AppBar(title: Text('Error')),
                    body: Center(child: Text('Invalid user data')),
                  );
                }
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 400),
            );
          default:
            return PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) => SplashScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
            );
        }
      },
      theme: ThemeData(
        textTheme: GoogleFonts.questrialTextTheme(Theme.of(context).textTheme),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}
