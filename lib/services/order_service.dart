import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/order.dart';
import 'local_account_service.dart';

class OrderService {
  const OrderService();

  Future<List<DeviceOrder>> loadOrders() => loadUserOrders();

  Future<List<DeviceOrder>> loadUserOrders() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(LocalAccountService.sessionEmailKey);
    if (email == null) return [];

    final saved = preferences.getString(_ordersKey(email));
    if (saved == null) return [];
    try {
      return (jsonDecode(saved) as List)
          .map(
            (order) =>
                DeviceOrder.fromMap(Map<String, dynamic>.from(order as Map)),
          )
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<bool> saveOrder(DeviceOrder order) async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(LocalAccountService.sessionEmailKey);
    if (email == null) return false;

    final orders = await loadUserOrders();
    orders.insert(0, order);
    return preferences.setString(
      _ordersKey(email),
      jsonEncode(orders.map((savedOrder) => savedOrder.toMap()).toList()),
    );
  }

  String _ordersKey(String email) => 'edumper.orders.$email';
}
