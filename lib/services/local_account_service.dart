import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AccountException implements Exception {
  final String message;

  const AccountException(this.message);

  @override
  String toString() => message;
}

class LocalAccountService {
  static const _accountsKey = 'edumper.accounts.v1';
  static const sessionEmailKey = 'edumper.sessionEmail.v1';

  Future<UserProfile> createAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    _validateEmail(normalizedEmail);
    _validatePassword(password);

    final first = firstName.trim();
    final last = lastName.trim();
    final phoneNumber = phone.trim();
    if (first.isEmpty || last.isEmpty || phoneNumber.isEmpty) {
      throw const AccountException('Complete all fields to create an account.');
    }

    final preferences = await SharedPreferences.getInstance();
    final accounts = _readAccounts(preferences);
    if (accounts.containsKey(normalizedEmail)) {
      throw const AccountException(
        'An account with this email already exists.',
      );
    }

    final profile = UserProfile(
      firstName: first,
      lastName: last,
      email: normalizedEmail,
      phone: phoneNumber,
    );
    final salt = _newSalt();
    accounts[normalizedEmail] = {
      'profile': profile.toMap(),
      'salt': salt,
      'passwordHash': _hashPassword(salt, password),
    };

    await preferences.setString(_accountsKey, jsonEncode(accounts));
    await preferences.setString(sessionEmailKey, normalizedEmail);
    return profile;
  }

  Future<UserProfile> logIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    _validateEmail(normalizedEmail);
    _validatePassword(password);

    final preferences = await SharedPreferences.getInstance();
    final account = _readAccounts(preferences)[normalizedEmail];
    if (account == null) {
      // This app has no authentication server. Bootstrap a local profile on
      // first sign-in, then verify the saved password on later sign-ins.
      final profile = UserProfile(
        firstName: 'User',
        lastName: '',
        email: normalizedEmail,
        phone: '',
      );
      final salt = _newSalt();
      final accounts = _readAccounts(preferences);
      accounts[normalizedEmail] = {
        'profile': profile.toMap(),
        'salt': salt,
        'passwordHash': _hashPassword(salt, password),
      };
      final saved = await preferences.setString(
        _accountsKey,
        jsonEncode(accounts),
      );
      if (!saved) {
        throw const AccountException(
          'Could not create a local account. Please try again.',
        );
      }
      await preferences.setString(sessionEmailKey, normalizedEmail);
      return profile;
    }

    if (account['passwordHash'] !=
        _hashPassword(account['salt'] as String, password)) {
      throw const AccountException('Email or password is incorrect.');
    }

    await preferences.setString(sessionEmailKey, normalizedEmail);
    return UserProfile.fromMap(
      Map<String, dynamic>.from(account['profile'] as Map),
    );
  }

  Future<UserProfile> loadCurrentProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(sessionEmailKey);
    if (email == null) return UserProfile.guest;

    final account = _readAccounts(preferences)[email];
    if (account == null) {
      await preferences.remove(sessionEmailKey);
      return UserProfile.guest;
    }

    return UserProfile.fromMap(
      Map<String, dynamic>.from(account['profile'] as Map),
    );
  }

  Future<String?> updateCurrentProfile(
    UserProfile profile, {
    String? currentPassword,
    String? newPassword,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(sessionEmailKey);
    if (email == null || normalizeEmail(profile.email) != email) {
      return 'Sign in again to update your profile.';
    }
    if (profile.firstName.trim().isEmpty ||
        profile.lastName.trim().isEmpty ||
        profile.phone.trim().isEmpty) {
      return 'Complete all profile fields.';
    }

    final accounts = _readAccounts(preferences);
    final account = accounts[email];
    if (account == null) return 'This account could not be found.';

    if (currentPassword != null || newPassword != null) {
      if (currentPassword == null || newPassword == null) {
        return 'Enter both your current and new password.';
      }
      if (!isValidPassword(newPassword)) {
        return 'New password must be between 8 and 128 characters.';
      }
      final salt = account['salt'] as String;
      if (account['passwordHash'] != _hashPassword(salt, currentPassword)) {
        return 'Current password is incorrect.';
      }

      final newSalt = _newSalt();
      account['salt'] = newSalt;
      account['passwordHash'] = _hashPassword(newSalt, newPassword);
    }

    account['profile'] = profile.copyWith(email: email).toMap();
    final saved = await preferences.setString(
      _accountsKey,
      jsonEncode(accounts),
    );
    return saved ? null : 'Could not save your changes. Please try again.';
  }

  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(sessionEmailKey);
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static bool isValidEmail(String email) {
    final value = normalizeEmail(email);
    if (value.length > 254 || value.contains('..')) return false;
    final parts = value.split('@');
    if (parts.length != 2) return false;

    final local = parts[0];
    final domain = parts[1];
    if (local.isEmpty ||
        local.length > 64 ||
        local.startsWith('.') ||
        local.endsWith('.')) {
      return false;
    }
    if (!RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(local)) {
      return false;
    }

    final labels = domain.split('.');
    if (labels.length < 2) return false;
    if (labels.any(
      (label) =>
          label.isEmpty ||
          label.length > 63 ||
          !RegExp(r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$').hasMatch(label),
    )) {
      return false;
    }
    return RegExp(r'^[a-z]{2,63}$').hasMatch(labels.last);
  }

  static bool isValidPassword(String password) =>
      password.length >= 8 && password.length <= 128;

  static void _validateEmail(String email) {
    if (!isValidEmail(email)) {
      throw const AccountException('Enter a valid email address.');
    }
  }

  static void _validatePassword(String password) {
    if (!isValidPassword(password)) {
      throw const AccountException(
        'Password must be between 8 and 128 characters.',
      );
    }
  }

  static Map<String, dynamic> _readAccounts(SharedPreferences preferences) {
    final saved = preferences.getString(_accountsKey);
    if (saved == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(saved) as Map);
    } on FormatException {
      return {};
    }
  }

  static String _newSalt() {
    final random = Random.secure();
    return List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _hashPassword(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
