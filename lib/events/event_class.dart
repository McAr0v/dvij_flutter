import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/constants/constants.dart';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/events/event_sorting_options.dart';
import 'package:dvij_flutter/events/events_list_class.dart';
import 'package:dvij_flutter/events/events_list_manager.dart';
import 'package:dvij_flutter/filters/filter_mixin.dart';
import 'package:dvij_flutter/image_uploader/image_uploader.dart';
import 'package:dvij_flutter/interfaces/entity_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'event_category_class.dart';

class EventCustom with MixinDatabase, TimeMixin implements IEntity{
  String id;
  DateTypeEnum dateType;
  String headline;
  String desc;
  String creatorId;
  DateTime createDate;
  EventCategory category;
  City city;
  String street;
  String house;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String imageUrl;
  String placeId;
  PriceTypeOption priceType;
  String price;
  OnceDate onceDay;
  LongDate longDays;
  RegularDate regularDays;
  IrregularDate irregularDays;
  List<String> favUsersIds;
  bool inFav;
  bool today;

  EventCustom({
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
    required this.priceType,
    required this.price,
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
  factory EventCustom.fromSnapshot(DataSnapshot snapshot) {

    DataSnapshot snapshotInfoFolder = snapshot.child('event_info');
    DataSnapshot snapshotFavFolder = snapshot.child('addedToFavourites');
    EventCustom tempEvent = EventCustom.emptyEvent;

    // --- ИНИЦИАЛИЗИРУЕМ ПЕРЕМЕННЫЕ ----

    DateTypeEnumClass dateTypeClass = DateTypeEnumClass();
    EventCategory eventCategory = EventCategory(name: '', id: snapshotInfoFolder.child('category').value.toString());
    City city = City(name: '', id: snapshotInfoFolder.child('city').value.toString());
    PriceTypeEnumClass priceType = PriceTypeEnumClass();

    OnceDate onceDate = OnceDate();
    String onceDayString = snapshotInfoFolder.child('onceDay').value.toString();

    LongDate longDate = LongDate();
    String longDaysString = snapshotInfoFolder.child('longDays').value.toString();

    RegularDate regularDate = RegularDate();
    String regularDateString = snapshotInfoFolder.child('regularDays').value.toString();

    IrregularDate irregularDate = IrregularDate();
    String irregularDaysString = snapshotInfoFolder.child('irregularDays').value.toString();


    // ---- РАБОТА С ДАТАМИ -----
    // ---- СЧИТЫВАЕМ И ГЕНЕРИРУЕМ ДАТЫ -----

    DateTypeEnum dateType = dateTypeClass.getEnumFromString(snapshotInfoFolder.child('eventType').value.toString());

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

    return EventCustom(
        id: snapshotInfoFolder.child('id').value.toString(),
        dateType: dateType,
        headline: snapshotInfoFolder.child('headline').value.toString(),
        desc: snapshotInfoFolder.child('desc').value.toString(),
        creatorId: snapshotInfoFolder.child('creatorId').value.toString(),
        createDate: DateMixin.getDateFromString(snapshotInfoFolder.child('createDate').value.toString()),
        category: eventCategory.getEntityByIdFromList(snapshotInfoFolder.child('category').value.toString()),
        city: city.getEntityByIdFromList(snapshotInfoFolder.child('city').value.toString()),
        street: snapshotInfoFolder.child('street').value.toString(),
        house: snapshotInfoFolder.child('house').value.toString(),
        phone: snapshotInfoFolder.child('phone').value.toString(),
        whatsapp: snapshotInfoFolder.child('whatsapp').value.toString(),
        telegram: snapshotInfoFolder.child('telegram').value.toString(),
        instagram: snapshotInfoFolder.child('instagram').value.toString(),
        imageUrl: snapshotInfoFolder.child('imageUrl').value.toString(),
        placeId: snapshotInfoFolder.child('placeId').value.toString(),
        price: snapshotInfoFolder.child('price').value.toString(),
        priceType: priceType.getEnumFromString(snapshotInfoFolder.child('priceType').value.toString()),
        onceDay: onceDate,
        longDays: longDate,
        regularDays: regularDate,
        irregularDays: irregularDate,
        today: today,
        inFav: tempEvent.addedInFavOrNot(snapshotFavFolder),
        favUsersIds: tempEvent.getFavIdsList(snapshotFavFolder)
    );
  }

  /// Переменная пустого [EventCustom]
  static final EventCustom emptyEvent = EventCustom(
      id: '',
      dateType: DateTypeEnum.once,
      headline: '',
      desc: '',
      creatorId: '',
      createDate: DateTime(2100),
      category: EventCategory.empty(),
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
      priceType: PriceTypeOption.free,
      price: '',
    favUsersIds: [],
    inFav: false,
    today: false
  );


  @override
  void addEntityToCurrentEntitiesLists() {
    EventsList eventsList = EventsList();
    eventsList.addEntityFromCurrentEntitiesLists(this);
  }

  @override
  Future<String> addToFav() async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String eventPath = 'events/$id/addedToFavourites/${UserCustom.currentUser?.uid}';

      Map<String, dynamic> eventData = MixinDatabase.generateDataCode('userId', UserCustom.currentUser?.uid);

      String eventPublish = await MixinDatabase.publishToDB(eventPath, eventData);

      if (!favUsersIds.contains(UserCustom.currentUser!.uid)){
        favUsersIds.add(UserCustom.currentUser!.uid);
        inFav = true;
      }

      if(EventListsManager.currentFeedEventsList.eventsList.isNotEmpty){
        updateCurrentEntityInEntitiesList();
      }

      String result = 'success';

      if (eventPublish != 'success') result = eventPublish;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  @override
  Future<String> deleteEntityIdFromPlace(String placeId) async {
    String placePath = 'places/$placeId/events/$id';
    return await MixinDatabase.deleteFromDb(placePath);
  }

  @override
  Future<String> deleteFromDb() async {

    ImageUploader imageUploader = ImageUploader();

    String entityPath = 'events/$id';
    String creatorPath = 'users/$creatorId/myEvents/$id';
    String placePath = 'places/$placeId/events/$id';

    String placeDeleteResult = 'success';
    String imageDeleteResult = 'success';

    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);
    String creatorDeleteResult = await MixinDatabase.deleteFromDb(creatorPath);

    imageDeleteResult = await imageUploader.removeImage(ImageFolderEnum.events, id);

    if (placeId != ''){
      placeDeleteResult = await MixinDatabase.deleteFromDb(placePath);
    }

    // Удаляем записи у пользователей, добавивших в избранное
    for (String favUser in favUsersIds){
      String favUserPath = 'users/$favUser/favEvents/$id';
      String deleteFavUser = await MixinDatabase.deleteFromDb(favUserPath);
    }

    return checkSuccessFromDb(entityDeleteResult, creatorDeleteResult, placeDeleteResult, imageDeleteResult);
  }

  @override
  Future<String> deleteFromFav() async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String eventPath = 'events/$id/addedToFavourites/${UserCustom.currentUser?.uid}';

      String eventDelete = await MixinDatabase.deleteFromDb(eventPath);

      if (favUsersIds.contains(UserCustom.currentUser?.uid)){
        favUsersIds.removeWhere((element) => element == UserCustom.currentUser?.uid);
        inFav = false;
      }

      if(EventListsManager.currentFeedEventsList.eventsList.isNotEmpty){
        updateCurrentEntityInEntitiesList();
      }

      String result = 'success';

      if (eventDelete != 'success') result = eventDelete;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  @override
  Map<String, dynamic> generateEntityDataCode() {
    DateTypeEnumClass dateTypeEnumClass = DateTypeEnumClass();
    PriceTypeEnumClass priceTypeEnumClass = PriceTypeEnumClass();

    return <String, dynamic> {
      'id': id,
      'eventType': dateTypeEnumClass.getNameEnum(dateType),
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
      'priceType': priceTypeEnumClass.getNameEnum(priceType),
      'price': price,
      'onceDay': onceDay.generateDateStingForDb(),
      'longDays': longDays.generateDateStingForDb(),
      'regularDays': regularDays.generateDateStingForDb(),
      'irregularDays': irregularDays.generateDateStingForDb(),
    };
  }

  @override
  Future<EventCustom> getEntityByIdFromDb(String eventId) async {
    EventCustom returnedEvent = EventCustom.emptyEvent;

    String path = 'events/$eventId';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(path);

    if (snapshot != null){
      return EventCustom.fromSnapshot(snapshot);
    }
    // Возвращаем список
    return returnedEvent;
  }

  @override
  Future<String> publishToDb() async {
    String placePublishResult = 'success';
    String entityPath = 'events/$id/event_info';

    Map<String, dynamic> data = generateEntityDataCode();
    Map<String, dynamic> dataToCreatorAndPlace = MixinDatabase.generateDataCode('eventId', id);

    String entityPublishResult = await MixinDatabase.publishToDB(entityPath, data);

    if (placeId != '') {
      String placePath = 'places/$placeId/events/$id';
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
    EventsList eventsList = EventsList();
    eventsList.updateCurrentListFavInformation(id, favUsersIds, inFav);
  }

  @override
  bool addedInFavOrNot(DataSnapshot snapshot) {
    if (UserCustom.currentUser?.uid != null)
    {
      String value = snapshot.child(UserCustom.currentUser!.uid).child('userId').value.toString();
      if (value == UserCustom.currentUser!.uid) return true;
    }

    return false;
  }


  @override
  bool checkFilter(Map<String, dynamic> mapOfArguments) {

    EventCategory eventCategoryFromFilter = mapOfArguments['eventCategoryFromFilter'];
    City cityFromFilter = mapOfArguments['cityFromFilter'];
    bool freePrice = mapOfArguments['freePrice'];
    bool today = mapOfArguments['today'];
    bool onlyFromPlaceEvents = mapOfArguments['onlyFromPlaceEvents'];
    DateTime selectedStartDatePeriod = mapOfArguments['selectedStartDatePeriod'];
    DateTime selectedEndDatePeriod = mapOfArguments['selectedEndDatePeriod'];

    City cityFromEvent = this.city;
    EventCategory categoryFromEvent = this.category;

    bool category = eventCategoryFromFilter.id == '' || eventCategoryFromFilter.id == categoryFromEvent.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromEvent.id;
    bool checkFreePrice = freePrice == false || price == '';
    bool checkToday = today == false || this.today == true;
    bool checkFromPlaceEvent = onlyFromPlaceEvents == false || placeId != '';
    bool checkDate = selectedStartDatePeriod == DateTime(2100) || FilterMixin.checkEventDatesForFilter(this, selectedStartDatePeriod, selectedEndDatePeriod);

    return category && city && checkFreePrice && checkToday && checkFromPlaceEvent && checkDate;
  }

  @override
  void deleteEntityFromCurrentEntityLists() {
    EventsList eventsList = EventsList();
    eventsList.deleteEntityFromCurrentEntitiesLists(id);
  }

  @override
  getEntityFromFeedList(String id) {
    EventsList eventsList = EventsList();
    return eventsList.getEntityFromFeedListById(id);
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
  EventCustom getEntityFromSnapshot(DataSnapshot snapshot) {
    EventCustom returnedEvent = EventCustom.emptyEvent;

    if (snapshot.exists){
      return EventCustom.fromSnapshot(snapshot);
    }
    // Возвращаем список
    return returnedEvent;
  }

  List<DropdownMenuItem<EventSortingOption>> getEventSortingOptionsList(){
    return [
      const DropdownMenuItem(
        value: EventSortingOption.createDateAsc,
        child: Text('Сначала новые'),
      ),

      const DropdownMenuItem(
        value: EventSortingOption.createDateDesc,
        child: Text('Сначала старые'),
      ),

      const DropdownMenuItem(
        value: EventSortingOption.nameAsc,
        child: Text('По имени: А-Я'),
      ),
      const DropdownMenuItem(
        value: EventSortingOption.nameDesc,
        child: Text('По имени: Я-А'),
      ),
      const DropdownMenuItem(
        value: EventSortingOption.favCountAsc,
        child: Text('Самые популярные'),
      ),
      const DropdownMenuItem(
        value: EventSortingOption.favCountDesc,
        child: Text('Менее популярные'),
      ),
    ];
  }

  @override
  void updateCurrentEntityInEntitiesList() {
    EventsList eventsList = EventsList();
    eventsList.updateCurrentEntityInEntitiesList(this);
  }

}