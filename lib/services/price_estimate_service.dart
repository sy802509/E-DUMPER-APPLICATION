import '../models/phone_sale_details.dart';

class StoragePrice {
  final String storage;
  final int goodConditionValue;

  const StoragePrice(this.storage, this.goodConditionValue);
}

class DeviceModelOption {
  final String name;
  final List<StoragePrice> storagePrices;

  const DeviceModelOption(this.name, this.storagePrices);
}

class PriceDeduction {
  final String reason;
  final int amount;

  const PriceDeduction(this.reason, this.amount);
}

class DevicePriceEstimate {
  final int baseValue;
  final List<PriceDeduction> deductions;
  final int offerValue;

  const DevicePriceEstimate({
    required this.baseValue,
    required this.deductions,
    required this.offerValue,
  });
}

class DevicePricingService {
  // Good-condition resale reference values (INR), captured from published
  // Indian buyback listings on 5 Oct 2026. These are snapshots, not live prices.
  static const _modelsByBrand = <String, List<DeviceModelOption>>{
    'Apple': [
      DeviceModelOption('iPhone 11', [
        StoragePrice('64GB', 12490),
        StoragePrice('128GB', 14150),
      ]),
      DeviceModelOption('iPhone 12', [StoragePrice('128GB', 17420)]),
      DeviceModelOption('iPhone 13', [StoragePrice('128GB', 24760)]),
      DeviceModelOption('iPhone 13 Pro', [StoragePrice('128GB', 33370)]),
      DeviceModelOption('iPhone 14', [StoragePrice('128GB', 27780)]),
      DeviceModelOption('iPhone 14 Pro', [StoragePrice('128GB', 43120)]),
      DeviceModelOption('iPhone 15', [StoragePrice('128GB', 42220)]),
      DeviceModelOption('iPhone 16', [StoragePrice('128GB', 52900)]),
    ],
    'Samsung': [
      DeviceModelOption('Galaxy A55 5G', [StoragePrice('128GB', 16530)]),
      DeviceModelOption('Galaxy S23 5G', [
        StoragePrice('128GB', 22650),
        StoragePrice('256GB', 24010),
      ]),
      DeviceModelOption('Galaxy S24 5G', [StoragePrice('256GB', 32830)]),
      DeviceModelOption('Galaxy S24 Ultra 5G', [StoragePrice('256GB', 62140)]),
    ],
    'Vivo': [
      DeviceModelOption('Vivo V30', [StoragePrice('128GB', 18730)]),
      DeviceModelOption('Vivo V40', [
        StoragePrice('128GB', 19740),
        StoragePrice('256GB', 21250),
        StoragePrice('512GB', 21620),
      ]),
      DeviceModelOption('Vivo X100', [StoragePrice('256GB', 25800)]),
      DeviceModelOption('Vivo Y29 5G', [StoragePrice('128GB', 10560)]),
    ],
    'OnePlus': [
      DeviceModelOption('OnePlus 8', [StoragePrice('256GB', 10500)]),
      DeviceModelOption('OnePlus 12R', [StoragePrice('128GB', 24920)]),
      DeviceModelOption('OnePlus 12', [StoragePrice('512GB', 38040)]),
      DeviceModelOption('OnePlus 13', [
        StoragePrice('256GB', 41230),
        StoragePrice('512GB', 43560),
      ]),
      DeviceModelOption('OnePlus 13R', [StoragePrice('256GB', 30460)]),
    ],
  };

  static const _issueDiscounts = <String, int>{
    'Screen damage': 35,
    'Dead battery': 15,
    'Water damage': 40,
    "Won't power on": 65,
    'Camera broken': 20,
    'No charging': 20,
    'Speaker not working': 8,
    'Flash damage': 5,
    'Button damage': 5,
    'Microphone damage': 7,
  };

  static List<DeviceModelOption> modelsForBrand(String brand) =>
      _modelsByBrand[brand] ?? const [];

  static int? baseValueFor(String brand, String model, String storage) {
    for (final option in modelsForBrand(brand)) {
      if (option.name != model) continue;
      for (final price in option.storagePrices) {
        if (price.storage == storage) return price.goodConditionValue;
      }
    }
    return null;
  }

  static DevicePriceEstimate estimate(PhoneSaleDetails device) {
    final baseValue = device.baseValue;
    var remaining = baseValue;
    final minimumValue = baseValue < 500
        ? baseValue
        : (baseValue * 0.05).round().clamp(500, baseValue).toInt();
    final deductions = <PriceDeduction>[];

    for (final issue in _issueDiscounts.entries) {
      if (!device.issues.contains(issue.key)) continue;
      final suggested = _roundToHundred(remaining * issue.value ~/ 100);
      final amount = suggested.clamp(0, remaining - minimumValue).toInt();
      if (amount == 0) continue;
      deductions.add(PriceDeduction(issue.key, amount));
      remaining -= amount;
    }

    if (!device.hasOriginalBill && remaining > minimumValue) {
      final suggested = _roundToHundred(remaining * 3 ~/ 100);
      final amount = suggested.clamp(0, remaining - minimumValue).toInt();
      if (amount > 0) {
        deductions.add(PriceDeduction('No original bill', amount));
        remaining -= amount;
      }
    }

    return DevicePriceEstimate(
      baseValue: baseValue,
      deductions: deductions,
      offerValue: remaining,
    );
  }

  static String formatRupees(int amount) {
    final digits = amount.toString();
    if (digits.length <= 3) return '₹$digits';

    final lastThree = digits.substring(digits.length - 3);
    final prefix = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    for (var end = prefix.length; end > 0; end -= 2) {
      final start = (end - 2).clamp(0, prefix.length).toInt();
      groups.insert(0, prefix.substring(start, end));
    }
    return '₹${groups.join(',')},$lastThree';
  }

  static int _roundToHundred(int amount) => ((amount + 50) ~/ 100) * 100;
}
