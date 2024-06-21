import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/filters/filter_mixin.dart';
import 'package:dvij_flutter/interfaces/entity_interface.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:firebase_database/firebase_database.dart';

class PromoCustom with MixinDatabase, TimeMixin implements IEntity{
  String id;
  DateTypeEnum dateType;
  String headline;
  String desc;
  String creatorId;
  DateTime createDate;
  PromoCategory category;
  City city;
  String street;
  String house;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String imageUrl;
  String placeId;
  OnceDate onceDay;
  LongDate longDays;
  RegularDate regularDays;
  IrregularDate irregularDays;
  int addedToFavouritesCount;
  bool inFav;
  bool today;

  PromoCustom({
    required this.id,
    required this.dateType,
    required this.headline,
    required this.desc,
    required this.creatorId,
    required this.createDate,
    required this.category,
    required this.city,
    required this.street,
    required this.house,
    required this.phone,
    required this.whatsapp,
    required this.telegram,
    required this.instagram,
    required this.imageUrl,
    required this.placeId,
    required this.onceDay,
    required this.longDays,
    required this.regularDays,
    required this.irregularDays,
    required this.addedToFavouritesCount,
    required this.inFav,
    required this.today,

  });

  /// МЕТОД СЧИТЫВАНИЯ СУЩНОСТИ С БД
  ///
  /// <br>
  /// Передаем "снимок" с бд и возвращаем заполненную сущность
  /// <br>
  /// <br>
  /// Принимает [DataSnapshot],
  /// <br>
  /// Возвращает [EventCustom]
  factory PromoCustom.fromSnapshot(DataSnapshot snapshot) {

    DataSnapshot infoSnapshot = snapshot.child('promo_info');
    DataSnapshot favSnapshot = snapshot.child('addedToFavourites');
    PromoCustom promoTemp = PromoCustom.emptyPromo;
    // --- ИНИЦИАЛИЗИРУЕМ ПЕРЕМЕННЫЕ ----

    DateTypeEnumClass dateTypeClass = DateTypeEnumClass();
    PromoCategory promoCategory = PromoCategory(name: '', id: infoSnapshot.child('category').value.toString());
    City city = City(name: '', id: infoSnapshot.child('city').value.toString());

    OnceDate onceDate = OnceDate();
    String onceDayString = infoSnapshot.child('onceDay').value.toString();

    LongDate longDate = LongDate();
    String longDaysString = infoSnapshot.child('longDays').value.toString();

    RegularDate regularDate = RegularDate();
    String regularDateString = infoSnapshot.child('regularDays').value.toString();

    IrregularDate irregularDate = IrregularDate();
    String irregularDaysString = infoSnapshot.child('irregularDays').value.toString();


    // ---- РАБОТА С ДАТАМИ -----
    // ---- СЧИТЫВАЕМ И ГЕНЕРИРУЕМ ДАТЫ -----

    DateTypeEnum dateType = dateTypeClass.getEnumFromString(infoSnapshot.child('promoType').value.toString());

    if (onceDayString != ''){
      onceDate = onceDate.getFromJson(onceDayString);
    }

    if (longDaysString != ''){
      longDate = longDate.getFromJson(longDaysString);
    }

    if (regularDateString != ''){
      regularDate = regularDate.getFromJson(regularDateString);
    }

    if (irregularDaysString != ''){
      irregularDate = irregularDate.getFromJson(irregularDaysString);
    }

    // ---- МЕТКА - СЕГОДНЯ ИЛИ НЕТ -----

    bool today = DateMixin.todayOrNot(dateType, onceDate, longDate, regularDate, irregularDate);

    // ---- ВОЗВРАЩАЕМ ЗАПОЛНЕННУЮ СУЩНОСТЬ -----

    return PromoCustom(
      id: infoSnapshot.child('id').value.toString(),
      dateType: dateType,
      headline: infoSnapshot.child('headline').value.toString(),
      desc: infoSnapshot.child('desc').value.toString(),
      creatorId: infoSnapshot.child('creatorId').value.toString(),
      createDate: DateMixin.getDateFromString(infoSnapshot.child('createDate').value.toString()),
      category: promoCategory.getEntityByIdFromList(infoSnapshot.child('category').value.toString()),
      city: city.getEntityByIdFromList(infoSnapshot.child('city').value.toString()),
      street: infoSnapshot.child('street').value.toString(),
      house: infoSnapshot.child('house').value.toString(),
      phone: infoSnapshot.child('phone').value.toString(),
      whatsapp: infoSnapshot.child('whatsapp').value.toString(),
      telegram: infoSnapshot.child('telegram').value.toString(),
      instagram: infoSnapshot.child('instagram').value.toString(),
      imageUrl: infoSnapshot.child('imageUrl').value.toString(),
      placeId: infoSnapshot.child('placeId').value.toString(),
      onceDay: onceDate,
      longDays: longDate,
      regularDays: regularDate,
      irregularDays: irregularDate,
      today: today,
        inFav: promoTemp.addedInFavOrNot(favSnapshot),
        addedToFavouritesCount: promoTemp.getFavCount(favSnapshot)
    );
  }

