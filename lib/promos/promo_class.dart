import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/constants/constants.dart';
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
import 'package:dvij_flutter/promos/promo_sorting_options.dart';
import 'package:dvij_flutter/promos/promos_list_class.dart';
import 'package:dvij_flutter/promos/promos_list_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../events/event_sorting_options.dart';
import '../image_uploader/image_uploader.dart';

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
  List<String> favUsersIds;
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
    required this.favUsersIds,
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
      favUsersIds: promoTemp.getFavIdsList(favSnapshot)
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
      city: City.empty(),
      street: '',
      house: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      imageUrl: AppConstants.defaultAvatar,
      placeId: '',
      onceDay: OnceDate(),
      longDays: LongDate(),
      regularDays: RegularDate(),
      irregularDays: IrregularDate(),
      inFav: false,
      favUsersIds: [],
      today: false
  );


  @override
  void addEntityToCurrentEntitiesLists() {
    PromoList promosList = PromoList();
    promosList.addEntityFromCurrentEntitiesLists(this);
  }

  @override
  Future<String> addToFav() async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String promoPath = 'promos/$id/addedToFavourites/${UserCustom.currentUser?.uid}';

      Map<String, dynamic> promoData = MixinDatabase.generateDataCode('userId', UserCustom.currentUser?.uid);

      String promoPublish = await MixinDatabase.publishToDB(promoPath, promoData);

      if (!favUsersIds.contains(UserCustom.currentUser!.uid)){
        favUsersIds.add(UserCustom.currentUser!.uid);
        inFav = true;
      }

      if(PromoListsManager.currentFeedPromosList.promosList.isNotEmpty){
        updateCurrentEntityInEntitiesList();
      }

      String result = 'success';

      if (promoPublish != 'success') result = promoPublish;

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

    ImageUploader imageUploader = ImageUploader();

    String entityPath = 'promos/$id';
    String creatorPath = 'users/$creatorId/myPromos/$id';
    String placePath = 'places/$placeId/promos/$id';

    String placeDeleteResult = 'success';
    String imageDeleteResult = 'success';
    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);
    String creatorDeleteResult = await MixinDatabase.deleteFromDb(creatorPath);

    imageDeleteResult = await imageUploader.removeImage(ImageFolderEnum.promos, id);

    if (placeId != ''){
      placeDeleteResult = await MixinDatabase.deleteFromDb(placePath);
    }

    // Удаляем записи у пользователей, добавивших в избранное
    for (String favUser in favUsersIds){
      String favUserPath = 'users/$favUser/favPromos/$id';
      await MixinDatabase.deleteFromDb(favUserPath);
    }

    return checkSuccessFromDb(entityDeleteResult, creatorDeleteResult, placeDeleteResult, imageDeleteResult);
  }

  @override
  Future<String> deleteFromFav() async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String promoPath = 'promos/$id/addedToFavourites/${UserCustom.currentUser?.uid}';

      String promoDelete = await MixinDatabase.deleteFromDb(promoPath);

      if (favUsersIds.contains(UserCustom.currentUser?.uid)){
        favUsersIds.removeWhere((element) => element == UserCustom.currentUser?.uid);
        inFav = false;
      }

      if(PromoListsManager.currentFeedPromosList.promosList.isNotEmpty){
        updateCurrentEntityInEntitiesList();
      }


      String result = 'success';

      if (promoDelete != 'success') result = promoDelete;

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
      return PromoCustom.fromSnapshot(snapshot);
    }
    // Возвращаем список
    return returnedPromo;
  }

  @override
  Future<String> publishToDb() async {
    String placePublishResult = 'success';
    String entityPath = 'promos/$id/promo_info';

    Map<String, dynamic> data = generateEntityDataCode();
    Map<String, dynamic> dataToCreatorAndPlace = MixinDatabase.generateDataCode('promoId', id);

    String entityPublishResult = await MixinDatabase.publishToDB(entityPath, data);

    if (placeId != '') {
      String placePath = 'places/$placeId/promos/$id';
      placePublishResult = await MixinDatabase.publishToDB(placePath, dataToCreatorAndPlace);
    }

    return checkSuccessFromDb(entityPublishResult, placePublishResult, 'success', 'success');
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
    promosList.updateCurrentListFavInformation(id, favUsersIds, inFav);
  }

  @override
  bool addedInFavOrNot(DataSnapshot? snapshot) {
    if (UserCustom.currentUser?.uid != null)
    {
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
  List<String> getFavIdsList(DataSnapshot snapshot) {
    List<String> favIds = [];

    for (DataSnapshot usersIdFolders in snapshot.children){

      String tempId = usersIdFolders.child('userId').value.toString();

      if (!favIds.contains(tempId)){
        favIds.add(tempId);
      }
    }

    return favIds;
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

  @override
  void updateCurrentEntityInEntitiesList() {
    PromoList promoList = PromoList();
    promoList.updateCurrentEntityInEntitiesList(this);
  }

  List<DropdownMenuItem<PromoSortingOption>> getPromoSortingOptionsList(){
    return [
      const DropdownMenuItem(
        value: PromoSortingOption.createDateAsc,
        child: Text('Сначала новые'),
      ),

      const DropdownMenuItem(
        value: PromoSortingOption.createDateDesc,
        child: Text('Сначала старые'),
      ),

      const DropdownMenuItem(
        value: PromoSortingOption.nameAsc,
        child: Text('По имени: А-Я'),
      ),
      const DropdownMenuItem(
        value: PromoSortingOption.nameDesc,
        child: Text('По имени: Я-А'),
      ),
      const DropdownMenuItem(
        value: PromoSortingOption.favCountAsc,
        child: Text('Самые популярные'),
      ),
      const DropdownMenuItem(
        value: PromoSortingOption.favCountDesc,
        child: Text('Менее популярные'),
      ),
    ];
  }

}