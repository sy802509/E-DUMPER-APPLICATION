import 'package:flutter/material.dart';

import '../theme/colors.dart';

class GetStartedButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GetStartedButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
          shadowColor: AppColors.accentShadow,
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
