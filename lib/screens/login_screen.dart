import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/app_text.dart';
import '../services/local_account_service.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/text_input_field.dart';
import '../widgets/action_button.dart';
import '../widgets/screen_header.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool createAccount;
  final bool returnToCaller;

  const LoginScreen({
    super.key,
    required this.createAccount,
    this.returnToCaller = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accountService = LocalAccountService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: context.tr(
                    widget.createAccount ? 'auth.create' : 'auth.login',
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  context.tr(
                    widget.createAccount ? 'auth.create' : 'auth.welcome',
                  ),
                  style: const TextStyle(
                    color: AppColors.heading,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.createAccount
                      ? context.tr('auth.details')
                      : context.tr('auth.manage'),
                  style: const TextStyle(
                    color: AppColors.statSubtitle,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 28),
                if (widget.createAccount) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextInputField(
                          label: context.tr('auth.first_name'),
                          hint: 'Raj',
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                          onChanged: (_) => _clearError(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextInputField(
                          label: context.tr('auth.last_name'),
                          hint: 'Sharma',
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          onChanged: (_) => _clearError(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
                TextInputField(
                  label: context.tr('auth.email'),
                  hint: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 18),
                if (widget.createAccount) ...[
                  TextInputField(
                    label: context.tr('auth.phone'),
                    hint: '+91 7688542899',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    onChanged: (_) => _clearError(),
                  ),
                  const SizedBox(height: 18),
                ],
                TextInputField(
                  label: context.tr('auth.password'),
                  hint: 'Min. 8 characters',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onChanged: (_) => _clearError(),
                ),
                if (!widget.createAccount)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      child: Text(
                        context.tr('auth.forgot'),
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ),
                  ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _successMessage!,
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ],
                const SizedBox(height: 28),
                PrimaryActionButton(
                  label: _isLoading
                      ? context.tr('auth.wait')
                      : widget.createAccount
                      ? context.tr('auth.create')
                      : context.tr('auth.login'),
                  onPressed: _isLoading ? null : _submit,
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _switchMode,
                    child: Text(
                      widget.createAccount
                          ? context.tr('auth.already')
                          : context.tr('auth.need_account'),
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (widget.createAccount &&
        (_firstNameController.text.trim().isEmpty ||
            _lastNameController.text.trim().isEmpty ||
            _phoneController.text.trim().isEmpty)) {
      setState(
        () => _errorMessage = 'Complete all fields to create your account.',
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!LocalAccountService.isValidEmail(email)) {
      setState(() => _errorMessage = 'Enter a valid email address.');
      return;
    }
    if (!LocalAccountService.isValidPassword(password)) {
      setState(
        () => _errorMessage = 'Password must be between 8 and 128 characters.',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      late final UserProfile profile;
      if (widget.createAccount) {
        profile = await _accountService.createAccount(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          password: password,
        );
      } else {
        profile = await _accountService.logIn(email: email, password: password);
      }

      if (mounted) {
        if (widget.returnToCaller) {
          Navigator.of(context).pop(profile);
        } else {
          _openDashboard(profile);
        }
      }
    } on AccountException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Something went wrong. Try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearError() {
    if (_errorMessage != null || _successMessage != null) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!LocalAccountService.isValidEmail(email)) {
      setState(() => _errorMessage = 'Enter a valid email address first.');
      return;
    }

    setState(
      () =>
          _successMessage = 'Password reset is unavailable for local accounts.',
    );
  }

  void _switchMode() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          createAccount: !widget.createAccount,
          returnToCaller: widget.returnToCaller,
        ),
      ),
    );
  }

  void _openDashboard(UserProfile profile) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => DashboardScreen(profile: profile)),
      (_) => false,
    );
  }
}
