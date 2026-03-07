import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_state_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/vinyl_grid_item.dart';

class CrateScreen extends StatefulWidget {
  const CrateScreen({super.key});

  @override
  State<CrateScreen> createState() => _CrateScreenState();
}

class _CrateScreenState extends State<CrateScreen> {
  String _sortBy = 'Artist'; // Default sort
  final List<String> _sortOptions = ['Artist', 'Year', 'Genre'];

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    
    if (collection.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.aqua));
    }
    
    var vinyls = List.from(collection.vinyls);

    // Apply Sorting
    if (_sortBy == 'Artist') {
      vinyls.sort((a, b) => a.artist.compareTo(b.artist));
    } else if (_sortBy == 'Year') {
      vinyls.sort((a, b) => b.year.compareTo(a.year)); // Newest first
    } else if (_sortBy == 'Genre') {
      vinyls.sort((a, b) => a.genre.compareTo(b.genre));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text('DIGITAL CRATE'),
              backgroundColor: AppColors.background.withValues(alpha: 0.5),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 배경 글로우 (이브의 감성)
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.aqua.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 10),
              // Sort Bar (Glassmorphism Chips)
              _buildSortBar(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth / 180).floor();
                    if (crossAxisCount < 2) crossAxisCount = 2;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 100),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: vinyls.length,
                        itemBuilder: (context, index) {
                          return VinylGridItem(vinyl: vinyls[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _sortOptions.map((option) {
          final isSelected = _sortBy == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _sortBy = option);
                }
              },
              backgroundColor: AppColors.surface.withValues(alpha: 0.3),
              selectedColor: AppColors.aqua.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.aqua : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.aqua : Colors.white12,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
