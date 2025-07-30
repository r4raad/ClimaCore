import 'package:flutter/material.dart';
import '../models/school.dart';
import '../models/user.dart';
import '../services/school_service.dart';
import '../services/user_service.dart';
import 'community_screen.dart';
import '../widgets/school_card.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClimaConnectScreen extends StatefulWidget {
  final AppUser user;

  const ClimaConnectScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ClimaConnectScreen> createState() => _ClimaConnectScreenState();
}

class _ClimaConnectScreenState extends State<ClimaConnectScreen> with TickerProviderStateMixin {
  final SchoolService _schoolService = SchoolService();
  final UserService _userService = UserService();
  
  List<School> _schools = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _joinedSchoolId;

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
    _joinedSchoolId = widget.user.joinedSchoolId;
    
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
    
    _fetchSchools();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

  Future<void> _fetchSchools() async {
    print('🚀 ClimaConnect: _fetchSchools called');
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      print('🔄 ClimaConnect: Starting to fetch schools...');
      final schools = await _schoolService.getSchools();
      print('📋 ClimaConnect: Received ${schools.length} schools');
      
      for (int i = 0; i < schools.length; i++) {
        final school = schools[i];
        print('🏫 School $i: ID=${school.id}, Name="${school.name}", ImageUrl="${school.imageUrl}"');
        print('🏫 School $i: Name length=${school.name.length}, Is empty=${school.name.isEmpty}');
      }
      
      if (schools.isEmpty) {
        print('📝 ClimaConnect: No schools found, creating sample schools...');
        await _schoolService.createSampleSchools();
        final newSchools = await _schoolService.getSchools();
        print('📋 ClimaConnect: After creating samples, received ${newSchools.length} schools');
        
        if (mounted) {
          setState(() {
            _schools = newSchools;
            _isLoading = false;
            _hasError = false;
          });
          print('✅ ClimaConnect: Sample schools loaded successfully');
        }
      } else {
        if (mounted) {
          setState(() {
            _schools = schools;
            _isLoading = false;
            _hasError = false;
          });
          print('✅ ClimaConnect: Schools loaded successfully, state updated');
        }
      }
    } catch (e) {
      print('❌ ClimaConnect: Error fetching schools: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _joinSchool(String schoolId) async {
    try {
      await _userService.joinSchool(widget.user.id, schoolId);
      setState(() {
        _joinedSchoolId = schoolId;
      });
      
      final school = _schools.firstWhere((s) => s.id == schoolId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully joined ${school.name}!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityScreen(
            user: widget.user,
            schoolId: schoolId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join school: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _leaveSchool() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave School'),
        content: const Text('Are you sure you want to leave your current school?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.joinSchool(widget.user.id, '');
        setState(() {
          _joinedSchoolId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left the school'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave school: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user has joined a school, show the community screen directly
    if (_joinedSchoolId != null && _joinedSchoolId!.isNotEmpty) {
      return CommunityScreen(user: widget.user, schoolId: _joinedSchoolId!);
    }
    // Otherwise, show the school list
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
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
                
                print('📊 ClimaConnect: Scroll progress t = $t, maxExtent = $maxExtent, minExtent = $minExtent');
                
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedOpacity(
                      opacity: t,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset(
                        'assets/images/test_svg.svg',
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) {
                          print('⚠️ ClimaConnect: SVG placeholder used - SVG may not be loading');
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.green, Colors.lightGreen],
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ ClimaConnect: SVG error: $error');
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.green, Colors.lightGreen],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          );
                        },
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
                              'ClimaConnect',
                              style: TextStyle(
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
                               'ClimaConnect',
                               style: TextStyle(
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
                  ],
                );
              },
            ),
            actions: [
              // Removed refresh and create sample schools buttons
            ],
          ),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      print('⏳ ClimaConnect: Showing loading state');
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading schools...'),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      print('❌ ClimaConnect: Showing error state');
      return _buildErrorState();
    }

    if (_schools.isEmpty) {
      print('📭 ClimaConnect: Showing empty state');
      return _buildEmptyState();
    }

    print('✅ ClimaConnect: Showing schools list');
    return _buildSchoolsList();
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Schools',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This might be due to network issues or the schools collection not existing yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _fetchSchools,
                  child: const Text('Retry'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _schoolService.createSampleSchools();
                    _fetchSchools();
                  },
                  child: const Text('Create Sample Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Schools Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no schools in the system yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _schoolService.createSampleSchools();
                _fetchSchools();
              },
              child: const Text('Create Sample Schools (Testing)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Schools',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join a school to connect with your community',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _schools.length,
          itemBuilder: (context, index) {
            final school = _schools[index];
            final isJoined = _joinedSchoolId == school.id;
            
            print('🏫 Building school card $index: "${school.name}" (joined: $isJoined)');
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: SchoolCard(
                school: school,
                joined: isJoined,
                onJoin: () => _joinSchool(school.id),
              ),
            );
          },
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
} 