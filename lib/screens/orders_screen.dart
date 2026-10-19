import 'package:flutter/material.dart';

import '../models/order.dart';
import 'tracking_screen.dart';
import '../services/order_service.dart';
import '../theme/colors.dart';
import '../widgets/screen_header.dart';

class OrdersScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final OrderService? orderService;
  final bool isGuest;
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;

  const OrdersScreen({
    super.key,
    this.onBack,
    this.orderService,
    this.isGuest = false,
    this.onSignIn,
    this.onCreateAccount,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<DeviceOrder>> _orders;

  @override
  void initState() {
    super.initState();
    _orders = (widget.orderService ?? OrderService()).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'My Orders', onBack: widget.onBack),
          const SizedBox(height: 20),
          if (widget.isGuest)
            _GuestOrdersPrompt(
              onSignIn: widget.onSignIn,
              onCreateAccount: widget.onCreateAccount,
            )
          else
            FutureBuilder<List<DeviceOrder>>(
              future: _orders,
              builder: (context, snapshot) {
                final orders = snapshot.data ?? const <DeviceOrder>[];
                final earned = orders.fold<int>(
                  0,
                  (sum, order) =>
                      sum +
                      (int.tryParse(
                            order.amount.replaceAll(RegExp(r'[^0-9]'), ''),
                          ) ??
                          0),
                );
                if (orders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      'No orders yet. Your accepted offers will appear here.',
                      style: TextStyle(color: AppColors.statSubtitle),
                    ),
                  );
                }
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _Summary(
                            label: 'TOTAL ORDERS',
                            value: '${orders.length}',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _Summary(
                            label: 'ORDER VALUE',
                            value: '₹$earned',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    ...orders.map(
                      (order) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _OrderCard(order: order),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GuestOrdersPrompt extends StatelessWidget {
  final VoidCallback? onSignIn;
  final VoidCallback? onCreateAccount;

  const _GuestOrdersPrompt({this.onSignIn, this.onCreateAccount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.accent, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Sign in to view your orders',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your pickup requests and tracking updates are saved to your account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.statSubtitle, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSignIn,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Sign in'),
            ),
          ),
          TextButton(
            onPressed: onCreateAccount,
            child: const Text(
              'Create account',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String label;
  final String value;

  const _Summary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.statSubtitle,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeviceOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.number,
                style: const TextStyle(
                  color: AppColors.statSubtitle,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                order.amount,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.device,
            style: const TextStyle(
              color: AppColors.heading,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.date,
                style: const TextStyle(
                  color: AppColors.statSubtitle,
                  fontSize: 13,
                ),
              ),
              Text(
                order.status,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(order: order),
                ),
              ),
              icon: const Icon(Icons.location_searching_rounded, size: 18),
              label: const Text('Track pickup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.divider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
