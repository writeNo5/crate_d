import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vinyls = MockData.getVinyls().take(10).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: const Text('COMMUNITY'),
              backgroundColor: AppColors.background.withValues(alpha: 0.5),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(top: kToolbarHeight + 16, bottom: 100),
            itemCount: vinyls.length,
            itemBuilder: (context, index) {
              final v = vinyls[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    // TODO: 상세 페이지 전환 (Detail View Navigation)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${v.title} 상세 정보로 이동합니다.')),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.glassWhite.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: v.coverUrl.startsWith('assets')
                                        ? Image.asset(v.coverUrl, fit: BoxFit.cover)
                                        : Image.network(v.coverUrl, fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        v.artist,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const CircleAvatar(radius: 8, backgroundColor: AppColors.aqua),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Collector_${index + 101} Just Added',
                                            style: TextStyle(color: AppColors.aqua.withValues(alpha: 0.7), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: Colors.white10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InteractionButton(icon: Icons.favorite_border, activeIcon: Icons.favorite, label: '좋아요'),
                                InteractionButton(icon: Icons.bookmark_border_rounded, activeIcon: Icons.bookmark_rounded, label: '갖고싶어요'),
                                const InteractionButton(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: '코멘트', isComment: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}

class InteractionButton extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isComment;

  const InteractionButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isComment = false,
  });

  @override
  State<InteractionButton> createState() => _InteractionButtonState();
}

class _InteractionButtonState extends State<InteractionButton> with SingleTickerProviderStateMixin {
  bool _isActive = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isComment) {
      // Just a small pop for comment, no active state toggle
      _controller.forward(from: 0.0);
      return;
    }
    
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _controller.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                _isActive ? widget.activeIcon : widget.icon,
                size: 18,
                color: _isActive ? AppColors.aqua : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                color: _isActive ? AppColors.aqua : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: _isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
