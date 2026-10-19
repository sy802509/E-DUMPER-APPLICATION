import 'package:flutter/material.dart';

import '../models/phone_sale_details.dart';
import '../services/price_estimate_service.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/action_button.dart';
import '../widgets/screen_header.dart';
import 'phone_condition_screen.dart';

class DeviceDetailsScreen extends StatefulWidget {
  final String brand;

  const DeviceDetailsScreen({super.key, required this.brand});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  bool hasOriginalBill = true;
  String? _selectedModel;
  String? _selectedStorage;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Device Details'),
            const SizedBox(height: 28),
            Text(
              'Device details',
              style: const TextStyle(
                color: AppColors.heading,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tell us about the ${widget.brand} device',
              style: const TextStyle(
                color: AppColors.statSubtitle,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 30),
            _productSelector(),
            const SizedBox(height: 20),
            _storageSelector(),
            const SizedBox(height: 10),
            const Text(
              'Prices are indicative and may change after inspection.',
              style: TextStyle(color: AppColors.statSubtitle, fontSize: 13),
            ),
            const SizedBox(height: 28),
            const Text(
              'Have Original Bill?',
              style: TextStyle(
                color: AppColors.heading,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: 'Yes',
                    isSelected: hasOriginalBill,
                    onTap: () => setState(() => hasOriginalBill = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChoiceButton(
                    label: 'No',
                    isSelected: !hasOriginalBill,
                    onTap: () => setState(() => hasOriginalBill = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            PrimaryActionButton(label: 'Continue', onPressed: _continue),
          ],
        ),
      ),
    );
  }

  List<DeviceModelOption> get _models =>
      DevicePricingService.modelsForBrand(widget.brand);

  DeviceModelOption? get _model {
    for (final model in _models) {
      if (model.name == _selectedModel) return model;
    }
    return null;
  }

  Widget _productSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedModel,
      isExpanded: true,
      dropdownColor: AppColors.statsBackground,
      iconEnabledColor: AppColors.accent,
      style: const TextStyle(
        color: AppColors.heading,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: _selectorDecoration('Phone model'),
      hint: const Text(
        'Choose a model',
        style: TextStyle(color: AppColors.statSubtitle, fontSize: 16),
      ),
      items: [
        for (final model in _models)
          DropdownMenuItem(
            value: model.name,
            child: Text(
              model.name,
              style: const TextStyle(color: AppColors.heading, fontSize: 16),
            ),
          ),
      ],
      onChanged: (value) => setState(() {
        _selectedModel = value;
        _selectedStorage = null;
      }),
    );
  }

  Widget _storageSelector() {
    final storagePrices = _model?.storagePrices ?? const <StoragePrice>[];
    return DropdownButtonFormField<String>(
      initialValue: _selectedStorage,
      isExpanded: true,
      dropdownColor: AppColors.statsBackground,
      iconEnabledColor: AppColors.accent,
      style: const TextStyle(
        color: AppColors.heading,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: _selectorDecoration('Storage capacity'),
      hint: Text(
        _model == null ? 'Choose a model first' : 'Choose storage',
        style: const TextStyle(color: AppColors.statSubtitle, fontSize: 16),
      ),
      items: [
        for (final price in storagePrices)
          DropdownMenuItem(
            value: price.storage,
            child: Text(
              price.storage,
              style: const TextStyle(color: AppColors.heading, fontSize: 16),
            ),
          ),
      ],
      onChanged: _model == null
          ? null
          : (value) => setState(() => _selectedStorage = value),
    );
  }

  InputDecoration _selectorDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.statSubtitle),
    filled: true,
    fillColor: AppColors.statsBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
  );

  void _continue() {
    final model = _model;
    final storage = _selectedStorage;
    final baseValue = model == null || storage == null
        ? null
        : DevicePricingService.baseValueFor(widget.brand, model.name, storage);
    if (model == null || storage == null || baseValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose the phone model and storage.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PhoneConditionScreen(
          submission: PhoneSaleDetails(
            brand: widget.brand,
            model: model.name,
            storage: storage,
            baseValue: baseValue,
            hasOriginalBill: hasOriginalBill,
            issues: const [],
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: isSelected
            ? AppColors.accent.withValues(alpha: 0.08)
            : AppColors.statsBackground,
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.heading,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
