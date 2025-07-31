import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz.dart';
import '../services/user_service.dart';

class QuizService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();
  static final UserService _userService = UserService();

  static Future<List<Quiz>> getQuizzes() async {
    try {
      print('📚 Fetching quizzes from Firebase...');
      final snapshot = await _firestore.collection('quizzes').get();
      print('📊 Found ${snapshot.docs.length} quiz documents');
      
      final quizzes = <Quiz>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('🏫 Processing quiz: ${doc.id}');
          
          // Create a quiz with the document ID as the quiz ID
          final quiz = Quiz(
            id: doc.id,
            title: data['title'] ?? doc.id,
            description: data['description'] ?? '',
            author: data['author'] ?? 'e-icon World Contest',
            category: data['category'] ?? 'Climate Science',
            questionCount: data['questionCount'] ?? 0,
            timeLimit: data['timeLimit'] ?? 300,
            points: data['points'] ?? 30,
            rating: (data['rating'] ?? 4.5).toDouble(),
            imageUrl: data['imageUrl'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            questions: _getQuestionsForQuiz(doc.id), // Get questions based on quiz ID
            createdAt: data['createdAt'] is Timestamp 
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            isActive: data['isActive'] ?? true,
          );
          
          quizzes.add(quiz);
          print('✅ Added quiz: ${quiz.title}');
        } catch (e) {
          print('❌ Error processing quiz ${doc.id}: $e');
        }
      }
      
      print('🎉 Successfully processed ${quizzes.length} quizzes');
      return quizzes;
    } catch (e) {
      print('❌ Error fetching quizzes: $e');
      return _getSampleQuizzes();
    }
  }

  static Future<Quiz?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        final data = doc.data()!;
        
        return Quiz(
          id: doc.id,
          title: data['title'] ?? doc.id,
          description: data['description'] ?? '',
          author: data['author'] ?? 'e-icon World Contest',
          category: data['category'] ?? 'Climate Science',
          questionCount: data['questionCount'] ?? 0,
          timeLimit: data['timeLimit'] ?? 300,
          points: data['points'] ?? 30,
          rating: (data['rating'] ?? 4.5).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          questions: _getQuestionsForQuiz(doc.id),
          createdAt: data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          isActive: data['isActive'] ?? true,
        );
      }
      return null;
    } catch (e) {
      print('Error fetching quiz: $e');
      return null;
    }
  }

  static List<QuizQuestion> _getQuestionsForQuiz(String quizId) {
    // Return sample questions based on quiz ID
    // In a real implementation, you would fetch these from Firebase
    switch (quizId) {
      case 'carbon-footprint':
        return _getCarbonFootprintQuestions();
      case 'climate-causes':
        return _getClimateCausesQuestions();
      case 'climate-change-basi...':
        return _getClimateChangeBasicQuestions();
      case 'renewable-energy':
        return _getRenewableEnergyQuestions();
      case 'sdg-climate-action':
        return _getSDGClimateActionQuestions();
      default:
        return _getSampleQuestions();
    }
  }

  static Future<QuizProgress?> getQuizProgress(String userId, String quizId) async {
    try {
      final doc = await _firestore
          .collection('quiz_progress')
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .get();
      
      if (doc.docs.isNotEmpty) {
        return QuizProgress.fromJson(doc.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error fetching quiz progress: $e');
      return null;
    }
  }

  static Future<QuizProgress?> getQuizProgressById(String progressId) async {
    try {
      final doc = await _firestore.collection('quiz_progress').doc(progressId).get();
      if (doc.exists) {
        return QuizProgress.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching quiz progress by ID: $e');
      return null;
    }
  }

  static Future<List<QuizProgress>> getUserQuizProgress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_progress')
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .get();
      
      final progressList = <QuizProgress>[];
      for (final doc in snapshot.docs) {
        try {
          final progress = QuizProgress.fromJson(doc.data());
          progressList.add(progress);
        } catch (e) {
          print('Error parsing quiz progress: $e');
        }
      }
      
      return progressList;
    } catch (e) {
      print('Error fetching user quiz progress: $e');
      return [];
    }
  }

  static Future<void> saveQuizProgress(QuizProgress progress) async {
    try {
      await _firestore
          .collection('quiz_progress')
          .doc(progress.id)
          .set(progress.toJson());
    } catch (e) {
      print('Error saving quiz progress: $e');
    }
  }

  static Future<QuizProgress> createQuizProgress(String userId, String quizId, int totalQuestions) async {
    final progress = QuizProgress(
      id: _uuid.v4(),
      quizId: quizId,
      userId: userId,
      currentQuestion: 0,
      correctAnswers: 0,
      totalQuestions: totalQuestions,
      timeSpent: 0,
      isCompleted: false,
      startedAt: DateTime.now(),
      score: 0,
      userAnswers: {},
    );

    await saveQuizProgress(progress);
    return progress;
  }

  static Future<void> updateQuizProgress(QuizProgress progress) async {
    await saveQuizProgress(progress);
  }

  static Future<void> submitAnswer(QuizProgress progress, String questionId, String answerId, bool isCorrect) async {
    final updatedProgress = QuizProgress(
      id: progress.id,
      quizId: progress.quizId,
      userId: progress.userId,
      currentQuestion: progress.currentQuestion + 1,
      correctAnswers: progress.correctAnswers + (isCorrect ? 1 : 0),
      totalQuestions: progress.totalQuestions,
      timeSpent: progress.timeSpent,
      isCompleted: progress.currentQuestion + 1 >= progress.totalQuestions,
      startedAt: progress.startedAt,
      completedAt: progress.currentQuestion + 1 >= progress.totalQuestions ? DateTime.now() : null,
      score: progress.score + (isCorrect ? 10 : 0),
      userAnswers: {...progress.userAnswers, questionId: answerId},
    );

    await updateQuizProgress(updatedProgress);
    
    if (updatedProgress.isCompleted) {
      await _awardQuizPoints(updatedProgress);
    }
  }

  static Future<void> _awardQuizPoints(QuizProgress progress) async {
    try {
      final quiz = await getQuizById(progress.quizId);
      if (quiz != null) {
        final percentage = progress.correctAnswers / progress.totalQuestions;
        int pointsToAward;
        
        if (percentage >= 0.9) {
          pointsToAward = quiz.points;
        } else if (percentage >= 0.7) {
          pointsToAward = (quiz.points * 0.8).round();
        } else if (percentage >= 0.5) {
          pointsToAward = (quiz.points * 0.6).round();
        } else {
          pointsToAward = (quiz.points * 0.3).round();
        }
        
        final user = await _userService.getUserById(progress.userId);
        if (user != null) {
          final newPoints = user.points + pointsToAward;
          await _userService.updateUserPoints(progress.userId, newPoints);
          
          print('Awarded $pointsToAward points to user ${progress.userId} for completing quiz ${progress.quizId}');
        }
      }
    } catch (e) {
      print('Error awarding quiz points: $e');
    }
  }

  static List<Quiz> _getSampleQuizzes() {
    return [
      Quiz(
        id: 'climate-change-basics',
        title: 'What is Climate Change',
        description: 'Learn about the fundamentals of climate change and its impact on our planet.',
        author: 'e-icon World Contest',
        category: 'Climate Science',
        questionCount: 10,
        timeLimit: 165,
        points: 50,
        rating: 4.8,
        imageUrl: 'assets/images/quiz/climate_basics.png',
        videoUrl: 'https://www.youtube.com/watch?v=example',
        questions: _getClimateChangeQuestions(),
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      Quiz(
        id: 'climate-causes',
        title: 'Climate Change: Causes',
        description: 'Explore the various causes of climate change and human impact on the environment.',
        author: 'e-icon World Contest',
        category: 'Climate Science',
        questionCount: 12,
        timeLimit: 192,
        points: 60,
        rating: 4.0,
        imageUrl: 'assets/images/quiz/climate_causes.png',
        videoUrl: 'https://www.youtube.com/watch?v=example2',
        questions: _getClimateCausesQuestions(),
        createdAt: DateTime.now().subtract(Duration(days: 25)),
      ),
      Quiz(
        id: 'sdg-climate-action',
        title: 'SDG 13: Climate Action',
        description: 'Understanding the United Nations Sustainable Development Goal 13 and climate action initiatives.',
        author: 'e-icon World Contest',
        category: 'Sustainability',
        questionCount: 10,
        timeLimit: 120,
        points: 50,
        rating: 4.5,
        imageUrl: 'assets/images/quiz/sdg13.png',
        videoUrl: 'https://www.youtube.com/watch?v=example3',
        questions: _getSDGQuestions(),
        createdAt: DateTime.now().subtract(Duration(days: 20)),
      ),
      Quiz(
        id: 'renewable-energy',
        title: 'Renewable Energy Sources',
        description: 'Test your knowledge about solar, wind, hydroelectric, and other renewable energy technologies.',
        author: 'e-icon World Contest',
        category: 'Clean Energy',
        questionCount: 8,
        timeLimit: 120,
        points: 40,
        rating: 4.2,
        imageUrl: 'assets/images/quiz/renewable_energy.png',
        videoUrl: 'https://www.youtube.com/watch?v=example4',
        questions: _getRenewableEnergyQuestions(),
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
      Quiz(
        id: 'carbon-footprint',
        title: 'Understanding Carbon Footprint',
        description: 'Learn about carbon footprints and how to reduce your environmental impact.',
        author: 'e-icon World Contest',
        category: 'Sustainability',
        questionCount: 6,
        timeLimit: 90,
        points: 30,
        rating: 4.6,
        imageUrl: 'assets/images/quiz/carbon_footprint.png',
        videoUrl: 'https://www.youtube.com/watch?v=example5',
        questions: _getCarbonFootprintQuestions(),
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
    ];
  }

  static List<QuizQuestion> _getClimateChangeQuestions() {
    return [
      QuizQuestion(
        id: 'cc_1',
        question: 'What is climate change?',
        answers: [
          QuizAnswer(id: 'cc_1_a', text: 'A natural increase in weather events like rain and snow every year', isCorrect: false),
          QuizAnswer(id: 'cc_1_b', text: 'The seasonal change from summer to winter and vice versa', isCorrect: false),
          QuizAnswer(id: 'cc_1_c', text: 'A sudden change in local weather due to storms or floods', isCorrect: false),
          QuizAnswer(id: 'cc_1_d', text: 'A long-term shift in global or regional climate patterns', isCorrect: true),
          QuizAnswer(id: 'cc_1_e', text: 'A temporary increase in temperature during heatwaves', isCorrect: false),
        ],
        correctAnswerId: 'cc_1_d',
        explanation: 'Climate change refers to long-term shifts in global or regional climate patterns, including temperature, precipitation, and wind patterns.',
        points: 10,
      ),
      QuizQuestion(
        id: 'cc_2',
        question: 'Which of the following is a greenhouse gas?',
        answers: [
          QuizAnswer(id: 'cc_2_a', text: 'Oxygen (O₂)', isCorrect: false),
          QuizAnswer(id: 'cc_2_b', text: 'Nitrogen (N₂)', isCorrect: false),
          QuizAnswer(id: 'cc_2_c', text: 'Carbon Dioxide (CO₂)', isCorrect: true),
          QuizAnswer(id: 'cc_2_d', text: 'Hydrogen (H₂)', isCorrect: false),
        ],
        correctAnswerId: 'cc_2_c',
        explanation: 'Carbon dioxide is a major greenhouse gas that traps heat in the Earth\'s atmosphere.',
        points: 10,
      ),
      QuizQuestion(
        id: 'cc_3',
        question: 'What is the main cause of current climate change?',
        answers: [
          QuizAnswer(id: 'cc_3_a', text: 'Volcanic eruptions', isCorrect: false),
          QuizAnswer(id: 'cc_3_b', text: 'Human activities', isCorrect: true),
          QuizAnswer(id: 'cc_3_c', text: 'Solar flares', isCorrect: false),
          QuizAnswer(id: 'cc_3_d', text: 'Natural climate cycles', isCorrect: false),
        ],
        correctAnswerId: 'cc_3_b',
        explanation: 'Human activities, particularly the burning of fossil fuels, are the primary cause of current climate change.',
        points: 10,
      ),
    ];
  }

  static List<QuizQuestion> _getClimateCausesQuestions() {
    return [
      QuizQuestion(
        id: 'causes_1',
        question: 'Which human activity contributes most to climate change?',
        answers: [
          QuizAnswer(id: 'causes_1_a', text: 'Burning fossil fuels', isCorrect: true),
          QuizAnswer(id: 'causes_1_b', text: 'Deforestation', isCorrect: false),
          QuizAnswer(id: 'causes_1_c', text: 'Agriculture', isCorrect: false),
          QuizAnswer(id: 'causes_1_d', text: 'Industrial processes', isCorrect: false),
        ],
        correctAnswerId: 'causes_1_a',
        explanation: 'Burning fossil fuels for energy production is the largest contributor to greenhouse gas emissions.',
        points: 10,
      ),
      QuizQuestion(
        id: 'causes_2',
        question: 'What is the greenhouse effect?',
        answers: [
          QuizAnswer(id: 'causes_2_a', text: 'A natural process that warms the Earth', isCorrect: true),
          QuizAnswer(id: 'causes_2_b', text: 'A man-made warming process', isCorrect: false),
          QuizAnswer(id: 'causes_2_c', text: 'A cooling effect from clouds', isCorrect: false),
          QuizAnswer(id: 'causes_2_d', text: 'A type of air pollution', isCorrect: false),
        ],
        correctAnswerId: 'causes_2_a',
        explanation: 'The greenhouse effect is a natural process where certain gases in the atmosphere trap heat from the sun.',
        points: 10,
      ),
    ];
  }

  static List<QuizQuestion> _getSDGQuestions() {
    return [
      QuizQuestion(
        id: 'sdg_1',
        question: 'What does SDG 13 stand for?',
        answers: [
          QuizAnswer(id: 'sdg_1_a', text: 'Sustainable Development Goal 13', isCorrect: true),
          QuizAnswer(id: 'sdg_1_b', text: 'Sustainable Development Group 13', isCorrect: false),
          QuizAnswer(id: 'sdg_1_c', text: 'Sustainable Development Guide 13', isCorrect: false),
          QuizAnswer(id: 'sdg_1_d', text: 'Sustainable Development Global 13', isCorrect: false),
        ],
        correctAnswerId: 'sdg_1_a',
        explanation: 'SDG 13 stands for Sustainable Development Goal 13, which focuses on Climate Action.',
        points: 10,
      ),
      QuizQuestion(
        id: 'sdg_2',
        question: 'What is the main focus of SDG 13?',
        answers: [
          QuizAnswer(id: 'sdg_2_a', text: 'Economic growth', isCorrect: false),
          QuizAnswer(id: 'sdg_2_b', text: 'Climate action', isCorrect: true),
          QuizAnswer(id: 'sdg_2_c', text: 'Education for all', isCorrect: false),
          QuizAnswer(id: 'sdg_2_d', text: 'Clean water', isCorrect: false),
        ],
        correctAnswerId: 'sdg_2_b',
        explanation: 'SDG 13 focuses on taking urgent action to combat climate change and its impacts.',
        points: 10,
      ),
    ];
  }

  static List<QuizQuestion> _getRenewableEnergyQuestions() {
    return [
      QuizQuestion(
        id: 're_1',
        question: 'Which renewable energy source is the fastest-growing globally?',
        answers: [
          QuizAnswer(id: 're_1_a', text: 'Solar power', isCorrect: true),
          QuizAnswer(id: 're_1_b', text: 'Wind power', isCorrect: false),
          QuizAnswer(id: 're_1_c', text: 'Hydroelectric power', isCorrect: false),
          QuizAnswer(id: 're_1_d', text: 'Geothermal power', isCorrect: false),
        ],
        correctAnswerId: 're_1_a',
        explanation: 'Solar power is the fastest-growing renewable energy source globally, with costs decreasing rapidly.',
        points: 10,
      ),
      QuizQuestion(
        id: 're_2',
        question: 'What is the main advantage of renewable energy over fossil fuels?',
        answers: [
          QuizAnswer(id: 're_2_a', text: 'Lower cost', isCorrect: false),
          QuizAnswer(id: 're_2_b', text: 'No greenhouse gas emissions', isCorrect: true),
          QuizAnswer(id: 're_2_c', text: 'Always available', isCorrect: false),
          QuizAnswer(id: 're_2_d', text: 'Easier to transport', isCorrect: false),
        ],
        correctAnswerId: 're_2_b',
        explanation: 'Renewable energy sources produce little to no greenhouse gas emissions during operation.',
        points: 10,
      ),
      QuizQuestion(
        id: 're_3',
        question: 'Which country leads in wind energy production?',
        answers: [
          QuizAnswer(id: 're_3_a', text: 'United States', isCorrect: false),
          QuizAnswer(id: 're_3_b', text: 'China', isCorrect: true),
          QuizAnswer(id: 're_3_c', text: 'Germany', isCorrect: false),
          QuizAnswer(id: 're_3_d', text: 'Denmark', isCorrect: false),
        ],
        correctAnswerId: 're_3_b',
        explanation: 'China leads the world in wind energy production and installed capacity.',
        points: 10,
      ),
    ];
  }

  static List<QuizQuestion> _getCarbonFootprintQuestions() {
    return [
      QuizQuestion(
        id: 'cf_1',
        question: 'What is a carbon footprint?',
        answers: [
          QuizAnswer(id: 'cf_1_a', text: 'The size of your shoe', isCorrect: false),
          QuizAnswer(id: 'cf_1_b', text: 'Total greenhouse gas emissions caused by your activities', isCorrect: true),
          QuizAnswer(id: 'cf_1_c', text: 'The amount of carbon in your body', isCorrect: false),
          QuizAnswer(id: 'cf_1_d', text: 'Your carbon credit score', isCorrect: false),
        ],
        correctAnswerId: 'cf_1_b',
        explanation: 'A carbon footprint is the total greenhouse gas emissions caused by an individual, organization, or activity.',
        points: 10,
      ),
      QuizQuestion(
        id: 'cf_2',
        question: 'Which activity has the highest carbon footprint?',
        answers: [
          QuizAnswer(id: 'cf_2_a', text: 'Walking', isCorrect: false),
          QuizAnswer(id: 'cf_2_b', text: 'Taking public transport', isCorrect: false),
          QuizAnswer(id: 'cf_2_c', text: 'Flying long distances', isCorrect: true),
          QuizAnswer(id: 'cf_2_d', text: 'Eating vegetables', isCorrect: false),
        ],
        correctAnswerId: 'cf_2_c',
        explanation: 'Flying long distances has one of the highest carbon footprints per passenger kilometer.',
        points: 10,
      ),
      QuizQuestion(
        id: 'cf_3',
        question: 'How can you reduce your carbon footprint?',
        answers: [
          QuizAnswer(id: 'cf_3_a', text: 'Use energy-efficient appliances', isCorrect: true),
          QuizAnswer(id: 'cf_3_b', text: 'Drive more often', isCorrect: false),
          QuizAnswer(id: 'cf_3_c', text: 'Use more plastic', isCorrect: false),
          QuizAnswer(id: 'cf_3_d', text: 'Leave lights on', isCorrect: false),
        ],
        correctAnswerId: 'cf_3_a',
        explanation: 'Using energy-efficient appliances is one of the most effective ways to reduce your carbon footprint.',
        points: 10,
      ),
    ];
  }

  static Future<void> addQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toJson());
    } catch (e) {
      print('Error adding quiz: $e');
    }
  }

  static Future<void> createSampleQuizzes() async {
    try {
      print('📚 Creating sample quizzes in Firebase...');
      
      final sampleQuizzes = _getSampleQuizzes();
      
      for (final quiz in sampleQuizzes) {
        await addQuiz(quiz);
        print('✅ Added quiz: ${quiz.title}');
      }
      
      print('🎉 Successfully created ${sampleQuizzes.length} sample quizzes in Firebase');
    } catch (e) {
      print('❌ Error creating sample quizzes: $e');
      rethrow;
    }
  }

  static Future<void> ensureSampleQuizzesExist() async {
    try {
      final snapshot = await _firestore.collection('quizzes').limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        print('📝 No quizzes found in Firebase, creating sample quizzes...');
        await createSampleQuizzes();
      } else {
        print('✅ Quizzes already exist in Firebase');
      }
    } catch (e) {
      print('❌ Error checking quizzes: $e');
      await createSampleQuizzes();
    }
  }

  static Future<void> updateQuizRating(String quizId, double newRating) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'rating': newRating,
      });
    } catch (e) {
      print('Error updating quiz rating: $e');
    }
  }

  static List<QuizQuestion> _getClimateChangeBasicQuestions() {
    return [
      QuizQuestion(
        id: 'ccb_1',
        question: 'What is the greenhouse effect?',
        answers: [
          QuizAnswer(id: 'ccb_1_a', text: 'A natural process that warms the Earth', isCorrect: true),
          QuizAnswer(id: 'ccb_1_b', text: 'A man-made process', isCorrect: false),
          QuizAnswer(id: 'ccb_1_c', text: 'A cooling effect', isCorrect: false),
          QuizAnswer(id: 'ccb_1_d', text: 'A type of pollution', isCorrect: false),
        ],
        correctAnswerId: 'ccb_1_a',
        explanation: 'The greenhouse effect is a natural process that warms the Earth\'s surface.',
        points: 10,
      ),
    ];
  }

  static List<QuizQuestion> _getSDGClimateActionQuestions() {
    return [
      QuizQuestion(
        id: 'sdg_1',
        question: 'What is SDG 13?',
        answers: [
          QuizAnswer(id: 'sdg_1_a', text: 'Climate Action', isCorrect: true),
          QuizAnswer(id: 'sdg_1_b', text: 'Clean Water', isCorrect: false),
          QuizAnswer(id: 'sdg_1_c', text: 'Quality Education', isCorrect: false),
          QuizAnswer(id: 'sdg_1_d', text: 'No Poverty', isCorrect: false),
        ],
        correctAnswerId: 'sdg_1_a',
        explanation: 'SDG 13 is Climate Action, which aims to take urgent action to combat climate change.',
        points: 10,
      ),
    ];
  }

  static List<QuizQuestion> _getSampleQuestions() {
    return [
      QuizQuestion(
        id: 'sample_1',
        question: 'What is climate change?',
        answers: [
          QuizAnswer(id: 'sample_1_a', text: 'A long-term change in global weather patterns', isCorrect: true),
          QuizAnswer(id: 'sample_1_b', text: 'A short-term weather event', isCorrect: false),
          QuizAnswer(id: 'sample_1_c', text: 'A seasonal change', isCorrect: false),
          QuizAnswer(id: 'sample_1_d', text: 'A daily temperature change', isCorrect: false),
        ],
        correctAnswerId: 'sample_1_a',
        explanation: 'Climate change refers to long-term changes in global weather patterns and average temperatures.',
        points: 10,
      ),
    ];
  }
} 