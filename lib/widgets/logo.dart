import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double iconSize;

  const AppLogo({super.key, this.size = 150, this.iconSize = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(38),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentShadow,
            blurRadius: 34,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Icon(Icons.recycling, size: iconSize, color: Colors.white),
    );
  }
}
