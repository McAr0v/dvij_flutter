import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/methods/date_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ad_user_class.dart';
import 'ads_enums/ad_active_enum.dart';
import 'ads_enums/ad_index_enum.dart';
import 'ads_enums/ad_location_enum.dart';

class AdAdmin extends AdUser {

  String clientName;
  String clientPhone;
  String clientWhatsapp;
  DateTime ordersDate;

  AdAdmin({
    required String id,
    required this.clientName,
    required this.clientPhone,
    required this.clientWhatsapp,
    required this.ordersDate,
    required String headline,
    required String desc,
    required String url,
    required String imageUrl,
    required DateTime startDate,
    required DateTime endDate,
    required AdLocationEnum location,
    required AdIndexEnum adIndex,
    AdActiveEnum? active = AdActiveEnum.notActive

  }) : super(id: id, headline: headline, desc: desc, url: url, imageUrl: imageUrl, startDate: startDate, endDate: endDate, location: location, adIndex: adIndex);

  // Инициализируем нужные классы:
  static AdLocationEnumClass adLocationEnumClass = AdLocationEnumClass();
  static AdIndexEnumClass adIndexEnumClass = AdIndexEnumClass();
  static AdActiveEnumClass adActiveEnumClass = AdActiveEnumClass();

  factory AdAdmin.fromSnapshot(DataSnapshot snapshot) {

    // Указываем путь к нашим полям
    String id = snapshot.child('id').value.toString();
    String clientName = snapshot.child('clientName').value.toString();
    String clientPhone = snapshot.child('clientPhone').value.toString();
    String clientWhatsapp = snapshot.child('clientWhatsapp').value.toString();
    DateTime ordersDate = DateMixin.getDateFromString(snapshot.child('ordersDate').value.toString());
    String headline = snapshot.child('headline').value.toString();
    String desc = snapshot.child('desc').value.toString();
    String url = snapshot.child('url').value.toString();
    String imageUrl = snapshot.child('imageUrl').value.toString();
    DateTime startDate = DateMixin.getDateFromString(snapshot.child('startDate').value.toString());
    DateTime endDate = DateMixin.getDateFromString(snapshot.child('endDate').value.toString());
    AdLocationEnum location = adLocationEnumClass.getEnumFromString(snapshot.child('location').value.toString());
    AdIndexEnum index = adIndexEnumClass.getEnumFromString(snapshot.child('adIndex').value.toString()) ;
    AdActiveEnum active = AdActiveEnumClass.getEnumFromDate(snapshot.child('startDate').value.toString(), snapshot.child('endDate').value.toString());

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return AdAdmin(
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
  static List<AdAdmin> currentAllAdsList = [];

  Map<String, dynamic> generateAdDataCode(AdAdmin ad) {
    return <String, dynamic> {
      'id': ad.id,
      'clientName': ad.clientName,
      'clientPhone': ad.clientPhone,
      'clientWhatsapp': ad.clientWhatsapp,
      'ordersDate': ad.ordersDate,
      'headline': ad.headline,
      'desc': ad.desc,
      'url': ad.url,
      'imageUrl': ad.imageUrl,
      'startDate': DateMixin.generateDateString(ad.startDate),
      'endDate': DateMixin.generateDateString(ad.endDate),
      'location': adLocationEnumClass.getNameEnum(ad.location),
      'adIndex': adIndexEnumClass.getNameEnum(ad.adIndex),
    };
  }

  Future<String?> publishAd(AdAdmin ad) async {

    String adPath = 'ads/${adLocationEnumClass.getNameEnum(ad.location)}/${adIndexEnumClass.getNameEnum(ad.adIndex)}/${ad.id}';
    Map<String, dynamic> adData = generateAdDataCode(ad);

    String result = await MixinDatabase.publishToDB(adPath, adData);

    return result;

  }

  @override
  List<AdAdmin> getAdsFromLocation(AdLocationEnum location) {
    List<AdAdmin> temp = [];
    for (AdAdmin ad in currentAllAdsList){
      if (ad.location == location) temp.add(ad);
    }
    return temp;
  }

  @override
  Future<List<AdAdmin>> getAllAds() async {

    List<AdAdmin> ads = [];
    currentAllAdsList = [];

    // Получаем данные из БД
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('ads');

    // Если они пришли

    if (snapshot != null){
      // Перебираем папки location
      for (var location in snapshot.children) {
        // Перебираем папки index
        for (var indexSnapshot in location.children ){
          // Перебираем папки с Id
          for (var idSnapshot in indexSnapshot.children){
            // Добавляем в список наш экземпляр сущности
            ads.add(AdAdmin.fromSnapshot(idSnapshot));
          }
        }
      }
    }

    currentAllAdsList = ads;

    // Возвращаем список
    return ads;
  }

}