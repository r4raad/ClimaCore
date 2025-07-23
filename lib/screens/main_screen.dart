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
      bottomNavigationBar: buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingNavItem(2, 'assets/icons/leaderboard_active.svg', 'assets/icons/leaderboard_inactive.svg'),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
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
        colorFilter: ColorFilter.mode(isSelected ? Colors.green : Colors.grey, BlendMode.srcIn),
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
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn), // White color for the icon
        ),
      ),
    );
  }
}