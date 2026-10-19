class UserAddress {
  final String id;
  final String type;
  final String fullName;
  final String phone;
  final String building;
  final String street;
  final String city;
  final String pincode;

  const UserAddress({
    this.id = '',
    required this.type,
    required this.fullName,
    required this.phone,
    required this.building,
    required this.street,
    required this.city,
    required this.pincode,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'fullName': fullName,
    'phone': phone,
    'building': building,
    'street': street,
    'city': city,
    'pincode': pincode,
  };

  factory UserAddress.fromMap(Map<String, dynamic> data) => UserAddress(
    type: data['type'] as String? ?? 'Home',
    fullName: data['fullName'] as String? ?? '',
    phone: data['phone'] as String? ?? '',
    building: data['building'] as String? ?? '',
    street: data['street'] as String? ?? '',
    city: data['city'] as String? ?? '',
    pincode: data['pincode'] as String? ?? '',
  );
}
