import 'package:flutter/material.dart';

import '../models/phone_sale_details.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/action_button.dart';
import '../widgets/screen_header.dart';
import 'price_offer_screen.dart';

class PhoneConditionScreen extends StatefulWidget {
  final PhoneSaleDetails? submission;

  const PhoneConditionScreen({super.key, this.submission});

  @override
  State<PhoneConditionScreen> createState() => _PhoneConditionScreenState();
}

class _PhoneConditionScreenState extends State<PhoneConditionScreen> {
  final selectedIssues = <String>{};

  final issues = const [
    ('💥', 'Screen damage'),
    ('🔋', 'Dead battery'),
    ('💧', 'Water damage'),
    ('⚡', "Won't power on"),
    ('📷', 'Camera broken'),
    ('🔌', 'No charging'),
    ('🔇', 'Speaker not working'),
    ('🔦', 'Flash damage'),
    ('🔘', 'Button damage'),
    ('🎙️', 'Microphone damage'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: "What's Wrong?"),
            const SizedBox(height: 28),
            const Text(
              "What's wrong with it?",
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select all issues that apply',
              style: TextStyle(color: AppColors.statSubtitle, fontSize: 17),
            ),
            const SizedBox(height: 28),
            ...issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _IssueButton(
                  icon: issue.$1,
                  label: issue.$2,
                  isSelected: selectedIssues.contains(issue.$2),
                  onTap: () {
                    setState(() {
                      if (!selectedIssues.add(issue.$2)) {
                        selectedIssues.remove(issue.$2);
                      }
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: 'Get Instant Quote →',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PriceOfferScreen(
                    submission:
                        (widget.submission ??
                                const PhoneSaleDetails(
                                  brand: 'Unknown',
                                  model: 'Device',
                                  storage: 'Unknown',
                                  baseValue: 0,
                                  hasOriginalBill: false,
                                  issues: [],
                                ))
                            .copyWith(issues: selectedIssues.toList()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        backgroundColor: isSelected
            ? AppColors.accent.withValues(alpha: 0.08)
            : AppColors.statsBackground,
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 23)),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.accent : AppColors.heading,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
