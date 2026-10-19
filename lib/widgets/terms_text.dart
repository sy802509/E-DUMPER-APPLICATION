import 'package:flutter/material.dart';

import '../services/app_text.dart';
import '../theme/colors.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr('welcome.terms'),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.terms,
        fontSize: 13,
        letterSpacing: 2,
        height: 1.5,
      ),
    );
  }
}