  /// Переменная пустого [PromoCustom]
  static final PromoCustom emptyPromo = PromoCustom(
      id: '',
      dateType: DateTypeEnum.once,
      headline: '',
      desc: '',
      creatorId: '',
      createDate: DateTime(2100),
      category: PromoCategory.empty,
      city: City.emptyCity,
      street: '',
      house: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
      placeId: '',
      onceDay: OnceDate(),
      longDays: LongDate(),
      regularDays: RegularDate(),
      irregularDays: IrregularDate(),
    inFav: false,
    addedToFavouritesCount: 0,
    today: false
  );


  @override
  void addEntityToCurrentEntitiesLists() {
    PromoList promosList = PromoList();
    promosList.addEntityFromCurrentEntitiesLists(this);
  }

  @override
  Future<String> addToFav() async {
    PromoList favPromos = PromoList();

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String promoPath = 'promos/$id/addedToFavourites/${UserCustom.currentUser?.uid}';
      String userPath = 'users/${UserCustom.currentUser?.uid}/favPromos/$id';

      Map<String, dynamic> promoData = MixinDatabase.generateDataCode('userId', UserCustom.currentUser?.uid);
      Map<String, dynamic> userData = MixinDatabase.generateDataCode('promoId', id);

      String promoPublish = await MixinDatabase.publishToDB(promoPath, promoData);
      String userPublish = await MixinDatabase.publishToDB(userPath, userData);

      favPromos.addEntityToCurrentFavList(id);

      String result = 'success';

      if (promoPublish != 'success') result = promoPublish;
      if (userPublish != 'success') result = userPublish;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  @override
  Future<String> deleteEntityIdFromPlace(String placeId) async {
    String placePath = 'places/$placeId/promos/$id';
    return await MixinDatabase.deleteFromDb(placePath);
  }

  @override
  Future<String> deleteFromDb() async {
    String entityPath = 'promos/$id';
    String creatorPath = 'users/$creatorId/myPromos/$id';
    String placePath = 'places/$placeId/promos/$id';
    String inFavPath = 'users/${UserCustom.currentUser?.uid ?? ''}/favPromos/$id';

    String placeDeleteResult = 'success';
    String inFavListDeleteResult = 'success';
    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);
    String creatorDeleteResult = await MixinDatabase.deleteFromDb(creatorPath);
    if (placeId != ''){
      placeDeleteResult = await MixinDatabase.deleteFromDb(placePath);
    }

    if (inFav){
      inFavListDeleteResult = await MixinDatabase.deleteFromDb(inFavPath);
    }

    return checkSuccessFromDb(entityDeleteResult, creatorDeleteResult, placeDeleteResult, inFavListDeleteResult);
  }

