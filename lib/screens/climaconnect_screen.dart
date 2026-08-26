import 'package:flutter/material.dart';
import '../models/school.dart';
import '../models/user.dart';
import '../services/school_service.dart';
import '../services/user_service.dart';
import '../utils/firestore_school_setup.dart';
import 'community_screen.dart';
import '../widgets/school_card.dart';

class ClimaConnectScreen extends StatefulWidget {
  final AppUser user;

  const ClimaConnectScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ClimaConnectScreen> createState() => _ClimaConnectScreenState();
}

class _ClimaConnectScreenState extends State<ClimaConnectScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final SchoolService _schoolService = SchoolService();
  final UserService _userService = UserService();

  List<School> _schools = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _joinedSchoolId;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  static const double _expandedHeight = 180.0;
  static const double _collapsedHeight = kToolbarHeight;

  late AnimationController _centerTitleController;
  late AnimationController _leftTitleController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _joinedSchoolId = widget.user.joinedSchoolId;

    print('🚀 ClimaConnect: initState called, _joinedSchoolId: "$_joinedSchoolId"');

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔄 ClimaConnect: didChangeDependencies called');

    _refreshUserData();
  }

  @override
  void didUpdateWidget(ClimaConnectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('🔄 ClimaConnect: didUpdateWidget called, old joinedSchoolId: "${oldWidget.user.joinedSchoolId}", new: "${widget.user.joinedSchoolId}"');

    if (oldWidget.user.joinedSchoolId != widget.user.joinedSchoolId) {
      _updateJoinedSchoolStatus();
    }
  }

  void _updateJoinedSchoolStatus() {
    final currentJoinedSchoolId = widget.user.joinedSchoolId;
    if (_joinedSchoolId != currentJoinedSchoolId) {
      setState(() {
        _joinedSchoolId = currentJoinedSchoolId;
      });

      print('🔄 ClimaConnect: Joined school status updated, _joinedSchoolId is now: "$_joinedSchoolId"');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _centerTitleController.dispose();
    _leftTitleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _refreshUserData();
    }
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
        print('📝 ClimaConnect: No schools found, setting up schools from Firestore...');
        await _schoolService.setupSchoolsFromFirestore();
        final newSchools = await _schoolService.getSchools();
        print('📋 ClimaConnect: After setup, received ${newSchools.length} schools');

        if (mounted) {
          setState(() {
            _schools = newSchools;
            _isLoading = false;
            _hasError = false;
          });
          print('✅ ClimaConnect: Schools loaded successfully from Firestore');
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

      print('🔄 ClimaConnect: Joining school $schoolId');
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

      print('✅ ClimaConnect: Successfully joined school, _joinedSchoolId is now: "$_joinedSchoolId"');
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

        print('🔄 ClimaConnect: Setting _joinedSchoolId to null');
        setState(() {
          _joinedSchoolId = null;
        });

        print('✅ ClimaConnect: _joinedSchoolId is now: "$_joinedSchoolId"');

        if (mounted) {
          print('🔄 ClimaConnect: Forcing rebuild');
          setState(() {});
        }

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
    print('🏗️ ClimaConnect: build called, _joinedSchoolId: "$_joinedSchoolId"');

    if (_joinedSchoolId != null && _joinedSchoolId!.isNotEmpty) {
      print('🏗️ ClimaConnect: Showing community content');
      return _buildCommunityContent();
    }

    print('🏗️ ClimaConnect: Showing schools list');
    return _buildSchoolsList();
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
    return _buildSchoolsListContent();
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
                const Text(
                  'Contact your administrator to set up schools in the database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
            const Text(
              'Contact your administrator to set up schools in the database.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolsList() {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: _expandedHeight,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFFF0F4F8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
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
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                          image: DecorationImage(
                            image: AssetImage('images/climaconnect_header.png'),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),

                    AnimatedOpacity(
                      opacity: t,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                          ),
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ),

                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: 0,
                      right: 0,
                      top: -20 * (1.0 - t),
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
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 4.0,
                                    color: Colors.black87,
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
                          child: Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: _showSettings,
                                  icon: Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildCommunityContent() {
    return CommunityScreen(
      user: widget.user,
      schoolId: _joinedSchoolId!,
      onSchoolLeft: () {

        setState(() {
          _joinedSchoolId = null;
          _isLoading = false;
          _hasError = false;
        });

        _refreshUserData();

        print('🔄 ClimaConnect: School left, showing schools list');
      },
    );
  }

  Widget _buildSchoolsListContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Schools',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _schools.length,
            itemBuilder: (context, index) {
              final school = _schools[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SchoolCard(
                  school: school,
                  joined: false,
                  onJoin: () => _joinSchool(school.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _refreshUserData() async {
    try {

      final updatedUser = await _userService.getUserById(widget.user.id);
      if (updatedUser != null && mounted) {

        setState(() {
          _joinedSchoolId = updatedUser.joinedSchoolId;
        });

        print('🔄 ClimaConnect: User data refreshed, _joinedSchoolId is now: "$_joinedSchoolId"');
      }
    } catch (e) {
      print('❌ ClimaConnect: Error refreshing user data: $e');

    }
  }
}