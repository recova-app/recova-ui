import 'package:flutter/material.dart';
import 'package:recova/pages/home_page.dart';
import 'package:recova/pages/create_post_page.dart';
import 'package:recova/pages/stats_page.dart';
import 'package:recova/pages/community_hub_page.dart';
import 'package:recova/pages/education_page.dart';
import 'package:recova/pages/profile_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StatsPage(),
    const CommunityHubPage(),
    const EducationPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Gunakan IndexedStack untuk menjaga state setiap halaman
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton:
          _currentIndex == -1
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostPage(),
                    ),
                  );
                },
                backgroundColor: colorScheme.secondary,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/menu/home_icon.png')),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/menu/stat_icon.png')),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/menu/support_icon.png')),
            label: 'Bantuan',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/menu/book_icon.png')),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/menu/setting_icon.png')),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
