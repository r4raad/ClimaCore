import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'climaconnect_screen.dart';
import 'leaderboard_screen.dart';
import 'climasights_screen.dart';
import 'climagame_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  AppUser? _appUser;
  bool _loadingUser = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    print('Loading user:  [32m [1m [4m [7m${firebaseUser?.uid} [0m');
    if (firebaseUser != null) {
      try {
        final user = await UserService().getUserById(firebaseUser.uid);
        print('User loaded: $user');
        if (mounted) {
          setState(() {
            _appUser = user;
            _loadingUser = false;
          });
        }
      } catch (e, stack) {
        print('Error loading user: $e');
        print(stack);
        if (mounted) setState(() {
          _loadingUser = false;
        });
      }
    } else {
      if (mounted) setState(() { _loadingUser = false; });
    }
  }

  void onItemTapped(int index) {
    if (_selectedIndex != index) {
      _animationController.reverse().then((_) {
        setState(() {
          _selectedIndex = index;
        });
        _animationController.forward();

        if (index == 1) {
          _loadUser();
        }
      });
    }
  }

  void _onItemTapped(int index) => onItemTapped(index);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_animationController.isAnimating && _animationController.value == 0.0) {
      _animationController.forward();
    }

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _getScreen(_selectedIndex),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingNavItem(2, 'assets/icons/leaderboard_active.svg', 'assets/icons/leaderboard_inactive.svg'),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        if (_appUser == null) return Center(child: Text('User not found'));
        return HomeScreen(user: _appUser!);
      case 1:
        if (_appUser == null) return Center(child: Text('User not found'));
        return ClimaConnectScreen(user: _appUser!);
      case 2:
        if (_appUser == null) return Center(child: Text('User not found'));
        return LeaderboardScreen(user: _appUser!);
      case 3:
        if (_appUser == null) return Center(child: Text('User not found'));
        return ClimaGameScreen(user: _appUser!);
      case 4:
        if (_appUser == null) return Center(child: Text('User not found'));
        return ClimaSightsScreen(user: _appUser!);
      default:
        if (_appUser == null) return Center(child: Text('User not found'));
        return HomeScreen(user: _appUser!);
    }
  }

  Widget buildBottomNavigationBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/icons/home_active.svg', 'assets/icons/home_inactive.svg'),
            _buildNavItem(1, 'assets/icons/climaconnect_active.svg', 'assets/icons/climaconnect_inactive.svg'),
            SizedBox(width: 60),
            _buildNavItem(3, 'assets/icons/climagame_active.svg', 'assets/icons/climagame_inactive.svg'),
            _buildNavItem(4, 'assets/icons/climasights_active.svg', 'assets/icons/climasights_inactive.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String activeIcon, String inactiveIcon) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = 30;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Transform.scale(
          scale: isSelected ? 1.1 : 1.0,
          child: SvgPicture.asset(
            isSelected ? activeIcon : inactiveIcon,
            width: iconSize,
            height: iconSize,
            colorFilter: isSelected
              ? null
              : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem(int index, String activeIcon, String inactiveIcon) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = 84;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Transform.scale(
          scale: isSelected ? 1.15 : 1.0,
          child: SvgPicture.asset(
            isSelected ? activeIcon : inactiveIcon,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}