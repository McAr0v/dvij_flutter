import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/classes/date_type_enum.dart';
import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/filters/filter_mixin.dart';
import 'package:firebase_database/firebase_database.dart';
import '../methods/date_functions.dart';
import 'event_category_class.dart';
import 'event_sorting_options.dart';

class EventCustom with MixinDatabase, DateMixin, TimeMixin {
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
  String whatsapp; // Формат даты (например, "yyyy-MM-dd")
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
  int? addedToFavouritesCount;
  bool? inFav;
  bool? today;

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
    this.addedToFavouritesCount,
    this.inFav,
    this.today,

  });

  factory EventCustom.fromSnapshot(DataSnapshot snapshot) {

    DateTypeEnumClass dateTypeClass = DateTypeEnumClass();
    EventCategory eventCategory = EventCategory(name: '', id: snapshot.child('category').value.toString());
    City city = City(name: '', id: snapshot.child('city').value.toString());
    PriceTypeEnumClass priceType = PriceTypeEnumClass();

    OnceDate onceDate = OnceDate();
    String onceDayString = snapshot.child('onceDay').value.toString();

    LongDate longDate = LongDate();
    String longDaysString = snapshot.child('longDays').value.toString();

    RegularDate regularDate = RegularDate();
    String regularDateString = snapshot.child('regularDays').value.toString();

    IrregularDate irregularDate = IrregularDate();
    String irregularDaysString = snapshot.child('irregularDays').value.toString();


    // ---- РАБОТА С ДАТАМИ -----

    DateTypeEnum dateType = dateTypeClass.getEnumFromString(snapshot.child('eventType').value.toString());

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

    bool today = DateMixin.todayOrNot(dateType, onceDate, longDate, regularDate, irregularDate);

    return EventCustom(
        id: snapshot.child('id').value.toString(),
        dateType: dateType,
        headline: snapshot.child('headline').value.toString(),
        desc: snapshot.child('desc').value.toString(),
        creatorId: snapshot.child('creatorId').value.toString(),
        createDate: getDateFromString(snapshot.child('createDate').value.toString()),
        category: eventCategory.getEntityByIdFromList(snapshot.child('category').value.toString()),
        city: city.getEntityByIdFromList(snapshot.child('city').value.toString()),
        street: snapshot.child('street').value.toString(),
        house: snapshot.child('house').value.toString(),
        phone: snapshot.child('phone').value.toString(),
        whatsapp: snapshot.child('whatsapp').value.toString(),
        telegram: snapshot.child('telegram').value.toString(),
        instagram: snapshot.child('instagram').value.toString(),
        imageUrl: snapshot.child('imageUrl').value.toString(),
        placeId: snapshot.child('placeId').value.toString(),
        price: snapshot.child('price').value.toString(),
        priceType: priceType.getEnumFromString(snapshot.child('priceType').value.toString()),
        onceDay: onceDate,
        longDays: longDate,
        regularDays: regularDate,
        irregularDays: irregularDate,
        today: today,
    );
  }

  static List<EventCustom> currentFeedEventsList = [];
  static List<EventCustom> currentFavEventsList = [];
  static List<EventCustom> currentMyEventsList = [];

  static EventCustom emptyEvent = EventCustom(
      id: '',
      dateType: DateTypeEnum.once,
      headline: '',
      desc: '',
      creatorId: '',
      createDate: DateTime(2100),
      category: EventCategory.emptyEventCategory,
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
      priceType: PriceTypeOption.free,
      price: ''
  );

  factory EventCustom.empty() {
    return EventCustom(
        id: '',
        dateType: DateTypeEnum.once,
        headline: '',
        desc: '',
        creatorId: '',
        createDate: DateTime(2100),
        category: EventCategory.emptyEventCategory,
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
        priceType: PriceTypeOption.free,
        price: ''
    );
  }

  Map<String, dynamic> generateEventDataCode() {
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

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ -----
  Future<String> createOrEditEvent() async {

    String placePublishResult = 'success';
    String entityPath = 'events/$id/event_info';
    String creatorPath = 'users/$creatorId/myEvents/$id';


    Map<String, dynamic> data = generateEventDataCode();
    Map<String, dynamic> dataToCreatorAndPlace = MixinDatabase.generateDataCode('eventId', id);

    String entityPublishResult = await MixinDatabase.publishToDB(entityPath, data);
    String creatorPublishResult = await MixinDatabase.publishToDB(creatorPath, dataToCreatorAndPlace);

    if (placeId != '') {
      String placePath = 'places/$placeId/events/$id';
      placePublishResult = await MixinDatabase.publishToDB(placePath, dataToCreatorAndPlace);
    }


    return checkSuccessFromDb(entityPublishResult, creatorPublishResult, placePublishResult, 'success');

  }

  Future<String> deleteEvent() async {

    String entityPath = 'events/$id';
    String creatorPath = 'users/$creatorId/myEvents/$id';
    String placePath = 'places/$placeId/events/$id';
    String inFavPath = 'users/${UserCustom.currentUser?.uid ?? ''}/favEvents/$id';

    String placeDeleteResult = 'success';
    String inFavListDeleteResult = 'success';
    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);
    String creatorDeleteResult = await MixinDatabase.deleteFromDb(creatorPath);
    if (placeId != ''){
      placeDeleteResult = await MixinDatabase.deleteFromDb(placePath);
    }

    if (inFav != null){
      if (inFav!){
          inFavListDeleteResult = await MixinDatabase.deleteFromDb(inFavPath);
      }
    }

    return checkSuccessFromDb(entityDeleteResult, creatorDeleteResult, placeDeleteResult, inFavListDeleteResult);

  }

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

  static Future<String> deleteEventIdFromPlace(
      String eventId,
      String placeId
      ) async {
      String placePath = 'places/$placeId/events/$eventId';
      return await MixinDatabase.deleteFromDb(placePath);
  }

  static Future<List<EventCustom>> getAllEvents() async {

    List<EventCustom> events = [];
    currentFeedEventsList = [];

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('events');

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {

        EventCustom event = EventCustom.fromSnapshot(childSnapshot.child('event_info'));

        event.inFav = await EventCustom.addedInFavOrNot(event.id);
        event.addedToFavouritesCount = await EventCustom.getFavCount(event.id);

        currentFeedEventsList.add(event);
        events.add(event);

      }
    }
    return events;
  }

  static Future<List<EventCustom>> getFavEvents(String userId, {bool refresh = false}) async {

    List<EventCustom> events = [];
    currentFavEventsList = [];
    List<String> eventsId = [];

    // TODO !!! Сделать загрузку списка избранного при загрузке информации пользователя. Здесь обращаться к уже готовому списку
    // TODO !!! Не забыть реализовать обновление списка избранных при добавлении и удалении из избранных
    String favPath = 'users/$userId/favEvents/';
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(favPath);

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {

        DataSnapshot idSnapshot = childSnapshot.child('eventId');

        if (idSnapshot.exists){
          eventsId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список избранных ID не пустой

    if (eventsId.isNotEmpty){

      // Если список всей ленты не пустой и не была вызвана функция обновления, то будем забирать данные из него
      if (currentFeedEventsList.isNotEmpty && !refresh){

        for (String id in eventsId) {
          EventCustom favEvent = getEventFromFeedListById(id);
          if (favEvent.id != ''){
            if (favEvent.id == id){
              currentFavEventsList.add(favEvent);
              events.add(favEvent);
            }
          }
        }

      } else {

        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (String event in eventsId){

          EventCustom temp = EventCustom.emptyEvent;
          temp = await temp.getEventById(event);

          if (temp.id != ''){
            currentFavEventsList.add(temp);
            events.add(temp);
          }
        }
      }
    }
    return events;
  }

  static EventCustom getEventFromFeedListById(String id){
    return currentFeedEventsList.firstWhere((
        element) => element.id == id, orElse: () => EventCustom.emptyEvent);
  }

  /*static EventCustom getEventFromFeedListById(String id){
    EventCustom tempEvent = EventCustom.emptyEvent;
  }*/

  static Future<List<EventCustom>> getMyEvents(String userId, {bool refresh = false}) async {

    List<EventCustom> events = [];
    currentMyEventsList = [];
    List<String> eventsId = [];

    // TODO !!! Сделать загрузку списка моих сущностей при загрузке информации пользователя. Здесь обращаться к уже готовому списку
    // TODO !!! Не забыть реализовать обновление списка моих сущностей при добавлении и удалении из раздела мои
    String favPath = 'users/$userId/myEvents/';
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(favPath);

    if (snapshot != null) {
      for (var childSnapshot in snapshot.children) {

        DataSnapshot idSnapshot = childSnapshot.child('eventId');

        if (idSnapshot.exists){
          eventsId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список избранных ID не пустой, и не была вызвана функция обновления
    if (eventsId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (currentFeedEventsList.isNotEmpty && !refresh) {
        for (String id in eventsId) {
          EventCustom favEvent = getEventFromFeedListById(id);
          if (favEvent.id == id) {
            currentMyEventsList.add(favEvent);
            events.add(favEvent);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var event in eventsId){
          EventCustom temp = EventCustom.emptyEvent;
          temp = await temp.getEventById(event);
          if (temp.id != ''){
            currentMyEventsList.add(temp);
            events.add(temp);
          }
        }
      }
    }
    return events;
  }


  static List<EventCustom> filterEvents(
      EventCategory eventCategoryFromFilter,
      City cityFromFilter,
      bool freePrice,
      bool today,
      bool onlyFromPlaceEvents,
      List<EventCustom> eventsList,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    List<EventCustom> events = [];

    for (int i = 0; i<eventsList.length; i++){

      bool result = checkFilter(
        eventCategoryFromFilter,
        cityFromFilter,
        freePrice,
        today,
        onlyFromPlaceEvents,
        eventsList[i],
        selectedStartDatePeriod,
        selectedEndDatePeriod
      );

      if (result) {
        events.add(eventsList[i]);
      }
    }
    // Возвращаем список
    return events;
  }

  static bool checkFilter (
      EventCategory eventCategoryFromFilter,
      City cityFromFilter,
      bool freePrice,
      bool today,
      bool onlyFromPlaceEvents,
      EventCustom event,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    City cityFromEvent = event.city;
    EventCategory categoryFromEvent = event.category;

    bool category = eventCategoryFromFilter.id == '' || eventCategoryFromFilter.id == categoryFromEvent.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromEvent.id;
    bool checkFreePrice = freePrice == false || event.price == '';
    bool checkToday = today == false || event.today! == true;
    bool checkFromPlaceEvent = onlyFromPlaceEvents == false || event.placeId != '';
    bool checkDate = selectedStartDatePeriod == DateTime(2100) || FilterMixin.checkEventDatesForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);

    return category && city && checkFreePrice && checkToday && checkFromPlaceEvent && checkDate;


  }


  static void sortEvents(EventSortingOption sorting, List<EventCustom> events) {

    switch (sorting){

      case EventSortingOption.nameAsc: events.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case EventSortingOption.nameDesc: events.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case EventSortingOption.favCountAsc: events.sort((a, b) => a.addedToFavouritesCount!.compareTo(b.addedToFavouritesCount!)); break;

      case EventSortingOption.favCountDesc: events.sort((a, b) => b.addedToFavouritesCount!.compareTo(a.addedToFavouritesCount!)); break;

    }

  }

  Future<EventCustom> getEventById(String eventId) async {

    EventCustom returnedEvent = EventCustom.empty();

    String path = 'events/$eventId/event_info';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(path);

    if (snapshot != null){
      EventCustom event = EventCustom.fromSnapshot(snapshot);

      event.inFav = await EventCustom.addedInFavOrNot(event.id);
      event.addedToFavouritesCount = await EventCustom.getFavCount(event.id);

      returnedEvent = event;
    }
    // Возвращаем список
    return returnedEvent;
  }



  static Future<int> getFavCount(String eventId) async {

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('events/$eventId/addedToFavourites');

    if (snapshot != null) {
      return snapshot.children.length;
    } else {
      return 0;
    }

  }

  static Future<bool> addedInFavOrNot(String eventId) async {

    if (UserCustom.currentUser?.uid != null)
    {
      DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('events/$eventId/addedToFavourites/${UserCustom.currentUser?.uid}');

      if (snapshot != null){
        for (var childSnapshot in snapshot.children) {
          if (childSnapshot.value == UserCustom.currentUser?.uid) return true;
        }
      }
    }

    return false;

  }

  static Future<String> addEventToFav(String eventId) async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String eventPath = 'events/$eventId/addedToFavourites/${UserCustom.currentUser?.uid}';
      String userPath = 'users/${UserCustom.currentUser?.uid}/favEvents/$eventId';

      Map<String, dynamic> eventData = MixinDatabase.generateDataCode('userId', UserCustom.currentUser?.uid);
      Map<String, dynamic> userData = MixinDatabase.generateDataCode('eventId', eventId);

      String eventPublish = await MixinDatabase.publishToDB(eventPath, eventData);
      String userPublish = await MixinDatabase.publishToDB(userPath, userData);

      addEventToCurrentFavList(eventId);

      String result = 'success';

      if (eventPublish != 'success') result = eventPublish;
      if (userPublish != 'success') result = userPublish;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }

  }

  static Future<String> deleteEventFromFav(String eventId) async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String eventPath = 'events/$eventId/addedToFavourites/${UserCustom.currentUser?.uid}';
      String userPath = 'users/${UserCustom.currentUser?.uid}/favEvents/$eventId';

      String eventDelete = await MixinDatabase.deleteFromDb(eventPath);
      String userDelete = await MixinDatabase.deleteFromDb(userPath);

      deleteEventFromCurrentFavList(eventId);

      String result = 'success';

      if (eventDelete != 'success') result = eventDelete;
      if (userDelete != 'success') result = userDelete;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }


  static void deleteEventFromCurrentFavList(String eventId){

    currentFavEventsList.removeWhere((event) => event.id == eventId);

  }

  static void addEventToCurrentFavList(String eventId){

    for (var event in currentFeedEventsList){
      if (event.id == eventId){
        currentFavEventsList.add(event);
        break;
      }
    }
  }


  static void updateCurrentEventListFavInformation(String eventId, int favCounter, bool inFav){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    for (int i = 0; i<currentFeedEventsList.length; i++){
      // Если ID совпадает
      if (currentFeedEventsList[i].id == eventId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentFeedEventsList[i].addedToFavouritesCount = favCounter;
        currentFeedEventsList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<currentFavEventsList.length; i++){
      // Если ID совпадает
      if (currentFavEventsList[i].id == eventId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentFavEventsList[i].addedToFavouritesCount = favCounter;
        currentFavEventsList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<currentMyEventsList.length; i++){
      // Если ID совпадает
      if (currentMyEventsList[i].id == eventId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentMyEventsList[i].addedToFavouritesCount = favCounter;
        currentMyEventsList[i].inFav = inFav;
        break;
      }
    }

  }

  static void deleteEventFromCurrentEventLists(String eventId){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    currentFeedEventsList.removeWhere((event) => event.id == eventId);
    currentFavEventsList.removeWhere((event) => event.id == eventId);
    currentMyEventsList.removeWhere((event) => event.id == eventId);

  }

  static Future<List<EventCustom>> getEventsList(String eventsListInString, {String decimal = ','}) async {
    List<EventCustom> tempList = [];

    List<String> splittedString = eventsListInString.split(decimal);

    for (int i = 0; i < splittedString.length; i++){
      EventCustom tempEvent = getEventFromFeedListById(splittedString[i]);

      if (tempEvent.id != ''){
        tempList.add(tempEvent);
      } else {
        tempEvent = await tempEvent.getEventById(splittedString[i]);
        if (tempEvent.id != ''){
          tempList.add(tempEvent);
        }
      }
    }

    return tempList;
  }
}