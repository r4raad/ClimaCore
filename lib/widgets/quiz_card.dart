import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;
  final bool isCompleted;
  final bool isPerfectlyCompleted;
  final int? bestScore;

  const QuizCard({
    Key? key,
    required this.quiz,
    this.onTap,
    this.isCompleted = false,
    this.isPerfectlyCompleted = false,
    this.bestScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isPerfectlyCompleted
            ? Colors.green.withOpacity(0.1)
            : isCompleted
                ? Colors.blue.withOpacity(0.05)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPerfectlyCompleted
            ? Border.all(color: Colors.green, width: 2)
            : isCompleted
                ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isPerfectlyCompleted ? 0.15 : 0.1),
            blurRadius: isPerfectlyCompleted ? 12 : 8,
            offset: Offset(0, isPerfectlyCompleted ? 4 : 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isPerfectlyCompleted ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
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
                      Text(
                        quiz.title,
                        style: GoogleFonts.questrial(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
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
                                '${quiz.questionCount} Question',
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
                                _formatTime(quiz.timeLimit),
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

                SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          quiz.rating.toString(),
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 16,
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${quiz.points}',
                          style: GoogleFonts.questrial(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
              ),
            ),
          ),

          if (isCompleted)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPerfectlyCompleted ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPerfectlyCompleted ? Icons.star : Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      isPerfectlyCompleted
                          ? 'PERFECT'
                          : bestScore != null
                              ? '${bestScore}%'
                              : 'DONE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (isPerfectlyCompleted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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