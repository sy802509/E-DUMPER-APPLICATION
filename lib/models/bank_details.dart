class BankDetails {
  final String accountName;
  final String accountNumber;
  final String ifsc;
  final String upiId;

  const BankDetails({
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
    required this.upiId,
  });

  factory BankDetails.fromMap(Map<String, dynamic> data) {
    return BankDetails(
      accountName: data['accountName'] as String? ?? '',
      accountNumber: data['accountNumber'] as String? ?? '',
      ifsc: data['ifsc'] as String? ?? '',
      upiId: data['upiId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'accountName': accountName.trim(),
    'accountNumber': accountNumber.trim(),
    'ifsc': ifsc.trim().toUpperCase(),
    'upiId': upiId.trim(),
  };
}