  @override
  Future<String> deleteFromFav() async {
    PromoList favPromos = PromoList();

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String promoPath = 'promos/$id/addedToFavourites/${UserCustom.currentUser?.uid}';
      String userPath = 'users/${UserCustom.currentUser?.uid}/favPromos/$id';

      String promoDelete = await MixinDatabase.deleteFromDb(promoPath);
      String userDelete = await MixinDatabase.deleteFromDb(userPath);

      favPromos.deleteEntityFromCurrentFavList(id);

      String result = 'success';

      if (promoDelete != 'success') result = promoDelete;
      if (userDelete != 'success') result = userDelete;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  @override
  Map<String, dynamic> generateEntityDataCode() {
    DateTypeEnumClass dateTypeEnumClass = DateTypeEnumClass();

    return <String, dynamic> {
      'id': id,
      'promoType': dateTypeEnumClass.getNameEnum(dateType),
      'headline': headline,
      'desc': desc,
      'creatorId': creatorId,
      'createDate': DateMixin.generateDateString(createDate),
      'category': category.id,
      'city': city.id,
      'street': street,
      'house': house,
      'phone': phone,
      'whatsapp': whatsapp,
      'telegram': telegram,
      'instagram': instagram,
      'imageUrl': imageUrl,
      'placeId': placeId,
      'onceDay': onceDay.generateDateStingForDb(),
      'longDays': longDays.generateDateStingForDb(),
      'regularDays': regularDays.generateDateStingForDb(),
      'irregularDays': irregularDays.generateDateStingForDb(),
    };
  }

  @override
  Future<PromoCustom> getEntityByIdFromDb(String promoId) async {
    PromoCustom returnedPromo = PromoCustom.emptyPromo;

    String path = 'promos/$promoId';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(path);

    if (snapshot != null){
      PromoCustom promo = PromoCustom.fromSnapshot(snapshot);

      returnedPromo = promo;
    }
    // Возвращаем список
    return returnedPromo;
  }

  @override
  Future<String> publishToDb() async {
    String placePublishResult = 'success';
    String entityPath = 'promos/$id/promo_info';
    String creatorPath = 'users/$creatorId/myPromos/$id';


    Map<String, dynamic> data = generateEntityDataCode();
    Map<String, dynamic> dataToCreatorAndPlace = MixinDatabase.generateDataCode('promoId', id);

    String entityPublishResult = await MixinDatabase.publishToDB(entityPath, data);
    String creatorPublishResult = await MixinDatabase.publishToDB(creatorPath, dataToCreatorAndPlace);

    if (placeId != '') {
      String placePath = 'places/$placeId/promos/$id';
      placePublishResult = await MixinDatabase.publishToDB(placePath, dataToCreatorAndPlace);
    }

    if (UserCustom.currentUser != null){
      if (!UserCustom.currentUser!.myPromos.contains(id)){
        UserCustom.currentUser!.myPromos.add(id);
      }
    }

    return checkSuccessFromDb(entityPublishResult, creatorPublishResult, placePublishResult, 'success');
  }

  /// МЕТОД ПРОВЕРКИ РЕЗУЛЬТАТОВ ВЫГРУЗКИ В БД
  ///
  /// <br>
  /// Передаем результаты разных асинхронных выгрузок из одной функции
  /// <br>
  /// <br>
  /// Вернет [String] "success" если все они успешны,
  /// <br>
  /// Вернет код ошибки, если хоть одна не успешна
  static String checkSuccessFromDb(
      String result1,
      String result2,
      String result3,
      String result4,
      ){
    if (result1 != 'success'){
      return result1;
    } else if (result2 != 'success'){
      return result2;
    } else if (result3 != 'success'){
      return result3;
    } else if (result4 != 'success'){
      return result4;
    } else {
      return 'success';
    }
  }

  @override
  void updateCurrentListFavInformation() {
    PromoList promosList = PromoList();
    promosList.updateCurrentListFavInformation(id, addedToFavouritesCount, inFav);
  }

  @override
  bool addedInFavOrNot(DataSnapshot? snapshot) {
    if (UserCustom.currentUser?.uid != null)
    {
      //DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('promos/$id/addedToFavourites/${UserCustom.currentUser?.uid}');
      if (snapshot != null){
        DataSnapshot userIdSnapshot = snapshot.child(UserCustom.currentUser!.uid).child('userId');
        if (userIdSnapshot.value == UserCustom.currentUser?.uid) return true;
      }
    }
    return false;
  }

  /// ФУНКЦИЯ ГЕНЕРАЦИИ СЛОВАРЯ ФИЛЬТРА ДЛЯ ПЕРЕДАЧИ В ФУНКЦИЮ
  /// <br><br>
  /// Автоматически делает словарь из данных фильтра, по которым
  /// будет производиться фильтрация сущности
  Map<String, dynamic> generateMapForFilter(
      PromoCategory promoCategoryFromFilter,
      City cityFromFilter,
      bool today,
      bool onlyFromPlacePromos,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {
    return {
      'promoCategoryFromFilter': promoCategoryFromFilter,
      'cityFromFilter': cityFromFilter,
      'today': today,
      'onlyFromPlacePromos': onlyFromPlacePromos,
      'selectedStartDatePeriod': selectedStartDatePeriod,
      'selectedEndDatePeriod': selectedEndDatePeriod,
    };
  }

  @override
  bool checkFilter(Map<String, dynamic> mapOfArguments) {

    PromoCategory promoCategoryFromFilter = mapOfArguments['promoCategoryFromFilter'];
    City cityFromFilter = mapOfArguments['cityFromFilter'];
    bool today = mapOfArguments['today'];
    bool onlyFromPlacePromos = mapOfArguments['onlyFromPlacePromos'];
    DateTime selectedStartDatePeriod = mapOfArguments['selectedStartDatePeriod'];
    DateTime selectedEndDatePeriod = mapOfArguments['selectedEndDatePeriod'];

    City cityFromEvent = this.city;
    PromoCategory categoryFromPromo = this.category;

    bool category = promoCategoryFromFilter.id == '' || promoCategoryFromFilter.id == categoryFromPromo.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromEvent.id;
    bool checkToday = today == false || this.today == true;
    bool checkFromPlacePromo = onlyFromPlacePromos == false || placeId != '';
    bool checkDate = selectedStartDatePeriod == DateTime(2100) || FilterMixin.checkPromoDatesForFilter(this, selectedStartDatePeriod, selectedEndDatePeriod);

    return category && city && checkToday && checkFromPlacePromo && checkDate;
  }

  @override
  void deleteEntityFromCurrentEntityLists() {
    PromoList promosList = PromoList();
    promosList.deleteEntityFromCurrentEntitiesLists(id);
  }

  @override
  getEntityFromFeedList(String id) {
    PromoList promosList = PromoList();
    return promosList.getEntityFromFeedListById(id);
  }

  @override
  int getFavCount(DataSnapshot snapshot) {
    if (snapshot.exists) {
      return snapshot.children.length;
    } else {
      return 0;
    }
  }

  @override
  PromoCustom getEntityFromSnapshot(DataSnapshot snapshot) {
    PromoCustom returnedPromo = PromoCustom.emptyPromo;

    if (snapshot.exists){
      PromoCustom promo = PromoCustom.fromSnapshot(snapshot);

      returnedPromo = promo;
    }
    // Возвращаем список
    return returnedPromo;
  }
}