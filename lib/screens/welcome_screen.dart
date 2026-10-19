import 'package:flutter/material.dart';

import 'getting_started_screen.dart';
import '../theme/colors.dart';
import '../widgets/welcome_header.dart';
import '../widgets/get_started_button.dart';
import '../widgets/grid_background.dart';
import '../widgets/stats_card.dart';
import '../widgets/terms_text.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _WelcomePanel(
              width: _panelWidth(constraints.maxWidth),
              height: constraints.maxHeight,
            );
          },
        ),
      ),
    );
  }

  double _panelWidth(double availableWidth) {
    return availableWidth > 1080 ? 1080 : availableWidth;
  }
}

class _WelcomePanel extends StatelessWidget {
  final double width;
  final double height;

  const _WelcomePanel({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width < 600 ? 28 : 80),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.panelBackground,
            border: Border.all(color: AppColors.panelBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.accentShadow,
                blurRadius: 50,
                spreadRadius: -30,
              ),
            ],
          ),
          child: Stack(
            children: [
              const GridBackground(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: const _WelcomeContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeContent extends StatelessWidget {
  const _WelcomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const WelcomeHeader(),
        const SizedBox(height: 42),
        const StatsCard(),
        const SizedBox(height: 38),
        GetStartedButton(onPressed: () => _openOnboarding(context)),
        const SizedBox(height: 16),
        const TermsText(),
      ],
    );
  }

  void _openOnboarding(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GettingStartedScreen()));
  }
}
