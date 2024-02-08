import 'package:dvij_flutter/classes/ads/ad_active_enum.dart';
import 'package:dvij_flutter/classes/ads/ad_index_enum.dart';
import 'package:dvij_flutter/classes/ads/ad_location_enum.dart';
import 'package:dvij_flutter/classes/pair.dart';
import 'package:dvij_flutter/methods/date_class.dart';
import 'package:firebase_database/firebase_database.dart';

import 'enums_interface.dart';

class AdCustom {

  late String id;
  late String clientName;
  late String clientPhone;
  late String clientWhatsapp;
  late DateTime ordersDate;
  late String headline;
  late String desc;
  late String url;
  late String imageUrl;
  late DateTime startDate;
  late DateTime endDate;
  late AdLocationEnum location;
  late AdIndexEnum adIndex;
  late AdActiveEnum active;

  AdCustom({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.clientWhatsapp,
    required this.ordersDate,
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



  factory AdCustom.fromSnapshot(DataSnapshot snapshot) {

    CustomEnums<AdLocationEnum> locationClass = AdLocationEnumClass();
    CustomEnums<AdIndexEnum> indexClass = AdIndexEnumClass();

    // Указываем путь к нашим полям
    String id = snapshot.child('id').value.toString();
    String clientName = snapshot.child('clientName').value.toString();
    String clientPhone = snapshot.child('clientPhone').value.toString();
    String clientWhatsapp = snapshot.child('clientWhatsapp').value.toString();
    DateTime ordersDate = DateClass.getDateFromString(snapshot.child('ordersDate').value.toString());
    String headline = snapshot.child('headline').value.toString();
    String desc = snapshot.child('desc').value.toString();
    String url = snapshot.child('url').value.toString();
    String imageUrl = snapshot.child('imageUrl').value.toString();
    DateTime startDate = DateClass.getDateFromString(snapshot.child('startDate').value.toString());
    DateTime endDate = DateClass.getDateFromString(snapshot.child('endDate').value.toString());
    AdLocationEnum location = locationClass.getEnumFromString(snapshot.child('location').value.toString());
    AdIndexEnum index = indexClass.getEnumFromString(snapshot.child('adIndex').value.toString()) ;
    AdActiveEnum active = AdActiveEnumClass.getEnumFromDate(snapshot.child('startDate').value.toString(), snapshot.child('endDate').value.toString())

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return AdCustom(
      id: id,
      clientName: clientName,
      clientPhone: clientPhone,
      clientWhatsapp: clientWhatsapp,
      ordersDate: ordersDate,
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



  // Статическая переменная для хранения списка городов
  static List<AdCustom> currentAllAdsList = [];

  static List<AdCustom> currentPlacesAdsList = [];
  static List<AdCustom> currentEventsAdsList = [];
  static List<AdCustom> currentPromosAdsList = [];

  static AdCustom empty = AdCustom(
      id: '',
      headline: '',
      desc: '',
      url: '',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
      startDate: DateTime(2024),
      endDate: DateTime(2050),
      location: AdLocationEnum.events,
      adIndex: AdIndexEnum.first,
      active: AdActiveEnum.notActive
  );

  static void resetAdsList(){

    currentAllAdsList = [];
    currentPromosAdsList = [];
    currentPlacesAdsList = [];
    currentEventsAdsList = [];

    currentAllAdsList = feelEmptyList(AdLocationEnum.events, 9);
    currentPlacesAdsList = feelEmptyList(AdLocationEnum.places, 3);
    currentEventsAdsList = feelEmptyList(AdLocationEnum.events, 3);
    currentPromosAdsList = feelEmptyList(AdLocationEnum.promos, 3);
  }

  static List<AdCustom> feelEmptyList(AdLocationEnum adEnum, int adsCount){
    List<AdCustom> tempList = [];
    for (int i = 0; i<adsCount; i++){
      AdCustom tempAd = AdCustom.empty;
      tempAd.adIndex = i;
      tempAd.location = adEnum;
      tempList[i] = tempAd;
    }
    return tempList;
  }

  static Future<void> getAdsAndSave() async {

    resetAdsList();

    currentAllAdsList = await getAds();

    for (AdCustom ad in currentAllAdsList){
      if (ad.location == AdLocationEnum.places) {
        if (ad.active){
          currentPlacesAdsList[ad.adIndex] = ad;
        }

      } else if (ad.location == AdLocationEnum.events){
        if (ad.active){
          currentEventsAdsList[ad.adIndex] = ad;
        }
      } else if (ad.location == AdLocationEnum.promos){
        if (ad.active){
          currentPromosAdsList[ad.adIndex] = ad;
        }
      }
    }
  }

  static Future<List<AdCustom>> getAds() async {

    List<AdCustom> ads = [];
    currentAllAdsList = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('ads');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов
      ads.add(AdCustom.fromSnapshot(childSnapshot.child('ad_info')));
    }
    // Возвращаем список
    return ads;
  }

  static Future<String?> createOrEditAdd(AdCustom ad) async {

    try {

      String adPath = 'ads/${ad.id}/ad_info';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(adPath).set({
        'id': ad.id,
        'eventType': ad.eventType,
        'headline': ad.headline,
        'desc': ad.desc,
        'creatorId': ad.creatorId,
        'createDate': ad.createDate,
        'category': ad.category,
        'city': ad.city,
        'street': ad.street,
        'house': ad.house,
        'phone': ad.phone,
        'whatsapp': ad.whatsapp,
        'telegram': ad.telegram,
        'instagram': ad.instagram,
        'imageUrl': ad.imageUrl,
        'placeId': ad.placeId ?? '',
        'onceDay': ad.onceDay,
        'longDays': ad.longDays,
        'regularDays': ad.regularDays,
        'irregularDays': ad.irregularDays,
        'price': ad.price ?? '',
        'priceType': ad.priceType ?? ''

      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(creatorPath).set({
        'eventId': ad.id,
        //'roleId': '-NngrYovmKAw_cp0pYfJ'
      });

      if (ad.placeId != '') {
        await FirebaseDatabase.instance.ref().child(placePath).set(
            {
              'eventId': ad.id,
            }
        );
      }

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
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

}