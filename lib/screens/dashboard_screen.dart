import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/local_account_service.dart';
import '../services/app_text.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'address_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'choose_brand_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile? profile;

  const DashboardScreen({super.key, this.profile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedTab = 0;
  int _homeRefreshCount = 0;
  final _accountService = LocalAccountService();
  late UserProfile profile;

  @override
  void initState() {
    super.initState();
    profile = widget.profile ?? UserProfile.guest;
    if (widget.profile == null) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        key: ValueKey(_homeRefreshCount),
        profile: profile,
        onSell: _openSellFlow,
        onSignIn: _openSignIn,
        onCreateAccount: _openCreateAccount,
      ),
      OrdersScreen(
        onBack: _showHome,
        isGuest: _isGuest,
        onSignIn: _openSignIn,
        onCreateAccount: _openCreateAccount,
      ),
      ProfileScreen(
        profile: profile,
        onBack: _showHome,
        onSignIn: _openSignIn,
        onCreateAccount: _openCreateAccount,
        onOrders: () => setState(() => selectedTab = 1),
        onAddress: _openAddress,
        onProfileUpdate: _updateProfile,
        onLogout: _logout,
      ),
    ];

    return PopScope(
      canPop: selectedTab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && selectedTab != 0) _showHome();
      },
      child: AppPanel(
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.statsBackground,
          indicatorColor: AppColors.accent.withValues(alpha: 0.18),
          selectedIndex: selectedTab == 0 ? 0 : selectedTab + 1,
          onDestinationSelected: (index) {
            if (index == 1) {
              _openSellFlow();
              return;
            }

            setState(() => selectedTab = index == 0 ? 0 : index - 1);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: context.tr('nav.home'),
            ),
            NavigationDestination(
              icon: Icon(Icons.sell_outlined),
              label: context.tr('nav.sell'),
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined),
              label: context.tr('nav.orders'),
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: context.tr('nav.profile'),
            ),
          ],
        ),
        child: screens[selectedTab],
      ),
    );
  }

  bool get _isGuest => profile.email.isEmpty;

  Future<void> _loadProfile() async {
    final loadedProfile = await _accountService.loadCurrentProfile();
    if (mounted) setState(() => profile = loadedProfile);
  }

  Future<void> _openSellFlow() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChooseBrandScreen()));
    if (!mounted) return;
    final currentProfile = await _accountService.loadCurrentProfile();
    if (!mounted) return;
    setState(() {
      profile = currentProfile;
      _homeRefreshCount++;
    });
  }

  void _openAddress() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddressScreen()));
  }

  void _openSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen(createAccount: false)),
    );
  }

  void _openCreateAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen(createAccount: true)),
    );
  }

  void _showHome() {
    setState(() => selectedTab = 0);
  }

  Future<String?> _updateProfile(
    UserProfile updatedProfile, {
    String? currentPassword,
    String? newPassword,
  }) async {
    final error = await _accountService.updateCurrentProfile(
      updatedProfile,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (error == null && mounted) setState(() => profile = updatedProfile);
    return error;
  }

  Future<void> _logout() async {
    await _accountService.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen(createAccount: false)),
      (_) => false,
    );
  }
}
