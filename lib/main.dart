import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/google_maps_loader.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'screens/climasights_screen.dart';
import 'screens/quiz_detail_screen.dart';
import 'screens/profile_picture_upload_screen.dart';
import 'screens/climagame_test_screen.dart';
import 'models/quiz.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/quiz_service.dart';
import 'utils/supabase_config.dart';
import 'utils/env_config.dart';
import 'utils/transitions.dart';
import 'utils/run_migration.dart';
import 'utils/run_ecore_setup.dart';
import 'utils/repopulate_quizzes.dart';
import 'utils/test_quiz_loading.dart';
import 'utils/memory_optimizer.dart';
import 'utils/performance_optimizer.dart';
import 'utils/android_optimizer.dart';
import 'utils/performance_monitor.dart';
import 'utils/android_map_optimizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('🚨 Flutter Error: ${details.exception}');
    print('🚨 Stack trace: ${details.stack}');
  };

  ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler('error', (ByteData? data) async {
    print('🚨 Platform Error Handler');
    return null;
  });

  MemoryOptimizer.initialize();
  PerformanceOptimizer.initialize();
  AndroidOptimizer.initialize();
  AndroidMapOptimizer.initialize();
  PerformanceMonitor.startMonitoring();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    try {
      await dotenv.load();
    } catch (e2) {}
  }

  if (kIsWeb) {
    initGoogleMapsWeb(EnvConfig.googleMapsApiKey);
  }

  try {
    if (EnvConfig.isSupabaseConfigured) {
      await SupabaseConfig.initialize();
    }
  } catch (e) {

  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await RunMigration.fixWeeklyPoints();

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
            return AppTransitions.fadeTransition(SplashScreen());
          case '/auth':
            return AppTransitions.slideFromRight(AuthScreen());
          case '/home':
            return AppTransitions.slideFromRight(MainScreen());
          case '/quiz-detail':
            final args = settings.arguments;
            Widget quizScreen;
            if (args is Map<String, dynamic>) {
              quizScreen = QuizDetailScreen(
                quiz: args['quiz'],
                attempt: args['attempt'],
              );
            } else if (args is Quiz) {
              quizScreen = QuizDetailScreen(quiz: args);
            } else {
              quizScreen = Scaffold(
                appBar: AppBar(title: Text('Error')),
                body: Center(child: Text('Invalid quiz data')),
              );
            }
            return AppTransitions.cardTransition(quizScreen);
          case '/profile-picture-upload':
            final args = settings.arguments;
            Widget uploadScreen;
            if (args is Map<String, dynamic>) {
              uploadScreen = ProfilePictureUploadScreen(
                user: args['user'],
                isFromRegistration: args['isFromRegistration'] ?? false,
              );
            } else {
              uploadScreen = Scaffold(
                appBar: AppBar(title: Text('Error')),
                body: Center(child: Text('Invalid user data')),
              );
            }
            return AppTransitions.modalTransition(uploadScreen);
                     case '/climasights':
             final args = settings.arguments;
             Widget climasightsScreen;
             if (args is Map<String, dynamic> && args['user'] != null) {
               climasightsScreen = ClimaSightsScreen(user: args['user']);
             } else {
               climasightsScreen = Scaffold(
                 appBar: AppBar(title: Text('Error')),
                 body: Center(child: Text('User data required')),
               );
             }
             return AppTransitions.slideFromBottom(climasightsScreen);
           case '/climagame-test':
             return AppTransitions.slideFromRight(ClimaGameTestScreen());
           default:
             return AppTransitions.fadeTransition(SplashScreen());
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
        scaffoldBackgroundColor: Colors.transparent,
      ),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF0F8FF),
                Color(0xFFE6F3FF),
                Color(0xFFE8F5E8),
                Color(0xFFF0FFF0),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
