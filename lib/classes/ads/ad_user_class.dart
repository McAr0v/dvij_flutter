import 'package:dvij_flutter/classes/ads/ads_interface.dart';
import 'package:dvij_flutter/classes/pair.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/methods/date_class.dart';
import 'package:firebase_database/firebase_database.dart';

import 'ads_enums/ad_active_enum.dart';
import 'ads_enums/ad_index_enum.dart';
import 'ads_enums/ad_location_enum.dart';
import 'ads_enums/enums_interface.dart';

class AdUser with MixinDatabase implements AdsInterface {

  String id;
  String headline;
  String desc;
  String url;
  String imageUrl;
  DateTime startDate;
  DateTime endDate;
  AdLocationEnum location;
  AdIndexEnum adIndex;
  AdActiveEnum active;

  AdUser({
    required this.id,
    required this.headline,
    required this.desc,
    required this.url,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.adIndex,
    this.active = AdActiveEnum.notActive
  });

  factory AdUser.fromSnapshot(DataSnapshot snapshot) {

    CustomEnums<AdLocationEnum> locationClass = AdLocationEnumClass();
    CustomEnums<AdIndexEnum> indexClass = AdIndexEnumClass();

    // Указываем путь к нашим полям
    String id = snapshot.child('id').value.toString();
    String headline = snapshot.child('headline').value.toString();
    String desc = snapshot.child('desc').value.toString();
    String url = snapshot.child('url').value.toString();
    String imageUrl = snapshot.child('imageUrl').value.toString();
    DateTime startDate = DateClass.getDateFromString(snapshot.child('startDate').value.toString());
    DateTime endDate = DateClass.getDateFromString(snapshot.child('endDate').value.toString());
    AdLocationEnum location = locationClass.getEnumFromString(snapshot.child('location').value.toString());
    AdIndexEnum index = indexClass.getEnumFromString(snapshot.child('adIndex').value.toString()) ;
    AdActiveEnum active = AdActiveEnumClass.getEnumFromDate(snapshot.child('startDate').value.toString(), snapshot.child('endDate').value.toString());

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return AdUser(
        id: id,
        headline: headline,
        desc: desc,
        url: url,
        imageUrl: imageUrl,
        startDate: startDate,
        endDate: endDate,
        location: location,
        adIndex: index,
        active: active
    );
  }

  static AdUser emptyAd = AdUser(
      id: '',
      headline: '',
      desc: '',
      url: '',
      imageUrl: '',
      startDate: DateTime(2100),
      endDate: DateTime(2100),
      location: AdLocationEnum.events,
      adIndex: AdIndexEnum.first,
      active: AdActiveEnum.notActive
  );

  // Статическая переменная для хранения списка городов
  static List<AdUser> currentAllAdsList = [];

  static List<AdUser> currentPlacesAdsList = [];
  static List<AdUser> currentEventsAdsList = [];
  static List<AdUser> currentPromosAdsList = [];



  static void resetAdsList(){

    currentPromosAdsList = [];
    currentPlacesAdsList = [];
    currentEventsAdsList = [];

  }

  static List<Pair> generateIndexedList(List<int> adIndexes, int feedElementsListCount)
  {
    int sumOfIndexes = adIndexes.length + feedElementsListCount;
    List<Pair> tempList = [];
    int feedElementIndex = 0;
    int adListIndex = 0;

    for (int i = 0; i < sumOfIndexes; i++){
      // -- Если рекламный список содержит очередной индекс

      if (adIndexes.contains(i)){
        // --- Это реклама ---
        tempList.add(Pair('ad', adListIndex));
        adListIndex++;
      } else {
        if (feedElementIndex < feedElementsListCount){
          tempList.add(Pair('feedElement', feedElementIndex));
          feedElementIndex++;
        }
      }
    }

    if (adIndexes.contains(sumOfIndexes)){
      tempList.add(Pair('ad', adListIndex));
      adListIndex++;
    }

    if (adIndexes.length - adListIndex != 0){
      for (int i = adListIndex; i<adIndexes.length; i++){
        tempList.add(Pair('ad', i));
      }
    }

    return tempList;

  }

  static List<int> getAdIndexesList (List<String> adList, int step, int firstAdIndex){

    List<int> indexesList = [];

    if (adList.isNotEmpty) {
      for (int i = 0; i < adList.length; i++){
        indexesList.add( firstAdIndex + ((step+1) * i) );
      }
    }

    return indexesList;

  }



  @override
  List<AdUser> getAdsFromLocation(AdLocationEnum location) {
    List<AdUser> temp = [];
    for (AdUser ad in currentAllAdsList){
      if (ad.location == location) temp.add(ad);
    }
    return temp;
  }

  static Future<void> getAllAdsAndSave() async {
    // Метод вызывается при загрузке приложения
    // Для подгрузки списка рекламы
    AdUser adUser = AdUser.emptyAd;
    currentAllAdsList = await adUser.getAllAds();

  }

  @override
  Future<List<AdUser>> getAllAds() async {
    List<AdUser> ads = [];
    currentAllAdsList = [];

    // Получаем данные из БД
    DataSnapshot? snapshot = await getInfoFromDB('ads');

    // Если они пришли
    if (snapshot != null){
      // Перебираем папки location
      for (var location in snapshot.children) {
        // Перебираем папки index
        for (var indexSnapshot in location.children ){
          // Перебираем папки с Id
          for (var idSnapshot in indexSnapshot.children){
            // Заполняем данными экземпляр сущности
            AdUser tempUser = AdUser.fromSnapshot(idSnapshot);
            // Если активное объявление, добавляем в список
            if (tempUser.active == AdActiveEnum.active){
              ads.add(tempUser);
            }
          }
        }
      }
    }

    currentAllAdsList = ads;

    return ads;
  }

}