import 'ads_enums/ad_location_enum.dart';

abstract class AdsInterface<T> {
  Future<List<T>> getAllAds() async {
    return [];
  }
  List<T> getAdsFromLocation(AdLocationEnum location);

}