import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/crate/presentation/screens/community_screen.dart';
import 'features/crate/presentation/screens/crate_screen.dart';
import 'features/crate/presentation/screens/scan_screen.dart';

import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/providers/app_state_provider.dart';
import 'core/models/vinyl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }
  
  Isar? isar;
  try {
    if (kIsWeb) {
      isar = await Isar.open(
        [VinylSchema],
        directory: '', // Web implementation ignores this, but parameter is required
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        [VinylSchema],
        directory: dir.path,
      );
    }
  } catch (e) {
    debugPrint('Failed to open Isar: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider(isar!)),
      ],
      child: const CrateDApp(),
    ),
  );
}

class CrateDApp extends StatelessWidget {
  const CrateDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crate D',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBody: true,
      body: Row(
        children: [
          if (isWide) _buildNavigationRail(),
          Expanded(
            child: _selectedIndex == 0
                ? const HomeScreen()
                : _selectedIndex == 1
                    ? const CrateScreen()
                    : const CommunityScreen(),
          ),
        ],
      ),
      floatingActionButton: _buildScanFAB(context),
      floatingActionButtonLocation: isWide ? FloatingActionButtonLocation.endFloat : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isWide ? null : _buildGlassBottomBar(),
    );
  }

  Widget _buildScanFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.aqua.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanScreen()),
          );
        },
        backgroundColor: AppColors.aqua,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.black),
      ),
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      labelType: NavigationRailLabelType.none,
      backgroundColor: AppColors.background,
      indicatorColor: AppColors.aqua.withValues(alpha: 0.2),
      selectedIconTheme: const IconThemeData(color: AppColors.aqua),
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home_outlined), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.grid_view_rounded), label: Text('Crate')),
        NavigationRailDestination(icon: Icon(Icons.people_outline), label: Text('Social')),
      ],
    );
  }

  // 이브의 감성이 담긴 글래스모피즘 하단 바
  Widget _buildGlassBottomBar() {
    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassWhite.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.glassWhite.withValues(alpha: 0.2),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // 투명하게 설정하여 Blur 효과 노출
              elevation: 0,
              selectedItemColor: AppColors.aqua,
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Crate'),
                BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Social'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('CRATE D'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Glow (Eve's Signature)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.aqua.withValues(alpha: 0.1),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Merged Profile Info
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, color: AppColors.aqua),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RD Collector',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Vinyl Enthusiast Since 2024',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats Summary (Simple & Clean)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassWhite.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Collection', '${collection.totalCollection}'),
                      _buildValueStatItem(collection),
                      _buildStatItem('Wishlist', '${collection.wishlistCount}'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Featured Section (Most Liked / Value)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FEATURED VINYL',
                      style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      'Most Liked • High Value',
                      style: TextStyle(color: AppColors.aqua, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFeaturedCard(),
                
                const SizedBox(height: 40),
                
                // Current Rotation (Friend Feedback based)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ON CURRENT ROTATION',
                      style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      '최근 지인들이 남긴 피드백 순',
                      style: TextStyle(fontSize: 10, color: AppColors.aqua),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRotationItem(),
              ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildValueStatItem(CollectionProvider collection) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(collection.formattedValue, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.aqua.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+${collection.valueChangePercentage}%',
                style: const TextStyle(color: AppColors.aqua, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const Text('Value', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      ],
    );
  }

  Widget _buildFeaturedCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.glassWhite.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassWhite.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: Image.asset('assets/images/electronic.png', fit: BoxFit.cover),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Synth Wave City', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Neon Arch', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotationItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassWhite.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassWhite.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/images/jazz.png', width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Midnight Echoes', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('The Jazz Quintet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.aqua),
        ],
      ),
    );
  }
}
