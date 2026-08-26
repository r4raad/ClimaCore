import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/transitions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuizDetailScreen extends StatefulWidget {
  final Quiz quiz;
  final QuizAttempt? attempt;

  const QuizDetailScreen({
    Key? key,
    required this.quiz,
    this.attempt,
  }) : super(key: key);

  @override
  _QuizDetailScreenState createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _isLoading = false;
  String? _userId;
  bool _isPerfectlyCompleted = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _checkPerfectCompletion();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> _checkPerfectCompletion() async {
    if (_userId != null) {
      final isPerfect = await QuizService.hasUserCompletedQuizPerfectly(_userId!, widget.quiz.id);
      if (mounted) {
        setState(() {
          _isPerfectlyCompleted = isPerfect;
        });
      }
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
      QuizAttempt attempt;

      if (widget.attempt != null) {
        attempt = widget.attempt!;
        print('🔍 Using existing attempt: ${attempt.id}');
      } else {

        final latestAttempt = await QuizService.getUserLatestAttempt(_userId!, widget.quiz.id);
        if (latestAttempt != null && !latestAttempt.isCompleted && latestAttempt.totalQuestions == widget.quiz.questions.length) {
          attempt = latestAttempt;
          print('🔍 Resuming existing attempt: ${attempt.id}');
        } else {
          attempt = await QuizService.createQuizAttempt(
            _userId!,
            widget.quiz.id,
            widget.quiz.questions.length,
          );
          print('🔍 Created new attempt: ${attempt.id} with ${widget.quiz.questions.length} questions');
        }
      }

      print('🔍 Quiz Debug - Total Questions: ${widget.quiz.questions.length}');
      print('🔍 Quiz Debug - Attempt Total Questions: ${attempt.totalQuestions}');
      print('🔍 Quiz Debug - Attempt Correct Answers: ${attempt.correctAnswers}');

      Navigator.pushReplacement(
        context,
        AppTransitions.slideFromRight(QuizTakingScreen(
          quiz: widget.quiz,
          attempt: attempt,
        )),
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

  Widget _buildCompletedButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[400]!),
      ),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Quiz Completed Perfectly',
            style: GoogleFonts.questrial(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes} min ${remainingSeconds} sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF4CAF50),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Detail Quiz',
              style: GoogleFonts.questrial(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF4CAF50), size: 20),
              ),
              SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                ),
                child: Stack(
                  children: [

                    Positioned(
                      bottom: 60,
                      left: 16,
                      right: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.quiz.title,
                            style: GoogleFonts.questrial(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'By ${widget.quiz.author}',
                            style: GoogleFonts.questrial(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      right: 16,
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          SizedBox(width: 4),
                          Text(
                            widget.quiz.rating.toString(),
                            style: GoogleFonts.questrial(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  Container(
                    height: 4,
                    margin: EdgeInsets.symmetric(horizontal: 150, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            'Brief explanation about this quiz',
                            style: GoogleFonts.questrial(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 16),

                          _buildQuizInfoRow(
                            Icons.quiz,
                            '${widget.quiz.questionCount} Question',
                            '${widget.quiz.points ~/ widget.quiz.questionCount} green point for a correct answer',
                          ),
                          SizedBox(height: 12),
                          _buildQuizInfoRow(
                            Icons.access_time,
                            _formatDuration(widget.quiz.timeLimit),
                            'Total duration of the video',
                          ),
                          SizedBox(height: 12),
                          _buildQuizInfoRow(
                            'assets/icons/green_points.svg',
                            'Win ${widget.quiz.points} Green Points',
                            'Answer all questions correctly',
                          ),

                          SizedBox(height: 24),

                          Text(
                            'Please read the text below carefully so you can understand it',
                            style: GoogleFonts.questrial(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          SizedBox(height: 12),

                          _buildInstructionItem('${widget.quiz.points ~/ widget.quiz.questionCount} point awarded for a correct answer and no marks for a incorrect answer'),
                          _buildInstructionItem('Tap on options to select the correct answer'),
                          _buildInstructionItem('Tap on the bookmark icon to save interesting questions'),
                          _buildInstructionItem('Click submit if you are sure you want to complete all the quizzes'),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: _isPerfectlyCompleted
                          ? _buildCompletedButton()
                          : ElevatedButton(
                              onPressed: _isLoading ? null : _startQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Start Quiz',
                                      style: GoogleFonts.questrial(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoRow(dynamic icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon is String
              ? SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                )
              : Icon(
                  icon as IconData,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.questrial(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.questrial(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: Color(0xFF2C3E50),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.questrial(
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  final QuizAttempt attempt;

  const QuizTakingScreen({
    Key? key,
    required this.quiz,
    required this.attempt,
  }) : super(key: key);

  @override
  _QuizTakingScreenState createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isSubmitting = false;
  DateTime _questionStartTime = DateTime.now();
  late QuizAttempt _currentAttempt;

  @override
  void initState() {
    super.initState();

    _currentAttempt = widget.attempt;

    _currentQuestionIndex = widget.attempt.questionResults.length;

    _questionStartTime = DateTime.now();
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
      final isCorrect = _selectedAnswer == currentQuestion.correctAnswerId;
      final questionTimeSpent = DateTime.now().difference(_questionStartTime).inSeconds;

      await QuizService.submitAnswerToAttempt(
        _currentAttempt,
        currentQuestion.id,
        _selectedAnswer!,
        isCorrect,
        questionTimeSpent,
      );

      final updatedAttempt = await QuizService.getUserLatestAttempt(_currentAttempt.userId, _currentAttempt.quizId);
      if (updatedAttempt != null) {
        _currentAttempt = updatedAttempt;
      }

      if (_currentQuestionIndex + 1 >= widget.quiz.questions.length) {

        final latestAttempt = await QuizService.getUserLatestAttempt(_currentAttempt.userId, _currentAttempt.quizId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              quiz: widget.quiz,
              attempt: latestAttempt ?? _currentAttempt,
            ),
          ),
        );
      } else {
        setState(() {
          _currentQuestionIndex++;
          _selectedAnswer = null;
          _questionStartTime = DateTime.now();
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

            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),

            SizedBox(height: 20),

            Text(
              currentQuestion.question,
              style: GoogleFonts.questrial(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 20),

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
  final QuizAttempt attempt;

  const QuizResultScreen({
    Key? key,
    required this.quiz,
    required this.attempt,
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

        final score = widget.attempt.finalScore;
        int pointsToAward = 0;

        if (score >= 90) {
          pointsToAward = widget.quiz.points;
        } else if (score >= 70) {
          pointsToAward = (widget.quiz.points * 0.8).round();
        } else if (score >= 50) {
          pointsToAward = (widget.quiz.points * 0.5).round();
        }

        if (pointsToAward > 0) {

          await userService.addUserPoints(user.uid, pointsToAward);
          await userService.addUserAction(user.uid);

          await userService.updateUserStreakFromDailyActivity(user.uid);

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
    final score = widget.attempt.finalScore;
    final isPassed = widget.attempt.isPassed;

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

    final score = widget.attempt.finalScore;
    int pointsEarned = 0;

    if (score >= 90) {
      pointsEarned = widget.quiz.points;
    } else if (score >= 70) {
      pointsEarned = (widget.quiz.points * 0.8).round();
    } else if (score >= 50) {
      pointsEarned = (widget.quiz.points * 0.5).round();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildResultRow('Correct Answers', '${widget.attempt.correctAnswers}/${widget.attempt.totalQuestions}'),
          Divider(),
          _buildResultRow('Time Spent', '${widget.attempt.timeSpent} seconds'),
          Divider(),
          _buildResultRow('Attempt Number', '#${widget.attempt.attemptNumber}'),
          if (pointsEarned > 0) ...[
            Divider(),
            _buildPointsRow('Points Earned', pointsEarned),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsRow(String label, int points) {
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
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/green_points.svg',
                width: 16,
                height: 16,
              ),
              SizedBox(width: 4),
              Text(
                '$points',
                style: GoogleFonts.questrial(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
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