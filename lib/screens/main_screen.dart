import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import 'climaconnect_screen.dart';
import 'leaderboard_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  AppUser? _appUser;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    print('Loading user:  [32m [1m [4m [7m${firebaseUser?.uid} [0m');
    if (firebaseUser != null) {
      try {
        final user = await UserService().getUserById(firebaseUser.uid);
        print('User loaded: $user');
        setState(() {
          _appUser = user;
          _loadingUser = false;
        });
      } catch (e, stack) {
        print('Error loading user: $e');
        print(stack);
        setState(() {
          _loadingUser = false;
        });
      }
    } else {
      setState(() { _loadingUser = false; });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingNavItem(2, 'assets/icons/leaderboard_active.svg', 'assets/icons/leaderboard_inactive.svg'),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        if (_appUser == null) return Center(child: Text('User not found'));
        return ClimaConnectScreen(user: _appUser!);
      case 2:
        return LeaderboardScreen();
      case 3:
        return Center(child: Text('Eco Mission Screen'));
      case 4:
        return Center(child: Text('ClimaSights Screen'));
      default:
        return HomeScreen();
    }
  }

  Widget buildBottomNavigationBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0, // Adjust as needed
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4), // Reduced vertical padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/icons/home_active.svg', 'assets/icons/home_inactive.svg'),
            _buildNavItem(1, 'assets/icons/climaconnect_active.svg', 'assets/icons/climaconnect_inactive.svg'),
            SizedBox(width: 60), // Placeholder for the floating center item
            _buildNavItem(3, 'assets/icons/ecomission_active.svg', 'assets/icons/ecomission_inactive.svg'),
            _buildNavItem(4, 'assets/icons/climasights_active.svg', 'assets/icons/climasights_inactive.svg'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String activeIcon, String inactiveIcon) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = 30;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SvgPicture.asset(
        isSelected ? activeIcon : inactiveIcon,
        width: iconSize,
        height: iconSize,
        colorFilter: isSelected 
          ? null // Don't apply color filter for active icons since they have their own color
          : ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildFloatingNavItem(int index, String activeIcon, String inactiveIcon) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = 36;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.green : Colors.grey, // Color based on selection
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: SvgPicture.asset(
          isSelected ? activeIcon : inactiveIcon, // Use both active and inactive icons
          width: iconSize,
          height: iconSize,
          colorFilter: isSelected 
            ? null // Don't apply color filter for active icons since they have their own color
            : ColorFilter.mode(Colors.white, BlendMode.srcIn), // White color for inactive icons
        ),
      ),
    );
  }
}