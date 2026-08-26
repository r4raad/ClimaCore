import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/quiz_migration_utility.dart';
import '../services/quiz_service.dart';
import '../models/quiz.dart';

class QuizMigrationTestScreen extends StatefulWidget {
  const QuizMigrationTestScreen({Key? key}) : super(key: key);

  @override
  _QuizMigrationTestScreenState createState() => _QuizMigrationTestScreenState();
}

class _QuizMigrationTestScreenState extends State<QuizMigrationTestScreen> {
  bool _isLoading = false;
  String _status = 'Ready to test migration';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Migration Test', style: GoogleFonts.questrial()),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Progress Migration',
              style: GoogleFonts.questrial(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.info,
                    color: _isLoading ? Colors.orange : Colors.blue,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: GoogleFonts.questrial(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            Text(
              'Migration Actions',
              style: GoogleFonts.questrial(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 16),

            _buildActionButton(
              '🔄 Migrate All Quiz Progress',
              'Migrate existing quiz_progress to new subcollection structure',
              () => _migrateAllProgress(),
            ),

            SizedBox(height: 12),

            _buildActionButton(
              '🔍 Compare User Progress',
              'Compare old vs new structure for a specific user',
              () => _compareUserProgress(),
            ),

            SizedBox(height: 12),

            _buildActionButton(
              '🧪 Test New Structure',
              'Create a test quiz attempt with the new structure',
              () => _testNewStructure(),
            ),

            SizedBox(height: 12),

            _buildActionButton(
              '📋 Show Recommended Indexes',
              'Display recommended Firestore indexes',
              () => _showRecommendedIndexes(),
            ),

            SizedBox(height: 30),

            Text(
              'Cleanup Actions (Use with caution)',
              style: GoogleFonts.questrial(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            SizedBox(height: 16),

            _buildActionButton(
              '🗑️ Delete Old Quiz Progress',
              'Delete the old quiz_progress collection (after migration)',
              () => _cleanupOldProgress(),
              isDestructive: true,
            ),

            Spacer(),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 New Structure Benefits:',
                    style: GoogleFonts.questrial(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Better performance with subcollections\n'
                    '• Track multiple attempts per quiz\n'
                    '• Detailed question-level analytics\n'
                    '• Easier user-specific queries\n'
                    '• Better scalability',
                    style: GoogleFonts.questrial(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, VoidCallback onPressed, {bool isDestructive = false}) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red[600] : Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.questrial(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.questrial(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _migrateAllProgress() async {
    setState(() {
      _isLoading = true;
      _status = 'Migrating quiz progress...';
    });

    try {
      await QuizMigrationUtility.migrateAllQuizProgress();
      setState(() {
        _status = 'Migration completed successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Migration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _compareUserProgress() async {
    setState(() {
      _isLoading = true;
      _status = 'Comparing user progress...';
    });

    try {

      const userId = 'FxqnM3LdyAVdMCWpsQuX9mjH1UX2';
      await QuizMigrationUtility.compareUserProgress(userId);
      setState(() {
        _status = 'Comparison completed! Check console for details.';
      });
    } catch (e) {
      setState(() {
        _status = 'Comparison failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testNewStructure() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing new structure...';
    });

    try {
      const userId = 'FxqnM3LdyAVdMCWpsQuX9mjH1UX2';
      const quizId = 'carbon-footprint';
      await QuizMigrationUtility.testNewStructure(userId, quizId);
      setState(() {
        _status = 'Test completed! Check console for results.';
      });
    } catch (e) {
      setState(() {
        _status = 'Test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showRecommendedIndexes() async {
    QuizMigrationUtility.createRecommendedIndexes();
    setState(() {
      _status = 'Recommended indexes displayed in console.';
    });
  }

  Future<void> _cleanupOldProgress() async {

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Confirm Deletion'),
        content: Text(
          'This will permanently delete the old quiz_progress collection. '
          'Make sure you have migrated all data first!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _status = 'Deleting old quiz progress...';
      });

      try {
        await QuizMigrationUtility.cleanupOldQuizProgress();
        setState(() {
          _status = 'Old quiz progress deleted successfully!';
        });
      } catch (e) {
        setState(() {
          _status = 'Deletion failed: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}