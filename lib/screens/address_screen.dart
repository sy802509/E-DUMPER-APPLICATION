import 'package:flutter/material.dart';

import '../models/user_address.dart';
import '../services/address_service.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/text_input_field.dart';
import '../widgets/action_button.dart';
import '../widgets/screen_header.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String selectedType = 'Home';
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _buildingController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressService = const AddressService();
  bool _isLoadingAddress = true;
  bool _hasSavedAddress = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  @override
  void dispose() {
    for (final controller in [
      _fullNameController,
      _phoneController,
      _buildingController,
      _streetController,
      _cityController,
      _pincodeController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: _hasSavedAddress ? 'Pickup Address' : 'Add Address',
            ),
            const SizedBox(height: 22),
            const Text(
              '📍  Our courier will pick up your device from this address after you accept the offer.',
              style: TextStyle(
                color: AppColors.statSubtitle,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Address Type',
              style: TextStyle(
                color: AppColors.heading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final type in ['Home', 'Work', 'Other'])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _TypeButton(
                        label: type,
                        isSelected: selectedType == type,
                        onTap: () => setState(() => selectedType = type),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'Full Name',
                    hint: 'Raj Sharma',
                    controller: _fullNameController,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: TextInputField(
                    label: 'Phone',
                    hint: '+91 98765 43210',
                    controller: _phoneController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextInputField(
              label: 'Flat / House No. / Building',
              hint: 'A-204, Sunshine Apartments',
              controller: _buildingController,
            ),
            const SizedBox(height: 20),
            TextInputField(
              label: 'Area / Street / Locality',
              hint: 'Andheri West',
              controller: _streetController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'City',
                    hint: 'Mumbai',
                    controller: _cityController,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: TextInputField(
                    label: 'Pincode',
                    hint: '400053',
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              '* Fill in required fields to save',
              style: TextStyle(color: AppColors.statSubtitle, fontSize: 12),
            ),
            const SizedBox(height: 28),
            PrimaryActionButton(
              label: _isLoadingAddress
                  ? 'Loading address...'
                  : _isSaving
                  ? 'Saving...'
                  : _hasSavedAddress
                  ? 'Update Address'
                  : 'Save Address',
              onPressed: _isLoadingAddress || _isSaving ? null : _saveAddress,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSavedAddress() async {
    final address = await _addressService.loadCurrentAddress();
    if (!mounted) return;
    if (address != null) {
      _hasSavedAddress = true;
      selectedType = address.type;
      _fullNameController.text = address.fullName;
      _phoneController.text = address.phone;
      _buildingController.text = address.building;
      _streetController.text = address.street;
      _cityController.text = address.city;
      _pincodeController.text = address.pincode;
    }
    setState(() => _isLoadingAddress = false);
  }

  Future<void> _saveAddress() async {
    FocusScope.of(context).unfocus();
    final values = [
      _fullNameController,
      _phoneController,
      _buildingController,
      _streetController,
      _cityController,
      _pincodeController,
    ];
    if (values.any((controller) => controller.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all address fields first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final saveError = await _addressService.saveAddress(
      UserAddress(
        type: selectedType,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        building: _buildingController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saveError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(saveError)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address saved.')));
    Navigator.of(context).pop(true);
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: isSelected
            ? AppColors.accent.withValues(alpha: 0.08)
            : AppColors.statsBackground,
        side: BorderSide(
          color: isSelected ? AppColors.accent : AppColors.divider,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.heading,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
