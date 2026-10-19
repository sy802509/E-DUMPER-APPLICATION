class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final names = fullName.split(' ').where((name) => name.isNotEmpty).toList();
    if (names.isEmpty) return 'U';
    return names.map((name) => name[0].toUpperCase()).take(2).join();
  }

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  Map<String, String> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
  };

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  static const guest = UserProfile(
    firstName: 'Guest',
    lastName: '',
    email: '',
    phone: '',
  );

  static const fallback = guest;
}
