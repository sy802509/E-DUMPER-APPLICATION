import 'package:flutter/material.dart';

import '../services/app_text.dart';
import '../theme/colors.dart';
import 'logo.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 380;

        return Column(
          children: [
            AppLogo(size: isCompact ? 108 : 128, iconSize: isCompact ? 50 : 60),
            const SizedBox(height: 22),
            Text(
              'E-DUMPER',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: isCompact ? 32 : 40,
                fontWeight: FontWeight.w900,
                letterSpacing: isCompact ? -1 : -2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('welcome.tagline'),
              style: TextStyle(
                color: AppColors.tagline,
                fontSize: isCompact ? 12 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: isCompact ? 2 : 3,
              ),
            ),
          ],
        );
      },
    );
  }
}
