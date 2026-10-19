import 'package:flutter/material.dart';

import '../models/user_address.dart';
import '../models/phone_sale_details.dart';
import '../models/order.dart';
import '../models/user_profile.dart';
import '../services/address_service.dart';
import '../services/price_estimate_service.dart';
import '../services/local_account_service.dart';
import '../services/order_service.dart';
import '../theme/colors.dart';
import '../widgets/app_panel.dart';
import '../widgets/action_button.dart';
import '../widgets/screen_header.dart';
import 'address_screen.dart';
import 'login_screen.dart';
import 'tracking_screen.dart';

class PriceOfferScreen extends StatefulWidget {
  final PhoneSaleDetails? submission;
  final OrderService orderService;

  const PriceOfferScreen({
    super.key,
    this.submission,
    this.orderService = const OrderService(),
  });

  @override
  State<PriceOfferScreen> createState() => _PriceOfferScreenState();
}

class _PriceOfferScreenState extends State<PriceOfferScreen> {
  final _addressService = const AddressService();
  UserAddress? _address;
  bool _isLoadingAddress = true;
  bool _isPlacingOrder = false;
  bool _isGuest = true;
  DevicePriceEstimate get _estimate => widget.submission == null
      ? const DevicePriceEstimate(baseValue: 0, deductions: [], offerValue: 0)
      : DevicePricingService.estimate(widget.submission!);

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(title: 'Your Quote'),
            const SizedBox(height: 24),
            _QuoteSummary(estimate: _estimate, device: widget.submission),
            const SizedBox(height: 18),
            _DeviceBreakdown(estimate: _estimate, device: widget.submission),
            const SizedBox(height: 26),
            _NextSteps(),
            const SizedBox(height: 22),
            if (_isLoadingAddress)
              const Center(child: CircularProgressIndicator())
            else if (_isGuest) ...[
              const _SignInRequiredNotice(),
              const SizedBox(height: 18),
              PrimaryActionButton(label: 'Sign in', onPressed: _signIn),
              Center(
                child: TextButton(
                  onPressed: _createAccount,
                  child: const Text(
                    'Create account',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ),
            ] else if (_address == null) ...[
              const _AddressNotice(),
              const SizedBox(height: 18),
              PrimaryActionButton(label: 'Add address', onPressed: _addAddress),
            ] else ...[
              _SavedAddressCard(address: _address!),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isPlacingOrder ? null : _addAddress,
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: const Text('Change address'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryActionButton(
                label: _isPlacingOrder ? 'Placing order...' : 'Accept offer',
                onPressed: _isPlacingOrder ? null : _acceptOffer,
              ),
              Center(
                child: TextButton(
                  onPressed: _isPlacingOrder
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(
                    'Decline offer',
                    style: TextStyle(color: AppColors.statSubtitle),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadAddress() async {
    final addressFuture = _addressService.loadCurrentAddress();
    final profileFuture = LocalAccountService().loadCurrentProfile();
    final address = await addressFuture;
    final profile = await profileFuture;
    if (!mounted) return;
    setState(() {
      _address = address;
      _isGuest = profile.email.isEmpty;
      _isLoadingAddress = false;
    });
  }

  Future<void> _signIn() async {
    final profile = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(createAccount: false, returnToCaller: true),
      ),
    );
    if (profile != null) await _loadAddress();
  }

  Future<void> _createAccount() async {
    final profile = await Navigator.of(context).push<UserProfile>(
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(createAccount: true, returnToCaller: true),
      ),
    );
    if (profile != null) await _loadAddress();
  }

  Future<void> _addAddress() async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddressScreen()));
    if (saved == true) await _loadAddress();
  }

  Future<void> _acceptOffer() async {
    final device = widget.submission;
    if (device == null || device.baseValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a supported phone model before continuing.'),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    try {
      final address = await _addressService.loadCurrentAddress();
      if (!mounted) return;
      if (address == null) {
        setState(() => _address = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a pickup address first.')),
        );
        return;
      }

      final now = DateTime.now();
      final order = DeviceOrder(
        number: 'EDO-${now.millisecondsSinceEpoch.toString().substring(6)}',
        device: '${device.brand} ${device.model} · ${device.storage}',
        amount: DevicePricingService.formatRupees(_estimate.offerValue),
        date: 'Just now',
        status: 'Courier assignment pending',
        placedAt: now,
        estimatedPickupAt: now.add(const Duration(hours: 24)),
        issues: device.issues,
      );
      final saved = await widget.orderService.saveOrder(order);
      if (!mounted) return;
      if (saved) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
          (route) => route.isFirst,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to place an order.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}

class _QuoteSummary extends StatelessWidget {
  final DevicePriceEstimate estimate;
  final PhoneSaleDetails? device;

  const _QuoteSummary({required this.estimate, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INDICATIVE ESTIMATE',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            DevicePricingService.formatRupees(estimate.offerValue),
            style: TextStyle(
              color: Colors.black,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${device?.brand ?? 'Phone'} ${device?.model ?? ''} ${device?.storage ?? ''}'
                .trim(),
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          SizedBox(height: 6),
          Text(
            'Final offer is confirmed after device inspection.',
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _DeviceBreakdown extends StatelessWidget {
  final DevicePriceEstimate estimate;
  final PhoneSaleDetails? device;

  const _DeviceBreakdown({required this.estimate, required this.device});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('${device?.model ?? 'Phone'} · ${device?.storage ?? ''}', ''),
      (
        'Good-condition market reference',
        DevicePricingService.formatRupees(estimate.baseValue),
      ),
      for (final deduction in estimate.deductions)
        (
          deduction.reason,
          '−${DevicePricingService.formatRupees(deduction.amount)}',
        ),
      (
        'Estimated offer',
        DevicePricingService.formatRupees(estimate.offerValue),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == rows.length - 1 ? 0 : 15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rows[index].$1,
                      style: TextStyle(
                        color: index == rows.length - 1
                            ? AppColors.heading
                            : AppColors.statSubtitle,
                        fontSize: 14,
                        fontWeight: index == rows.length - 1
                            ? FontWeight.w800
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    rows[index].$2,
                    style: TextStyle(
                      color: index == rows.length - 1
                          ? AppColors.accent
                          : AppColors.heading,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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

class _NextSteps extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        'Accept the offer',
        'Confirm your device details and accept the quote',
      ),
      (
        '02',
        'Pickup request',
        'Estimated pickup within 24 hours; courier assignment is pending',
      ),
      (
        '03',
        'Get paid',
        'Final payment timing is confirmed after device inspection',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NEXT STEPS',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.$1,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$2,
                        style: const TextStyle(
                          color: AppColors.heading,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.$3,
                        style: const TextStyle(
                          color: AppColors.statSubtitle,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressNotice extends StatelessWidget {
  const _AddressNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('📍', style: TextStyle(fontSize: 25)),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address required',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add a pickup address before accepting this offer.',
                  style: TextStyle(color: AppColors.statSubtitle, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInRequiredNotice extends StatelessWidget {
  const _SignInRequiredNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: AppColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sign in or create an account to add a pickup address and place this order.',
              style: TextStyle(color: AppColors.statSubtitle, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedAddressCard extends StatelessWidget {
  final UserAddress address;

  const _SavedAddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.statsBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pickup address',
                  style: TextStyle(
                    color: AppColors.heading,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${address.fullName}\n${address.building}, ${address.street}, ${address.city} ${address.pincode}',
                  style: const TextStyle(
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
