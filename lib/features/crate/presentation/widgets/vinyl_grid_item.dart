import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/models/vinyl.dart';
import '../../../../core/theme/app_colors.dart';

class VinylGridItem extends StatelessWidget {
  final Vinyl vinyl;

  const VinylGridItem({super.key, required this.vinyl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.glassWhite.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassWhite.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: vinyl.coverUrl.startsWith('assets') 
                      ? Image.asset(
                          vinyl.coverUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Image.network(
                          vinyl.coverUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.album_outlined, color: AppColors.textSecondary),
                          ),
                        ),
                ),
              ),
              // Album Info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vinyl.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vinyl.artist,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
