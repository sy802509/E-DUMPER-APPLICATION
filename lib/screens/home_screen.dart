import 'package:flutter/material.dart';

import '../models/offer.dart';
import '../models/order.dart';
import '../models/user_profile.dart';
import '../services/offer_service.dart';
import '../services/order_service.dart';
import '../services/app_text.dart';
import '../theme/colors.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onSell;
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;
  final OfferService offerService;
  final OrderService orderService;

  const HomeScreen({
    super.key,
    required this.profile,
    required this.onSell,
    required this.onSignIn,
    required this.onCreateAccount,
    this.offerService = const OfferService(),
    this.orderService = const OrderService(),
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<DeviceOffer>> _offers;
  late Future<List<DeviceOrder>> _orders;

  @override
  void initState() {
    super.initState();
    _offers = widget.offerService.loadOffers();
    _orders = widget.orderService.loadUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Greeting(profile: widget.profile)),
              if (!isGuest)
                _NotificationButton(
                  onPressed: () => _showNotifications(context),
                ),
            ],
          ),
          if (isGuest) ...[
            const SizedBox(height: 20),
            _GuestAccountCard(
              onSignIn: widget.onSignIn,
              onCreateAccount: widget.onCreateAccount,
            ),
          ] else ...[
            const SizedBox(height: 20),
            FutureBuilder<List<DeviceOrder>>(
              future: _orders,
              builder: (context, snapshot) =>
                  _EarningsCard(orders: snapshot.data ?? const []),
            ),
          ],
          const SizedBox(height: 20),
          _SellPrompt(onTap: widget.onSell),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 380;

              return Flex(
                direction: isCompact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('home.buying_now'),
                    style: const TextStyle(
                      color: AppColors.heading,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    context.tr('home.live_offers'),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<DeviceOffer>>(
            future: _offers,
            builder: (context, snapshot) {
              final offers = snapshot.data ?? liveOffers;
              return Column(
                children: offers
                    .map(
                      (offer) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _OfferCard(offer: offer),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  bool get isGuest => widget.profile.email.isEmpty;

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.statsBackground,
      showDragHandle: true,
      builder: (_) => _NotificationsSheet(orders: _orders),
    );
  }
}

class _Greeting extends StatelessWidget {
  final UserProfile profile;

  const _Greeting({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.email.isEmpty)
          const Text(
            'Welcome, guest 👋',
            style: TextStyle(
              color: AppColors.statSubtitle,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          )
        else ...[
          Text(
            context.tr('home.greeting'),
            style: TextStyle(color: AppColors.statSubtitle, fontSize: 15),
          ),
          SizedBox(height: 6),
        ],
        Text(
          profile.email.isEmpty
              ? 'Explore eDumper'
              : '${profile.firstName.isEmpty ? 'User' : profile.firstName} 👋',
          style: TextStyle(
            color: AppColors.heading,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _GuestAccountCard extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onCreateAccount;

  const _GuestAccountCard({
    required this.onSignIn,
    required this.onCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_circle_outlined, color: AppColors.accent),
              SizedBox(width: 10),
              Text(
                'You’re browsing as a guest',
                style: TextStyle(
                  color: AppColors.heading,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in or create an account to save pickup details, place orders, and track your sales.',
            style: TextStyle(
              color: AppColors.statSubtitle,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
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

class _NotificationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NotificationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: context.tr('home.notifications'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.heading,
            size: 25,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.statsBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  final Future<List<DeviceOrder>> orders;

  const _NotificationsSheet({required this.orders});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('home.notifications'),
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            FutureBuilder<List<DeviceOrder>>(
              future: orders,
              builder: (context, snapshot) {
                final userOrders = snapshot.data ?? const <DeviceOrder>[];
                final latestOrder = userOrders.isEmpty
                    ? null
                    : userOrders.first;
                if (latestOrder == null) {
                  return const _NotificationItem(
                    icon: Icons.local_shipping_outlined,
                    title: 'No pickup scheduled',
                    message:
                        'Your pickup updates will appear here after you place an order.',
                  );
                }
                return _NotificationItem(
                  icon: Icons.local_shipping_outlined,
                  title: latestOrder.status,
                  message:
                      '${latestOrder.device} · Order ${latestOrder.number}',
                );
              },
            ),
            const SizedBox(height: 12),
            _NotificationItem(
              icon: Icons.currency_rupee_rounded,
              title: context.tr('home.new_offer'),
              message: context.tr('home.offer_message'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.statSubtitle,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final List<DeviceOrder> orders;

  const _EarningsCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    final paidOrders = orders.where((order) {
      final status = order.status.toLowerCase();
      return status.contains('paid') ||
          status.contains('completed') ||
          status.contains('delivered');
    });
    final earned = paidOrders.fold<int>(
      0,
      (sum, order) => sum + _amount(order.amount),
    );
    final pending = orders
        .where((order) => !paidOrders.contains(order))
        .fold<int>(0, (sum, order) => sum + _amount(order.amount));
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('home.total_earned'),
                      style: const TextStyle(
                        color: AppColors.statSubtitle,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${earned.toString()}',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.accent,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 240;

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Metric(
                      label: context.tr('home.devices_sold'),
                      value: '${orders.length}',
                    ),
                    const SizedBox(height: 12),
                    _Metric(
                      label: context.tr('home.pending_payout'),
                      value: '₹$pending',
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _Metric(
                      label: context.tr('home.devices_sold'),
                      value: '${orders.length}',
                    ),
                  ),
                  Container(width: 1, height: 38, color: AppColors.divider),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _Metric(
                      label: context.tr('home.pending_payout'),
                      value: '₹$pending',
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

  int _amount(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.statSubtitle, fontSize: 13),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.heading,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SellPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _SellPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Text('📱', style: TextStyle(fontSize: 35)),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('onboarding.broken.title'),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      context.tr('home.instant_offer'),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.black, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final DeviceOffer offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 300;
          final details = _OfferDetails(offer: offer);
          final price = _OfferPrice(offer: offer);

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(offer.emoji, style: const TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 14),
                price,
              ],
            );
          }

          return Row(
            children: [
              Text(offer.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 16),
              Expanded(child: details),
              price,
            ],
          );
        },
      ),
    );
  }
}

class _OfferDetails extends StatelessWidget {
  final DeviceOffer offer;

  const _OfferDetails({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offer.isHot)
          Text(
            'HOT',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        Text(
          offer.brand,
          style: const TextStyle(color: AppColors.statSubtitle, fontSize: 13),
        ),
        Text(
          offer.model,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.heading,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          offer.condition,
          style: const TextStyle(color: AppColors.statSubtitle, fontSize: 13),
        ),
      ],
    );
  }
}

class _OfferPrice extends StatelessWidget {
  final DeviceOffer offer;

  const _OfferPrice({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('home.offer_price'),
          style: TextStyle(
            color: AppColors.statSubtitle,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          offer.price,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
