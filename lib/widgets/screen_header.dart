import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../screens/welcome_screen.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const ScreenHeader({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => _goBack(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.heading),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.heading,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  void _goBack(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }
}
