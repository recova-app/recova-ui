import 'package:flutter/material.dart';
import 'package:recova/features/community/presentation/pages/community_hub_page.dart';
import 'package:recova/features/community/presentation/pages/create_post_page.dart';
import 'package:recova/features/education/presentation/pages/education_page.dart';
import 'package:recova/features/home/presentation/pages/home_page.dart';
import 'package:recova/features/profile/presentation/pages/profile_page.dart';
import 'package:recova/features/routine/presentation/pages/stats_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final Set<int> _loadedPages = {0};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Gunakan IndexedStack untuk menjaga state setiap halaman secara lazy
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomePage(),
          _loadedPages.contains(1)
              ? const StatsPage()
              : const SizedBox.shrink(),
          _loadedPages.contains(2)
              ? const CommunityHubPage()
              : const SizedBox.shrink(),
          _loadedPages.contains(3)
              ? const EducationPage()
              : const SizedBox.shrink(),
          _loadedPages.contains(4)
              ? const ProfilePage()
              : const SizedBox.shrink(),
        ],
      ),
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
            _loadedPages.add(index);
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
