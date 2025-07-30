import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/ai_chat_screen.dart';
import '../models/user.dart';

class ClimaAIButton extends StatelessWidget {
  final AppUser user;
  
  const ClimaAIButton({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIChatScreen(user: user),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Q',
            style: GoogleFonts.questrial(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ),
    );
  }
} 