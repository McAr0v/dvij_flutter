import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/classes/date_type_enum.dart';
import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/events/events_elements/event_type_tab_element.dart';
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
  List<DateTime> onceDay;
  List<DateTime> longDays;
  List<String> regularDaysStart;
  List<String> regularDaysEnd;
  List<DateTime> irregularDaysStart;
  List<DateTime> irregularDaysEnd;
  List<DateTime> irregularDaysOnlyDate;
  int? addedToFavouritesCount;
  bool? canEdit;
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
    required this.regularDaysStart,
    required this.regularDaysEnd,
    required this.irregularDaysStart,
    required this.irregularDaysEnd,
    required this.irregularDaysOnlyDate,
    required this.priceType,
    required this.price,
    this.addedToFavouritesCount,
    this.canEdit,
    this.inFav,
    this.today,

  });

  factory EventCustom.fromSnapshot(DataSnapshot snapshot) {

    DateTypeEnumClass dateTypeClass = DateTypeEnumClass();
    EventCategory eventCategory = EventCategory(name: '', id: snapshot.child('category').value.toString());
    City city = City(name: '', id: snapshot.child('city').value.toString());
    PriceTypeEnumClass priceType = PriceTypeEnumClass();

    // ---- РАБОТА С ДАТАМИ -----

    DateTypeEnum dateType = dateTypeClass.getEnumFromString(snapshot.child('eventType').value.toString());
    List<DateTime> onceDay = DateMixin.getDateFromJson(snapshot.child('onceDay').value.toString(), 'date', 'startTime', 'endTime');
    List<DateTime> longDays = DateMixin.getPeriodDatesFromJson(snapshot.child('longDays').value.toString(), 'startDate', 'endDate', 'startTime', 'endTime');

    List<String> regularDaysStart = TimeMixin.getTimeListFromJson(snapshot.child('regularDays').value.toString(), 'startTime', 'Не выбрано');
    List<String> regularDaysEnd = TimeMixin.getTimeListFromJson(snapshot.child('regularDays').value.toString(), 'endTime', 'Не выбрано');

    List<DateTime> irregularDaysStart = [];
    List<DateTime> irregularDaysEnd = [];
    List<DateTime> irregularDaysOnlyDate = [];

    DateMixin.getIrregularDateFromJson(snapshot.child('irregularDays').value.toString(), irregularDaysStart, irregularDaysEnd, irregularDaysOnlyDate);

    bool today = DateMixin.todayOrNot(dateType, onceDay, longDays, regularDaysStart, regularDaysEnd, irregularDaysStart, irregularDaysEnd, irregularDaysOnlyDate);

    return EventCustom(
        id: snapshot.child('id').value.toString(),
        dateType: dateType,
        headline: snapshot.child('headline').value.toString(),
        desc: snapshot.child('desc').value.toString(),
        creatorId: snapshot.child('creatorId').value.toString() ?? '',
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
        onceDay: onceDay,
        longDays: longDays,
        regularDaysStart: regularDaysStart,
        regularDaysEnd: regularDaysEnd,
        irregularDaysStart: irregularDaysStart,
        irregularDaysEnd: irregularDaysEnd,
        irregularDaysOnlyDate: irregularDaysOnlyDate,
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
      onceDay: [],
      longDays: [],
      regularDaysStart: [],
      regularDaysEnd: [],
      irregularDaysStart: [],
      irregularDaysEnd: [],
      irregularDaysOnlyDate: [],
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
        onceDay: [],
        longDays: [],
        regularDaysStart: [],
        regularDaysEnd: [],
        irregularDaysStart: [],
        irregularDaysEnd: [],
        irregularDaysOnlyDate: [],
        priceType: PriceTypeOption.free,
        price: ''
    );
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> createOrEditEvent(EventCustom event) async {

    try {

      String eventPath = 'events/${event.id}/event_info';
      String creatorPath = 'users/${event.creatorId}/myEvents/${event.id}';
      String placePath = 'places/${event.placeId}/events/${event.id}';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(eventPath).set({
        'id': event.id,
        'eventType': event.dateType,
        'headline': event.headline,
        'desc': event.desc,
        'creatorId': event.creatorId,
        'createDate': event.createDate,
        'category': event.category,
        'city': event.city,
        'street': event.street,
        'house': event.house,
        'phone': event.phone,
        'whatsapp': event.whatsapp,
        'telegram': event.telegram,
        'instagram': event.instagram,
        'imageUrl': event.imageUrl,
        'placeId': event.placeId ?? '',
        'onceDay': event.onceDay,
        'longDays': event.longDays,
        'regularDays': event.regularDays,
        'irregularDays': event.irregularDays,
        'price': event.price ?? '',
        'priceType': event.priceType ?? ''

      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(creatorPath).set({
        'eventId': event.id,
        //'roleId': '-NngrYovmKAw_cp0pYfJ'
      });

      if (event.placeId != '') {
        await FirebaseDatabase.instance.ref().child(placePath).set(
          {
            'eventId': event.id,
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

  static Future<String> deleteEvent(
      String eventId,
      // List<UserCustom> users, Восстановить если надо добавлять других пользователей
      String creatorId,
      String placeId
      ) async {
    try {

      DatabaseReference reference = FirebaseDatabase.instance.ref().child('events').child(eventId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Мероприятие не найдено';
      }

      // Удаляем место
      await reference.remove();

      // Удалить админские записи у пользователей

      /*for (var user in users) {

        DatabaseReference userReference = FirebaseDatabase.instance.ref().child('users').child(user.uid).child('myPlaces').child(eventId);

        await userReference.remove();

      }*/

      // Удаляем создателя

      if (creatorId != '') {
        DatabaseReference userReference = FirebaseDatabase.instance.ref().child('users').child(creatorId).child('myEvents').child(eventId);

        await userReference.remove();
      }

      if (placeId != '') {
        await EventCustom.deleteEventIdFromPlace(eventId, placeId);
      }



      // TODO По хорошему надо удалять и мероприятия

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  static Future<String> deleteEventIdFromPlace(
      String eventId,
      // List<UserCustom> users, Восстановить если надо добавлять других пользователей
      String placeId
      ) async {
    try {

      DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/events').child(eventId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Мероприятие не найдено';
      }

      // Удаляем место
      await reference.remove();

      return 'success';

    } catch (error) {
      return '$error';
    }
  }

  static Future<List<EventCustom>> getAllEvents() async {

    List<EventCustom> events = [];
    currentFeedEventsList = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('events');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      EventCustom event = EventCustom.fromSnapshot(childSnapshot.child('event_info'));

      String favCount = await EventCustom.getFavCount(event.id);
      String inFav = await EventCustom.addedInFavOrNot(event.id);
      //bool fromPlace = eventFromPlace(event.placeId);

      event.inFav = inFav;
      event.addedToFavouritesCount = favCount;
      event.today = todayEventOrNot(event).toString();

      currentFeedEventsList.add(event);

      events.add(event);

    }

    // Возвращаем список
    return events;
  }

  /*static bool eventFromPlace (String placeId) {
    return placeId != '';
  }*/

  static Future<List<EventCustom>> getFavEvents(String userId) async {

    List<EventCustom> events = [];
    currentFavEventsList = [];
    List<String> eventsId = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users/$userId/favEvents/');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      DataSnapshot idSnapshot = childSnapshot.child('eventId');

      if (idSnapshot.exists){
        eventsId.add(idSnapshot.value.toString());
      }
    }

    if (eventsId.isNotEmpty){

      for (var event in eventsId){

        EventCustom temp = await getEventById(event);

        if (temp.id != ''){
          currentFavEventsList.add(temp);
          events.add(temp);
        }

      }

    }
    // Возвращаем список
    return events;
  }

  static Future<List<EventCustom>> getMyEvents(String userId) async {

    List<EventCustom> events = [];
    currentMyEventsList = [];
    List<String> eventsId = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users/$userId/myEvents/');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      DataSnapshot idSnapshot = childSnapshot.child('eventId');

      if (idSnapshot.exists){
        eventsId.add(idSnapshot.value.toString());
      }
    }

    if (eventsId.isNotEmpty){

      for (var event in eventsId){

        EventCustom temp = await getEventById(event);

        if (temp.id != ''){
          currentMyEventsList.add(temp);
          events.add(temp);
        }

      }

    }
    // Возвращаем список
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

    City cityFromEvent = City.getCityByIdFromList(event.city);
    EventCategory categoryFromEvent = EventCategory.getEventCategoryFromCategoriesList(event.category);

    bool category = eventCategoryFromFilter.id == '' || eventCategoryFromFilter.id == categoryFromEvent.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromEvent.id;
    bool checkFreePrice = freePrice == false || event.price == '';
    bool checkToday = today == false || bool.parse(event.today!) == true;
    bool checkFromPlaceEvent = onlyFromPlaceEvents == false || event.placeId != '';
    bool checkDate = selectedStartDatePeriod == DateTime(2100) || checkEventsDatesForFilter(event, selectedStartDatePeriod, selectedEndDatePeriod);

    return category && city && checkFreePrice && checkToday && checkFromPlaceEvent && checkDate;


  }


  static void sortEvents(EventSortingOption sorting, List<EventCustom> events) {

    switch (sorting){

      case EventSortingOption.nameAsc: events.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case EventSortingOption.nameDesc: events.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case EventSortingOption.favCountAsc: events.sort((a, b) => int.parse(a.addedToFavouritesCount!).compareTo(int.parse(b.addedToFavouritesCount!))); break;

      case EventSortingOption.favCountDesc: events.sort((a, b) => int.parse(b.addedToFavouritesCount!).compareTo(int.parse(a.addedToFavouritesCount!))); break;

    }

  }

  static Future<EventCustom> getEventById(String eventId) async {

    EventCustom returnedEvent = EventCustom.empty();

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('events');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      EventCustom event = EventCustom.fromSnapshot(childSnapshot.child('event_info'));

      if (event.id == eventId) {

        returnedEvent = event;
        String favCount = await EventCustom.getFavCount(event.id);
        String inFav = await EventCustom.addedInFavOrNot(event.id);
        String canEdit = await EventCustom.canEditOrNot(event.id);
        event.canEdit = canEdit;
        event.inFav = inFav;
        event.addedToFavouritesCount = favCount;
        event.today = todayEventOrNot(event).toString();
      }
    }

    // Возвращаем список
    return returnedEvent;
  }



  static Future<String> getFavCount(String eventId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('events/$eventId/addedToFavourites');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }

  static Future<String> addedInFavOrNot(String eventId) async {

    String addedToFavourites = 'false';

    if (UserCustom.currentUser?.uid != null)
    {

      final DatabaseReference reference = FirebaseDatabase.instance.ref().child('events/$eventId/addedToFavourites/${UserCustom.currentUser?.uid}');

      // Получаем снимок данных папки
      DataSnapshot snapshot = await reference.get();

      for (var childSnapshot in snapshot.children) {
        // заполняем город (City.fromSnapshot) из снимка данных
        // и обавляем в список городов

        if (childSnapshot.value == UserCustom.currentUser?.uid) addedToFavourites = 'true';

      }

    }

    return addedToFavourites;

  }

  static Future<String> canEditOrNot(String eventId) async {

    String canEdit = 'false';

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('events/$eventId/canEdit');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      if (childSnapshot.value == UserCustom.currentUser?.uid) canEdit = 'true';

    }

    return canEdit;

  }

  static Future<String> addEventToFav(String eventId) async {

    try {

      if (UserCustom.currentUser?.uid != null){
        String eventPath = 'events/$eventId/addedToFavourites/${UserCustom.currentUser?.uid}';
        String userPath = 'users/${UserCustom.currentUser?.uid}/favEvents/$eventId';

        // Записываем данные пользователя в базу данных
        await FirebaseDatabase.instance.ref().child(eventPath).set({
          'userId': UserCustom.currentUser?.uid,
        });

        await FirebaseDatabase.instance.ref(userPath).set(
            {
              'eventId': eventId,
            }
        );

        addEventToCurrentFavList(eventId);

        // Если успешно
        return 'success';

      } else {

        return 'Пользователь не зарегистрирован';

      }

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Ошибка записи в избранное: $e');
      return 'Ошибка записи в избранное: $e';
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


  static void updateCurrentEventListFavInformation(String eventId, String favCounter, String inFav){
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

  static Future<String> deleteEventFromFav(String eventId) async {
    try {
      if (UserCustom.currentUser?.uid != null){
        DatabaseReference reference = FirebaseDatabase.instance.ref().child('events/$eventId/addedToFavourites').child(UserCustom.currentUser!.uid);

        // Проверяем, существует ли город с указанным ID
        DataSnapshot snapshot = await reference.get();
        if (!snapshot.exists) {
          return 'Пользователь не найден';
        }

        // Удаляем город
        await reference.remove();

        DatabaseReference referenceUser = FirebaseDatabase.instance.ref().child('users/${UserCustom.currentUser?.uid}/favEvents').child(eventId);

        DataSnapshot snapshotUser = await referenceUser.get();
        if (!snapshotUser.exists) {
          return 'Мероприятие у пользователя не найдено';
        }

        // Удаляем город
        await referenceUser.remove();

      }

      deleteEventFromCurrentFavList(eventId);

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> writeUserRoleInEvent(String eventId, String userId, String roleId) async {

    try {

      String placePath = 'events/$eventId/managers/$userId';
      String userPath = 'users/$userId/myEvents/$eventId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).set({
        'userId': userId,
        'roleId': roleId,
      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(userPath).set({
        'eventId': eventId,
        'roleId': roleId,
      });

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  static Future<String?> deleteUserRoleInEvent(String eventId, String userId) async {

    try {

      String placePath = 'events/$eventId/managers/$userId';
      String userPath = 'users/$userId/myPlaces/$eventId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).remove();
      await FirebaseDatabase.instance.ref().child(userPath).remove();

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  static DateTypeEnum getEventTypeEnum (String eventType) {
    switch (eventType){

      case 'once': return DateTypeEnum.once;
      case 'long': return DateTypeEnum.long;
      case 'regular': return DateTypeEnum.regular;
      case 'irregular': return DateTypeEnum.irregular;
      default: return DateTypeEnum.once;

    }
  }

  static PriceTypeOption getPriceTypeEnum (String priceType) {
    switch (priceType){

      case 'free': return PriceTypeOption.free;
      case 'fixed': return PriceTypeOption.fixed;
      case 'range': return PriceTypeOption.range;
      default: return PriceTypeOption.free;

    }
  }

  static String getNamePriceTypeEnum (PriceTypeOption priceType, {bool translate = false}) {
    switch (priceType){

    case PriceTypeOption.free: return !translate? 'free' : 'Бесплатный вход';
    case PriceTypeOption.fixed: return !translate? 'fixed' : 'Фиксированная';
    case PriceTypeOption.range: return !translate? 'range' : 'От - До';

    }
  }

  static String getPriceString (PriceTypeOption priceType, String fixedPrice, String startPrice, String endPrice){
    switch (priceType){
      case PriceTypeOption.free: return '';
      case PriceTypeOption.fixed: return fixedPrice;
      case PriceTypeOption.range: return '$startPrice-$endPrice';
    }
  }

  static String getNameEventTypeEnum (DateTypeEnum enumItem, {bool translate = false}) {

    switch (enumItem){

      case DateTypeEnum.once: return !translate? 'once' : 'Разовое';
      case DateTypeEnum.long: return !translate? 'long' : 'Длительное';
      case DateTypeEnum.regular: return !translate? 'regular' : 'Регулярное';
      case DateTypeEnum.irregular: return !translate? 'irregular' : 'По расписанию';

    }
  }

  static Future<List<EventCustom>> getEventsList(String eventsListInString, {String decimal = ','}) async {
    List<EventCustom> tempList = [];

    List<String> splittedString = eventsListInString.split(decimal);
    print('111 --${splittedString[0]}-');

    for (int i = 0; i < splittedString.length; i++){
      EventCustom tempEvent = getEventFromFeedList(splittedString[i]);

      if (tempEvent.id != ''){
        tempList.add(tempEvent);
      } else {
        tempEvent = await getEventById(splittedString[i]);
        if (tempEvent.id != ''){
          tempList.add(tempEvent);
        }
      }
    }

    return tempList;

  }

  static EventCustom getEventFromFeedList (String eventId){

    EventCustom result = EventCustom.emptyEvent;

    if (currentFeedEventsList.isNotEmpty){
      for (int i = 0; i < currentFeedEventsList.length; i++ )
      {
        if (currentFeedEventsList[i].id == eventId) {
          return currentFeedEventsList[i];
        }
      }
    }

    return result;

  }

}