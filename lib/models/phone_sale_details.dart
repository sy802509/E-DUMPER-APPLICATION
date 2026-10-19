class PhoneSaleDetails {
  final String brand;
  final String model;
  final String storage;
  final int baseValue;
  final bool hasOriginalBill;
  final List<String> issues;

  const PhoneSaleDetails({
    required this.brand,
    required this.model,
    required this.storage,
    required this.baseValue,
    required this.hasOriginalBill,
    required this.issues,
  });

  PhoneSaleDetails copyWith({List<String>? issues}) {
    return PhoneSaleDetails(
      brand: brand,
      model: model,
      storage: storage,
      baseValue: baseValue,
      hasOriginalBill: hasOriginalBill,
      issues: issues ?? this.issues,
    );
  }
}
