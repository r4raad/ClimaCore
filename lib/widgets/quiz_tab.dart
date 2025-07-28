import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../widgets/quiz_card.dart';
import '../widgets/quiz_progress_card.dart';
import '../models/user.dart';

class QuizTab extends StatefulWidget {
  final AppUser user;
  const QuizTab({Key? key, required this.user}) : super(key: key);
  @override
  _QuizTabState createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  List<Quiz> _quizzes = [];
  List<QuizProgress> _quizProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await QuizService.ensureSampleQuizzesExist();
      
      final quizzes = await QuizService.getQuizzes();
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load quizzes')),
        );
      }
    }
  }

  List<Quiz> get _newQuizzes {
    return _quizzes.where((quiz) {
      return !_quizProgress.any((progress) => 
        progress.quizId == quiz.id && progress.isCompleted);
    }).toList();
  }

  List<QuizProgress> get _continueQuizzes {
    return _quizProgress.where((progress) => 
      !progress.isCompleted && progress.currentQuestion > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _buildQuizContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${widget.user.name.isNotEmpty ? widget.user.name : 'User'}',
            style: GoogleFonts.questrial(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          
          SizedBox(height: 4),
          
          Text(
            'Let\'s test your knowledge',
            style: GoogleFonts.questrial(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading quizzes...',
            style: GoogleFonts.questrial(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return RefreshIndicator(
      onRefresh: _loadQuizzes,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_newQuizzes.isNotEmpty) ...[
              _buildSectionHeader('New Quiz'),
              SizedBox(height: 12),
              ..._newQuizzes.map((quiz) => QuizCard(
                quiz: quiz,
                onTap: () => _startQuiz(quiz),
              )),
              SizedBox(height: 24),
            ],
            
            if (_continueQuizzes.isNotEmpty) ...[
              _buildSectionHeader('Continue Quiz'),
              SizedBox(height: 12),
              ..._continueQuizzes.map((progress) {
                final quiz = _quizzes.firstWhere(
                  (q) => q.id == progress.quizId,
                  orElse: () => Quiz(
                    id: '',
                    title: 'Unknown Quiz',
                    description: '',
                    author: '',
                    category: '',
                    questionCount: 0,
                    timeLimit: 0,
                    points: 0,
                    rating: 0,
                    imageUrl: '',
                    videoUrl: '',
                    questions: [],
                    createdAt: DateTime.now(),
                  ),
                );
                return QuizProgressCard(
                  quiz: quiz,
                  progress: progress,
                  onContinue: () => _continueQuiz(quiz, progress),
                  onDelete: () => _deleteProgress(progress),
                );
              }),
              SizedBox(height: 24),
            ],
            
            if (_newQuizzes.isEmpty && _continueQuizzes.isEmpty) ...[
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No quizzes available',
                      style: GoogleFonts.questrial(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check back later for new climate education quizzes',
                      style: GoogleFonts.questrial(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.questrial(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  void _startQuiz(Quiz quiz) {
    Navigator.pushNamed(
      context,
      '/quiz-detail',
      arguments: quiz,
    );
  }

  void _continueQuiz(Quiz quiz, QuizProgress progress) {
    Navigator.pushNamed(
      context,
      '/quiz-detail',
      arguments: {'quiz': quiz, 'progress': progress},
    );
  }

  void _deleteProgress(QuizProgress progress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Progress'),
        content: Text('Are you sure you want to delete your progress for this quiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _quizProgress.removeWhere((p) => p.id == progress.id);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 