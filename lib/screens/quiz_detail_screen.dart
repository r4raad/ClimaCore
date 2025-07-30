import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizDetailScreen extends StatefulWidget {
  final Quiz quiz;
  final QuizProgress? progress;

  const QuizDetailScreen({
    Key? key,
    required this.quiz,
    this.progress,
  }) : super(key: key);

  @override
  _QuizDetailScreenState createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _startQuiz() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to start the quiz')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      QuizProgress progress;
      
      if (widget.progress != null) {
        progress = widget.progress!;
      } else {
        progress = await QuizService.createQuizProgress(
          _userId!,
          widget.quiz.id,
          widget.quiz.questions.length,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizTakingScreen(
            quiz: widget.quiz,
            progress: progress,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start quiz: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Details'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Image
            if (widget.quiz.imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.quiz.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.quiz,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
              ),

            SizedBox(height: 20),

            // Quiz Title
            Text(
              widget.quiz.title,
              style: GoogleFonts.questrial(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 8),

            // Quiz Description
            Text(
              widget.quiz.description,
              style: GoogleFonts.questrial(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 20),

            // Quiz Stats
            _buildQuizStats(),

            SizedBox(height: 30),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.progress != null ? 'Continue Quiz' : 'Start Quiz',
                        style: GoogleFonts.questrial(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStats() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildStatRow('Questions', '${widget.quiz.questionCount}'),
          Divider(),
          _buildStatRow('Time Limit', '${widget.quiz.timeLimit} min'),
          Divider(),
          _buildStatRow('Points', '${widget.quiz.points}'),
          Divider(),
          _buildStatRow('Rating', '${widget.quiz.rating}/5'),
          Divider(),
          _buildStatRow('Category', widget.quiz.category),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.questrial(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.questrial(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  final QuizProgress progress;

  const QuizTakingScreen({
    Key? key,
    required this.quiz,
    required this.progress,
  }) : super(key: key);

  @override
  _QuizTakingScreenState createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentQuestionIndex = widget.progress.currentQuestion;
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
      final isCorrect = _selectedAnswer == currentQuestion.correctAnswerId;

      await QuizService.submitAnswer(
        widget.progress,
        currentQuestion.id,
        _selectedAnswer!,
        isCorrect,
      );

      if (_currentQuestionIndex + 1 >= widget.quiz.questions.length) {
        // Quiz completed
        // Fetch the latest progress from Firestore
        final latestProgress = await QuizService.getQuizProgressById(widget.progress.id);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              quiz: widget.quiz,
              progress: latestProgress ?? widget.progress,
            ),
          ),
        );
      } else {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answer: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),

            SizedBox(height: 20),

            // Question
            Text(
              currentQuestion.question,
              style: GoogleFonts.questrial(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 20),

                         // Answer Options
             Expanded(
               child: ListView.builder(
                 itemCount: currentQuestion.answers.length,
                 itemBuilder: (context, index) {
                   final option = currentQuestion.answers[index];
                  final isSelected = _selectedAnswer == option.id;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAnswer = option.id;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF4CAF50) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Color(0xFF4CAF50) : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white : Colors.grey[300],
                                ),
                                child: isSelected
                                    ? Icon(Icons.check, size: 14, color: Color(0xFF4CAF50))
                                    : null,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: GoogleFonts.questrial(
                                    fontSize: 16,
                                    color: isSelected ? Colors.white : Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAnswer == null || _isSubmitting ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentQuestionIndex + 1 >= widget.quiz.questions.length
                            ? 'Finish Quiz'
                            : 'Next Question',
                        style: GoogleFonts.questrial(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatefulWidget {
  final Quiz quiz;
  final QuizProgress progress;

  const QuizResultScreen({
    Key? key,
    required this.quiz,
    required this.progress,
  }) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _pointsAwarded = false;

  @override
  void initState() {
    super.initState();
    _awardPoints();
  }

  Future<void> _awardPoints() async {
    if (_pointsAwarded) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userService = UserService();
        
        // Award points based on quiz performance
        final score = (widget.progress.correctAnswers / widget.progress.totalQuestions * 100).round();
        int pointsToAward = 0;
        
        if (score >= 90) {
          pointsToAward = widget.quiz.points; // Full points for 90%+
        } else if (score >= 70) {
          pointsToAward = (widget.quiz.points * 0.8).round(); // 80% points for 70%+
        } else if (score >= 50) {
          pointsToAward = (widget.quiz.points * 0.5).round(); // 50% points for 50%+
        }
        
        if (pointsToAward > 0) {
          await userService.addUserPoints(user.uid, pointsToAward);
          await userService.addUserAction(user.uid);
          await userService.addWeekPoints(user.uid, pointsToAward);
          
          setState(() {
            _pointsAwarded = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('+$pointsToAward points earned!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ QuizResult: Error awarding points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = (widget.progress.correctAnswers / widget.progress.totalQuestions * 100).round();
    final isPassed = score >= 70;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Results'),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              size: 80,
              color: isPassed ? Colors.amber : Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              isPassed ? 'Congratulations!' : 'Keep Learning!',
              style: GoogleFonts.questrial(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You scored $score%',
              style: GoogleFonts.questrial(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            _buildResultCard(),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Back to Quizzes',
                  style: GoogleFonts.questrial(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildResultRow('Correct Answers', '${widget.progress.correctAnswers}/${widget.progress.totalQuestions}'),
          Divider(),
          _buildResultRow('Time Spent', '${widget.progress.timeSpent} min'),
          Divider(),
          _buildResultRow('Points Earned', '${widget.progress.score}'),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.questrial(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.questrial(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
} 