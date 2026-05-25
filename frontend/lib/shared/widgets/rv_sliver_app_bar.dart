import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';

enum RvRole { renter, owner, admin, neutral }

class RvSliverAppBar extends StatelessWidget {
  const RvSliverAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.role = RvRole.renter,
    this.expandedHeight = 150,
    this.actions,
    this.pinned = true,
  });

  final String title;
  final String subtitle;
  final RvRole role;
  final double expandedHeight;
  final List<Widget>? actions;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      expandedHeight: expandedHeight,
      backgroundColor: _topColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: actions,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.logoGradient,
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'RideVN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: _gradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(191),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _topColor => switch (role) {
        RvRole.renter => const Color(0xFF003380),
        RvRole.owner => const Color(0xFF001A3D),
        RvRole.admin => const Color(0xFF0A1628),
        RvRole.neutral => AppColors.primary,
      };

  LinearGradient get _gradient => switch (role) {
        RvRole.renter => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF003380), Color(0xFF007BFF)],
          ),
        RvRole.owner => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001A3D), Color(0xFF003380)],
          ),
        RvRole.admin => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A1628), Color(0xFF142035)],
          ),
        RvRole.neutral => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF003380), Color(0xFF007BFF)],
          ),
      };
}
