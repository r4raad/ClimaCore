import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/case.dart';
import '../services/case_service.dart';
import '../widgets/case_card.dart';
import 'package:url_launcher/url_launcher.dart';

class CasesScreen extends StatefulWidget {
  const CasesScreen({Key? key}) : super(key: key);

  @override
  _CasesScreenState createState() => _CasesScreenState();
}

class _CasesScreenState extends State<CasesScreen> {
  List<Case> _cases = [];
  bool _isLoading = true;
  String _selectedTab = 'Cases';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cases = await CaseService.getCasesWithFallback();
      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshCases() async {
    await CaseService.fetchAndProcessNews();
    await _loadCases();
  }

  void _reviewCase(Case caseData) async {
    try {
      await CaseService.markCaseAsReviewed(caseData.id, 'current_user_id');

      if (caseData.sourceUrl.isNotEmpty) {
        final uri = Uri.parse(caseData.sourceUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Case reviewed: ${caseData.personName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to review case'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, List<Case>> _groupCasesByDate() {
    final grouped = <String, List<Case>>{};

    for (final caseData in _cases) {
      final dateKey = caseData.formattedDate;
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(caseData);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _buildCasesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshCases,
        backgroundColor: Color(0xFF4CAF50),
        child: Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text(
              'Loading climate cases...',
              style: GoogleFonts.questrial(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    if (_cases.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No cases available',
                style: GoogleFonts.questrial(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pull to refresh and load new cases',
                style: GoogleFonts.questrial(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final groupedCases = _groupCasesByDate();
    final sortedDates = groupedCases.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Yesterday') return -1;
        if (b == 'Yesterday') return 1;
        return a.compareTo(b);
      });

    return RefreshIndicator(
      onRefresh: _refreshCases,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final casesForDate = groupedCases[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  date,
                  style: GoogleFonts.questrial(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),

              ...casesForDate.map((caseData) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: CaseCard(
                  caseData: caseData,
                  onReview: () => _reviewCase(caseData),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}