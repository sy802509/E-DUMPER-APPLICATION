class DeviceOrder {
  final String number;
  final String device;
  final String amount;
  final String date;
  final String status;
  final DateTime placedAt;
  final DateTime estimatedPickupAt;
  final List<String> issues;

  const DeviceOrder({
    required this.number,
    required this.device,
    required this.amount,
    required this.date,
    required this.status,
    required this.placedAt,
    required this.estimatedPickupAt,
    this.issues = const [],
  });

  Map<String, dynamic> toMap() => {
    'number': number,
    'device': device,
    'amount': amount,
    'date': date,
    'status': status,
    'placedAt': placedAt.toIso8601String(),
    'estimatedPickupAt': estimatedPickupAt.toIso8601String(),
    'issues': issues,
  };

  factory DeviceOrder.fromMap(Map<String, dynamic> data) {
    final placedAt =
        DateTime.tryParse(data['placedAt'] as String? ?? '') ?? DateTime.now();
    return DeviceOrder(
      number: data['number'] as String? ?? '',
      device: data['device'] as String? ?? '',
      amount: data['amount'] as String? ?? '',
      date: data['date'] as String? ?? '',
      status: data['status'] as String? ?? '',
      placedAt: placedAt,
      estimatedPickupAt:
          DateTime.tryParse(data['estimatedPickupAt'] as String? ?? '') ??
          placedAt.add(const Duration(hours: 24)),
      issues: List<String>.from(data['issues'] as List? ?? const []),
    );
  }
}
