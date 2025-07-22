
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart'; 
import 'screens/auth_screen.dart'; 
import 'screens/main_screen.dart'; // Import the new MainScreen
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ClimaCore());
}

class ClimaCore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClimaCore',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/auth': (context) => AuthScreen(),
        '/home': (context) => MainScreen(), // Use MainScreen for the home route
      },
      theme: ThemeData(
        textTheme: GoogleFonts.questrialTextTheme(Theme.of(context).textTheme),
      ),
    );
  }
}
