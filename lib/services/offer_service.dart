import '../models/offer.dart';

class OfferService {
  const OfferService();

  Future<List<DeviceOffer>> loadOffers() async => liveOffers;
}
