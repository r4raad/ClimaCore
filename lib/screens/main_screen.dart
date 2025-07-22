import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Placeholder screens for now
  static List<Widget> _screenOptions = <Widget>[
    HomeScreen(),
    Center(child: Text('ClimaConnect Screen')),
    Center(child: Text('Leaderboard Screen')),
    Center(child: Text('Eco Mission Screen')),
    Center(child: Text('ClimaSights Screen')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'assets/icons/home_active.svg', 'assets/icons/home_inactive.svg'),
                _buildNavItem(1, 'assets/icons/climaconnect_active.svg', 'assets/icons/climaconnect_inactive.svg'),
                _buildNavItem(2, 'assets/icons/leaderboard_active.svg', 'assets/icons/leaderboard_inactive.svg', isCenter: true),
                _buildNavItem(3, 'assets/icons/ecomission_active.svg', 'assets/icons/ecomission_inactive.svg'),
                _buildNavItem(4, 'assets/icons/climasights_active.svg', 'assets/icons/climasights_inactive.svg'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String activeIcon, String inactiveIcon, {bool isCenter = false}) {
    final bool isSelected = _selectedIndex == index;
    final double iconSize = isCenter ? 36 : 30;
    if (isSelected && isCenter) {
      // Special style for center (Leaderboard) when active
      return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
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
            activeIcon,
            width: iconSize,
            height: iconSize,
            color: Colors.white,
          ),
        ),
      );
    } else if (isSelected) {
      // Active, not center
      return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: SvgPicture.asset(
          activeIcon,
          width: iconSize,
          height: iconSize,
          color: Colors.green,
        ),
      );
    } else {
      // Inactive
      return GestureDetector(
        onTap: () => _onItemTapped(index),
        child: SvgPicture.asset(
          inactiveIcon,
          width: iconSize,
          height: iconSize,
          color: Colors.grey,
        ),
      );
    }
  }
}