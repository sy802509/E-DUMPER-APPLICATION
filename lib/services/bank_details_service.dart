import '../models/bank_details.dart';

class BankDetailsService {
  const BankDetailsService();

  Future<BankDetails> load() async => const BankDetails(
    accountName: '',
    accountNumber: '',
    ifsc: '',
    upiId: '',
  );

  Future<String?> save(BankDetails details) async => null;
}
