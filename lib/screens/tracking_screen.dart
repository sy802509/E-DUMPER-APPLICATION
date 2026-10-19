import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/screen_header.dart';

class OrderTrackingScreen extends StatelessWidget {
  final DeviceOrder order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Pickup tracking'),
            const SizedBox(height: 24),
            _PickupStatusCard(order: order),
            const SizedBox(height: 18),
            _ProgressCard(order: order),
            const SizedBox(height: 18),
            _CourierInfoCard(),
          ],
        ),
      ),
    );
  }
}

class _PickupStatusCard extends StatelessWidget {
  final DeviceOrder order;

  const _PickupStatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PICKUP STATUS',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.status,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            order.device,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order ${order.number} · ${order.amount} estimated',
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.black87),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated pickup by',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDateTime(order.estimatedPickupAt),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DeviceOrder order;

  const _ProgressCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDER PROGRESS',
            style: TextStyle(
              color: AppColors.heading,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          _ProgressStep(
            icon: Icons.check_circle,
            title: 'Pickup request placed',
            detail: _formatDateTime(order.placedAt),
            isComplete: true,
            isLast: false,
          ),
          _ProgressStep(
            icon: Icons.more_horiz_rounded,
            title: 'Courier assignment pending',
            detail: 'We’ll show courier details here after assignment.',
            isComplete: false,
            isLast: false,
          ),
          _ProgressStep(
            icon: Icons.inventory_2_outlined,
            title: 'Phone pickup',
            detail: 'Estimated by ${_formatDateTime(order.estimatedPickupAt)}',
            isComplete: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final bool isComplete;
  final bool isLast;

  const _ProgressStep({
    required this.icon,
    required this.title,
    required this.detail,
    required this.isComplete,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isComplete ? AppColors.accent : AppColors.statSubtitle,
                  size: 21,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isComplete
                          ? AppColors.heading
                          : AppColors.statSubtitle,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: AppColors.statSubtitle,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierInfoCard extends StatelessWidget {
  const _CourierInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_searching_rounded, color: AppColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Courier location unavailable',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Live location and pickup person details appear after a courier service assigns a driver.',
                  style: TextStyle(
                    color: AppColors.statSubtitle,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.day}/${local.month}/${local.year} · $hour:$minute $period';
}
