import '../ads/ads_enums/ad_location_enum.dart';

abstract class IAds<T> {
  Future<List<T>> getAllAds();
  List<T> getAdsFromLocation(AdLocationEnum location);

}