import 'package:flutter/material.dart';

import '../theme/colors.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Expanded(
            child: StatItem(title: 'SELL', subtitle: 'Devices'),
          ),
          StatDivider(),
          Expanded(
            child: StatItem(title: 'GET', subtitle: 'Paid Out'),
          ),
          StatDivider(),
          Expanded(
            child: StatItem(title: '4.9★', subtitle: 'Rating'),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const StatItem({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.statSubtitle, fontSize: 14),
        ),
      ],
    );
  }
}

class StatDivider extends StatelessWidget {
  const StatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 82, color: AppColors.divider);
  }
}
