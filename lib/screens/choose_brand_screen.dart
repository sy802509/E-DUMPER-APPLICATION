import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/action_button.dart';
import '../widgets/screen_header.dart';
import 'device_details_screen.dart';

class ChooseBrandScreen extends StatefulWidget {
  const ChooseBrandScreen({super.key});

  @override
  State<ChooseBrandScreen> createState() => _ChooseBrandScreenState();
}

class _ChooseBrandScreenState extends State<ChooseBrandScreen> {
  String? selectedBrand;
  final brands = const ['Apple', 'Samsung', 'Vivo', 'OnePlus'];

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Select Brand'),
            const SizedBox(height: 28),
            const Text(
              'Select brand',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            ...brands.map(
              (brand) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _BrandButton(
                  brand: brand,
                  isSelected: selectedBrand == brand,
                  onTap: () => setState(() => selectedBrand = brand),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: 'Continue',
              onPressed: selectedBrand == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DeviceDetailsScreen(brand: selectedBrand!),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandButton extends StatelessWidget {
  final String brand;
  final bool isSelected;
  final VoidCallback onTap;

  const _BrandButton({
    required this.brand,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
        backgroundColor: isSelected
            ? AppColors.accent.withValues(alpha: 0.08)
            : AppColors.statsBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        brand,
        style: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.heading,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
