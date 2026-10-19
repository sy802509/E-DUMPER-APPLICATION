import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/app_text.dart';
import '../services/local_account_service.dart';
import '../models/user_profile.dart';
import '../widgets/logo.dart';
import '../widgets/app_panel.dart';
import '../widgets/action_button.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  State<GettingStartedScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  int pageIndex = 0;
  final _accountService = LocalAccountService();

  @override
  Widget build(BuildContext context) {
    final page = pageIndex == 0
        ? _OnboardingPage(
            icon: '📱',
            title: context.tr('onboarding.broken.title'),
            description: context.tr('onboarding.broken.description'),
          )
        : _OnboardingPage(
            icon: '🔍',
            title: context.tr('onboarding.check.title'),
            description: context.tr('onboarding.check.description'),
          );

    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 42),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 680, maxWidth: 760),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _openDashboard,
                  child: Text(
                    context.tr('onboarding.skip'),
                    style: TextStyle(color: AppColors.tagline),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              page,
              const SizedBox(height: 30),
              PrimaryActionButton(
                label: context.tr('onboarding.guest'),
                onPressed: _openDashboard,
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => _openAuth(createAccount: false),
                child: Text(context.tr('onboarding.have_account')),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: pageIndex == 0
                    ? () => setState(() => pageIndex = 1)
                    : () => _openAuth(createAccount: true),
                child: Text(
                  pageIndex == 0
                      ? context.tr('onboarding.next')
                      : context.tr('auth.create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDashboard() async {
    await _accountService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(profile: UserProfile.guest),
      ),
      (_) => false,
    );
  }

  void _openAuth({required bool createAccount}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoginScreen(createAccount: createAccount),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(size: 96, iconSize: 44),
        const SizedBox(height: 30),
        Text(icon, style: const TextStyle(fontSize: 52)),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.heading,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.statSubtitle,
            fontSize: 17,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
