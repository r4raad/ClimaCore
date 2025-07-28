import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';

class QuizProgressCard extends StatelessWidget {
  final Quiz quiz;
  final QuizProgress progress;
  final VoidCallback? onContinue;
  final VoidCallback? onDelete;

  const QuizProgressCard({
    Key? key,
    required this.quiz,
    required this.progress,
    this.onContinue,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getQuizIconColor(quiz.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getQuizIcon(quiz.category),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                quiz.title,
                                style: GoogleFonts.questrial(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            if (onDelete != null)
                              GestureDetector(
                                onTap: onDelete,
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        
                        SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${progress.currentQuestion}/${progress.totalQuestions} Question',
                                  style: GoogleFonts.questrial(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(width: 16),
                            
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _formatTime(progress.timeSpent),
                                  style: GoogleFonts.questrial(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              if (onContinue != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue Quiz',
                      style: GoogleFonts.questrial(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQuizIconColor(String category) {
    switch (category.toLowerCase()) {
      case 'climate science':
        return Colors.blue;
      case 'sustainability':
        return Colors.green;
      case 'environmental science':
        return Colors.teal;
      case 'renewable energy':
        return Colors.orange;
      default:
        return Color(0xFF4CAF50);
    }
  }

  IconData _getQuizIcon(String category) {
    switch (category.toLowerCase()) {
      case 'climate science':
        return Icons.wb_sunny;
      case 'sustainability':
        return Icons.eco;
      case 'environmental science':
        return Icons.nature;
      case 'renewable energy':
        return Icons.electric_bolt;
      default:
        return Icons.quiz;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '$minutes min ${remainingSeconds > 0 ? '$remainingSeconds sec' : ''}';
    } else {
      return '$remainingSeconds sec';
    }
  }
} 