class DeviceOffer {
  final String brand;
  final String model;
  final String condition;
  final String price;
  final String emoji;
  final bool isHot;

  const DeviceOffer({
    required this.brand,
    required this.model,
    required this.condition,
    required this.price,
    required this.emoji,
    this.isHot = false,
  });
}

const liveOffers = [
  DeviceOffer(
    brand: 'Samsung',
    model: 'Galaxy S21 FE',
    condition: 'Any condition',
    price: 'Up to ₹28,500',
    emoji: '📱',
    isHot: true,
  ),
  DeviceOffer(
    brand: 'Apple',
    model: 'iPhone 13 Pro',
    condition: 'Working parts',
    price: 'Up to ₹62,000',
    emoji: '📱',
    isHot: true,
  ),
  DeviceOffer(
    brand: 'Vivo',
    model: 'V23 Pro',
    condition: 'Dead / broken',
    price: 'Up to ₹11,800',
    emoji: '📱',
  ),
  DeviceOffer(
    brand: 'OnePlus',
    model: '9 Pro',
    condition: 'Any condition',
    price: 'Up to ₹19,500',
    emoji: '📱',
  ),
];
