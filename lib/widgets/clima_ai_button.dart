import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          child: SvgPicture.asset(
            'icons/ai.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => Icon(
              Icons.psychology,
              size: 20,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ),
    );
  }
}