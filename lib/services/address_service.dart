import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_address.dart';
import 'local_account_service.dart';

class AddressService {
  const AddressService();

  Future<UserAddress?> loadCurrentAddress() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(LocalAccountService.sessionEmailKey);
    if (email == null) return null;

    final saved = preferences.getString(_addressKey(email));
    if (saved == null) return null;
    try {
      return UserAddress.fromMap(
        Map<String, dynamic>.from(jsonDecode(saved) as Map),
      );
    } on FormatException {
      return null;
    }
  }

  Future<String?> saveAddress(UserAddress address) async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(LocalAccountService.sessionEmailKey);
    if (email == null) return 'Sign in to save a pickup address.';

    final saved = await preferences.setString(
      _addressKey(email),
      jsonEncode(address.toMap()),
    );
    return saved ? null : 'Could not save this address. Please try again.';
  }

  String _addressKey(String email) => 'edumper.address.$email';
}
