import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/resilience_tab.dart';
import '../widgets/quiz_tab.dart';
import '../widgets/ai_tab.dart';
import '../widgets/clima_ai_button.dart';

import '../models/user.dart';

class ClimaSightsScreen extends StatefulWidget {
  final AppUser user;
  const ClimaSightsScreen({Key? key, required this.user}) : super(key: key);
  @override
  _ClimaSightsScreenState createState() => _ClimaSightsScreenState();
}

class _ClimaSightsScreenState extends State<ClimaSightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1;
  
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  static const double _expandedHeight = 250.0;
  static const double _collapsedHeight = kToolbarHeight;

  late AnimationController _centerTitleController;
  late AnimationController _leftTitleController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
    
    _centerTitleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _leftTitleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _centerTitleController.dispose();
    _leftTitleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final maxScroll = _expandedHeight - _collapsedHeight;
    final progress = (offset / maxScroll).clamp(0.0, 1.0);
    
    setState(() {
      _scrollOffset = offset;
    });
    
    _centerTitleController.value = 1.0 - progress;
    _leftTitleController.value = progress;
    _backgroundController.value = 1.0 - progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: _expandedHeight,
              floating: false,
              pinned: true,
              backgroundColor: Colors.green,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxExtent = constraints.maxHeight;
                  final double minExtent = kToolbarHeight;
                  final double t = ((maxExtent - minExtent) / (_expandedHeight - _collapsedHeight)).clamp(0.0, 1.0);
                  
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedOpacity(
                        opacity: t,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: 0,
                        right: 0,
                        top: -40 * (1.0 - t),
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: t,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            child: Center(
                              child: Text(
                                'ClimaSights',
                                style: GoogleFonts.questrial(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        left: 16,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: AnimatedOpacity(
                          opacity: 1.0 - t,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ClimaSights',
                                style: GoogleFonts.questrial(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 1.1,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        top: 20,
                        right: 20,
                        child: AnimatedOpacity(
                          opacity: t,
                          duration: const Duration(milliseconds: 200),
                          child: ClimaAIButton(user: widget.user),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                // Removed refresh button
              ],
            ),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF4CAF50),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildTabNavigation(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    QuizTab(user: widget.user),
                    ResilienceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.questrial(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.questrial(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: 'Quiz'),
          Tab(text: 'Resilience'),
        ],
      ),
    );
  }
} 