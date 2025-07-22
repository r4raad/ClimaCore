import 'package:flutter/material.dart';
import 'home_screen.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _selectedIndex == 0 ?  Image.asset('assets/icons/home_active.png', width: 32, height: 33) : Image.asset('assets/icons/home_inactive.png', width: 32, height: 33),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1 ?  Image.asset('assets/icons/climaconnect_active.png', width: 35, height: 35) : Image.asset('assets/icons/climaconnect_inactive.png', width: 32, height: 33),
            label: 'ClimaConnect',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset('assets/icons/leaderboard_active.png', width: 30, height: 30)
                  )
                : Image.asset('assets/icons/leaderboard_inactive.png', width: 32, height: 33),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 3 ?  Image.asset('assets/icons/ecomission_active.png', width: 32, height: 33) : Image.asset('assets/icons/ecomission_inactive.png', width: 32, height: 33),
            label: 'Eco Mission',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 4 ?  Image.asset('assets/icons/climasights_active.png', width: 35, height: 35) : Image.asset('assets/icons/climasights_inactive.png', width: 35, height: 35),
            label: 'ClimaSights',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green, // You can adjust the selected item color
        unselectedItemColor: Colors.grey, // You can adjust the unselected item color
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}