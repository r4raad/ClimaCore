import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_message.dart';

class AIMessageBubble extends StatelessWidget {
  final AIMessage message;
  final VoidCallback? onCopy;

  const AIMessageBubble({
    Key? key,
    required this.message,
    this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.grey[200] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: isUser ? null : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    message.content,
                    style: GoogleFonts.questrial(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
                
                if (!isUser && onCopy != null) ...[
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onCopy,
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Copy',
                              style: GoogleFonts.questrial(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4CAF50),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 