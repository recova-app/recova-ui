import 'package:flutter/material.dart';
import 'package:recova/pages/community_page.dart';
import 'package:recova/pages/create_post_page.dart';
import 'package:recova/pages/education_page.dart';
import 'package:recova/pages/home_page.dart';
import 'package:recova/pages/profile_page.dart';
import 'package:recova/pages/stats_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const Color _selectedColor = Color(0xFF0E6B52);
  static const Color _unselectedColor = Color(0xFF111111);

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StatsPage(),
    CommunityPage(),
    EducationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton:
          _currentIndex == 2
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreatePostPage(),
                    ),
                  );
                },
                backgroundColor: _selectedColor,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            indicatorColor: _selectedColor,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              _navDestination('assets/images/menu/home_icon.png', 0, 'Home'),
              _navDestination('assets/images/menu/stat_icon.png', 1, 'Stats'),
              _navDestination(
                'assets/images/menu/comm_icon.png',
                2,
                'Community',
              ),
              _navDestination(
                'assets/images/menu/book_icon.png',
                3,
                'Education',
              ),
              _navDestination(
                'assets/images/menu/setting_icon.png',
                4,
                'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationDestination _navDestination(
    String assetPath,
    int index,
    String label,
  ) {
    final selected = _currentIndex == index;

    return NavigationDestination(
      icon: ImageIcon(
        AssetImage(assetPath),
        color: selected ? Colors.white : _unselectedColor,
      ),
      selectedIcon: ImageIcon(AssetImage(assetPath), color: Colors.white),
      label: label,
    );
  }
}
