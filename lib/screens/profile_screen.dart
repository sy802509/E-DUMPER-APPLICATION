import 'package:flutter/material.dart';

import '../models/order.dart';
import '../models/user_profile.dart';
import '../models/bank_details.dart';
import '../services/bank_details_service.dart';
import '../services/app_text.dart';
import '../services/local_account_service.dart';
import '../services/order_service.dart';
import '../theme/colors.dart';
import '../widgets/screen_header.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;
  final Future<void> Function()? onLogout;
  final VoidCallback? onOrders;
  final VoidCallback? onAddress;
  final Future<String?> Function(
    UserProfile profile, {
    String? currentPassword,
    String? newPassword,
  })?
  onProfileUpdate;
  final OrderService orderService;
  final BankDetailsService bankDetailsService;

  const ProfileScreen({
    super.key,
    this.profile = UserProfile.fallback,
    this.onBack,
    this.onSignIn,
    this.onCreateAccount,
    this.onLogout,
    this.onOrders,
    this.onAddress,
    this.onProfileUpdate,
    this.orderService = const OrderService(),
    this.bankDetailsService = const BankDetailsService(),
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  late Future<List<DeviceOrder>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = widget.orderService.loadUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profile.email.isEmpty) {
      return _GuestProfile(
        onBack: widget.onBack,
        onSignIn: widget.onSignIn,
        onCreateAccount: widget.onCreateAccount,
      );
    }

    final displayName = widget.profile.fullName.isEmpty
        ? 'User'
        : widget.profile.fullName;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
      child: Column(
        children: [
          ScreenHeader(title: context.tr('nav.profile'), onBack: widget.onBack),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.accent,
            child: Text(
              widget.profile.initials,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayName,
            style: const TextStyle(
              color: AppColors.heading,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.profile.email.isEmpty
                ? context.tr('profile.no_email')
                : widget.profile.email,
            style: const TextStyle(color: AppColors.statSubtitle, fontSize: 15),
          ),
          if (widget.profile.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Phone: ${widget.profile.phone}',
              style: const TextStyle(
                color: AppColors.statSubtitle,
                fontSize: 15,
              ),
            ),
          ],
          const SizedBox(height: 10),
          FutureBuilder<List<DeviceOrder>>(
            future: _orders,
            builder: (context, snapshot) {
              final orders = snapshot.data ?? const <DeviceOrder>[];
              return Text(
                '${orders.length} ${context.tr('profile.devices_sold')}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          FutureBuilder<List<DeviceOrder>>(
            future: _orders,
            builder: (context, snapshot) {
              final orders = snapshot.data ?? const <DeviceOrder>[];
              return Row(
                children: [
                  Expanded(
                    child: _ProfileStat(
                      value: '${orders.length}',
                      label: context.tr('profile.devices'),
                    ),
                  ),
                  Expanded(
                    child: _ProfileStat(
                      value: _earnedLabel(orders),
                      label: context.tr('profile.earned'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          _ProfileAction(
            icon: Icons.edit_outlined,
            label: context.tr('profile.edit'),
            onTap: () => _showEditProfileSheet(context),
          ),
          _ProfileAction(
            icon: Icons.location_on_outlined,
            label: context.tr('profile.address'),
            onTap:
                widget.onAddress ??
                () => _showInfoSheet(
                  context,
                  'My Address',
                  'Add a pickup address so we know where to collect your device.',
                  Icons.location_on_outlined,
                ),
          ),
          _ProfileAction(
            icon: Icons.account_balance_outlined,
            label: context.tr('profile.bank'),
            onTap: () => _showBankDetailsSheet(context),
          ),
          _ProfileAction(
            icon: Icons.receipt_long_outlined,
            label: context.tr('profile.order_history'),
            onTap: widget.onOrders ?? () {},
          ),
          _ProfileAction(
            icon: Icons.shield_outlined,
            label: context.tr('profile.privacy'),
            onTap: () => _showInfoSheet(
              context,
              'Privacy & security',
              'Your account and payout details are shown locally in this static app.',
              Icons.shield_outlined,
            ),
          ),
          _ProfileAction(
            icon: Icons.chat_bubble_outline,
            label: context.tr('profile.support'),
            onTap: () => _showInfoSheet(
              context,
              'Contact support',
              'Our support team is ready to help with your next sale.',
              Icons.chat_bubble_outline,
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _isLoggingOut ? null : _logout,
            child: _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : Text(
                    context.tr('profile.logout'),
                    style: TextStyle(color: Colors.redAccent),
                  ),
          ),
        ],
      ),
    );
  }

  String _earnedLabel(List<DeviceOrder> orders) {
    final total = orders.fold<int>(
      0,
      (sum, order) =>
          sum + int.parse(order.amount.replaceAll(RegExp(r'[^0-9]'), '')),
    );
    return total < 1000 ? '₹$total' : '₹${(total / 1000).toStringAsFixed(1)}K';
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    await widget.onLogout?.call();
    if (mounted) setState(() => _isLoggingOut = false);
  }

  void _showInfoSheet(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.statsBackground,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accent, size: 28),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.statSubtitle,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: Navigator.of(context).pop,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(context.tr('common.done')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.statsBackground,
      showDragHandle: true,
      builder: (_) => _EditProfileSheet(
        profile: widget.profile,
        onSave: widget.onProfileUpdate,
      ),
    );
  }

  Future<void> _showBankDetailsSheet(BuildContext context) async {
    final details = await widget.bankDetailsService.load();
    if (!context.mounted) return;
    final accountName = TextEditingController(text: details.accountName);
    final accountNumber = TextEditingController(text: details.accountNumber);
    final ifsc = TextEditingController(text: details.ifsc);
    final upiId = TextEditingController(text: details.upiId);
    var isSaving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.statsBackground,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              8,
              24,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bank Details',
                    style: TextStyle(
                      color: AppColors.heading,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _EditField(
                    label: 'Account holder name',
                    controller: accountName,
                  ),
                  const SizedBox(height: 14),
                  _EditField(
                    label: 'Account number',
                    controller: accountNumber,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _EditField(label: 'IFSC code', controller: ifsc),
                  const SizedBox(height: 14),
                  _EditField(label: 'UPI ID (optional)', controller: upiId),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (accountName.text.trim().isEmpty ||
                                  accountNumber.text.trim().isEmpty ||
                                  ifsc.text.trim().isEmpty) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Complete the required bank fields.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              final error = await widget.bankDetailsService
                                  .save(
                                    BankDetails(
                                      accountName: accountName.text,
                                      accountNumber: accountNumber.text,
                                      ifsc: ifsc.text,
                                      upiId: upiId.text,
                                    ),
                                  );
                              if (!sheetContext.mounted) return;
                              setSheetState(() => isSaving = false);
                              if (error != null) {
                                ScaffoldMessenger.of(
                                  sheetContext,
                                ).showSnackBar(SnackBar(content: Text(error)));
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(isSaving ? 'Saving...' : 'Save bank details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      accountName.dispose();
      accountNumber.dispose();
      ifsc.dispose();
      upiId.dispose();
    });
  }
}

class _GuestProfile extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;

  const _GuestProfile({this.onBack, this.onSignIn, this.onCreateAccount});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
      child: Column(
        children: [
          ScreenHeader(title: context.tr('nav.profile'), onBack: onBack),
          const SizedBox(height: 46),
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.statsBackground,
            child: Icon(
              Icons.person_outline_rounded,
              color: AppColors.accent,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Guest profile',
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in or create an account to manage your profile, pickup address, payment details, and orders.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.statSubtitle,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Sign in'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCreateAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  final Future<String?> Function(
    UserProfile profile, {
    String? currentPassword,
    String? newPassword,
  })?
  onSave;

  const _EditProfileSheet({required this.profile, required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit profile',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _EditField(label: 'First name', controller: _firstNameController),
              const SizedBox(height: 14),
              _EditField(label: 'Last name', controller: _lastNameController),
              const SizedBox(height: 14),
              _EditField(
                label: 'Email (login account)',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              const SizedBox(height: 14),
              _EditField(
                label: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 22),
              const Text(
                'Change password (optional)',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Leave these fields blank to keep your current password.',
                style: TextStyle(color: AppColors.statSubtitle, fontSize: 13),
              ),
              const SizedBox(height: 14),
              _EditField(
                label: 'Current password',
                controller: _currentPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              _EditField(
                label: 'New password',
                controller: _newPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              _EditField(
                label: 'Confirm new password',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(_isSaving ? 'Saving...' : 'Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all profile fields.')),
      );
      return;
    }

    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final changingPassword =
        currentPassword.isNotEmpty ||
        newPassword.isNotEmpty ||
        confirmPassword.isNotEmpty;
    if (changingPassword) {
      if (currentPassword.isEmpty ||
          newPassword.isEmpty ||
          confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete all password fields.')),
        );
        return;
      }
      if (!LocalAccountService.isValidPassword(newPassword)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New password must be between 8 and 128 characters.'),
          ),
        );
        return;
      }
      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The new passwords do not match.')),
        );
        return;
      }
    }

    if (widget.onSave == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to edit your profile.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final error = await widget.onSave!(
      widget.profile.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      ),
      currentPassword: changingPassword ? currentPassword : null,
      newPassword: changingPassword ? newPassword : null,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool obscureText;

  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      style: const TextStyle(color: AppColors.heading),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.statSubtitle),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline, color: AppColors.statSubtitle)
            : null,
        filled: true,
        fillColor: AppColors.panelBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.statSubtitle,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ProfileAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ProfileAction> createState() => _ProfileActionState();
}

class _ProfileActionState extends State<_ProfileAction> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: Material(
          color: _isPressed
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.statsBackground,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _isPressed = value),
            child: ListTile(
              leading: Icon(widget.icon, color: AppColors.accent, size: 25),
              title: Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.statSubtitle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
