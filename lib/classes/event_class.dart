import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/classes/event_type_enum.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_sorting_options.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/methods/days_functions.dart';
import 'package:firebase_database/firebase_database.dart';

import 'event_category_class.dart';
import 'event_sorting_options.dart';

class Event {
  String id;
  String eventType;
  String headline;
  String desc;
  String creatorId;
  String createDate;
  String category;
  String city;
  String street;
  String house;
  String phone;
  String whatsapp; // Формат даты (например, "yyyy-MM-dd")
  String telegram;
  String instagram;
  String imageUrl;
  String placeId;
  String price;
  String onceDay;
  String longDays;
  String regularDays;
  String irregularDays;
  String? addedToFavouritesCount;
  String? canEdit;
  String? inFav;
  String? today;
  String? inFavCounter;

  Event({
    required this.id,
    required this.eventType,
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
    required this.price,
    this.addedToFavouritesCount,
    this.canEdit,
    this.inFav,
    this.today,
    this.inFavCounter,

  });

  factory Event.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot eventTypeSnapshot = snapshot.child('eventType');
    DataSnapshot headlineSnapshot = snapshot.child('headline');
    DataSnapshot descSnapshot = snapshot.child('desc');
    DataSnapshot creatorIdSnapshot = snapshot.child('creatorId');
    DataSnapshot createDateSnapshot = snapshot.child('createDate');
    DataSnapshot categorySnapshot = snapshot.child('category');
    DataSnapshot citySnapshot = snapshot.child('city');
    DataSnapshot streetSnapshot = snapshot.child('street');
    DataSnapshot houseSnapshot = snapshot.child('house');
    DataSnapshot phoneSnapshot = snapshot.child('phone');
    DataSnapshot whatsappSnapshot = snapshot.child('whatsapp');
    DataSnapshot telegramSnapshot = snapshot.child('telegram');
    DataSnapshot instagramSnapshot = snapshot.child('instagram');
    DataSnapshot imageUrlSnapshot = snapshot.child('imageUrl');
    DataSnapshot placeIdSnapshot = snapshot.child('placeId');
    DataSnapshot onceDayDateSnapshot = snapshot.child('onceDay');
    DataSnapshot longDaysSnapshot = snapshot.child('longDays');
    DataSnapshot regularDaysSnapshot = snapshot.child('regularDays');
    DataSnapshot irregularDaysSnapshot = snapshot.child('irregularDays');
    DataSnapshot priceSnapshot = snapshot.child('price');

    return Event(
        id: idSnapshot.value.toString() ?? '',
        eventType: eventTypeSnapshot.value.toString() ?? '',
        headline: headlineSnapshot.value.toString() ?? '',
        desc: descSnapshot.value.toString() ?? '',
        creatorId: creatorIdSnapshot.value.toString() ?? '',
        createDate: createDateSnapshot.value.toString() ?? '',
        category: categorySnapshot.value.toString() ?? '',
        city: citySnapshot.value.toString() ?? '',
        street: streetSnapshot.value.toString() ?? '',
        house: houseSnapshot.value.toString() ?? '',
        phone: phoneSnapshot.value.toString() ?? '',
        whatsapp: whatsappSnapshot.value.toString() ?? '',
        telegram: telegramSnapshot.value.toString() ?? '',
        instagram: instagramSnapshot.value.toString() ?? '',
        imageUrl: imageUrlSnapshot.value.toString() ?? '',
        placeId: placeIdSnapshot.value.toString() ?? '',
        price: priceSnapshot.value.toString() ?? '',
        onceDay: onceDayDateSnapshot.value.toString() ?? '',
        longDays: longDaysSnapshot.value.toString() ?? '',
        regularDays: regularDaysSnapshot.value.toString() ?? '',
        irregularDays: irregularDaysSnapshot.value.toString() ?? ''

    );
  }

  static List<Event> currentFeedEventsList = [];
  static List<Event> currentFavEventsList = [];
  static List<Event> currentMyEventsList = [];

  static Event emptyEvent = Event(
      id: '',
      eventType: '',
      headline: '',
      desc: '',
      creatorId: '',
      createDate: '',
      category: '',
      city: '',
      street: '',
      house: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
      placeId: '',
    price: '',
    onceDay: '',
    longDays: '',
    regularDays: '',
    irregularDays: ''

  );

  factory Event.empty() {
    return Event(
        id: '',
        eventType: '',
        headline: '',
        desc: '',
        creatorId: '',
        createDate: '',
        category: '',
        city: '',
        street: '',
        house: '',
        phone: '',
        whatsapp: '',
        telegram: '',
        instagram: '',
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
        placeId: '',
        price: '',
        onceDay: '',
        longDays: '',
        regularDays: '',
        irregularDays: ''
    );
  }

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  // Метод для добавления нового пола или редактирования пола в Firebase

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> createOrEditEvent(Event event) async {

    try {

      String eventPath = 'events/${event.id}/event_info';
      String creatorPath = 'users/${event.creatorId}/myEvents/${event.id}';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(eventPath).set({
        'id': event.id,
        'eventType': event.eventType,
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
        'price': event.price ?? ''

      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(creatorPath).set({
        'eventId': event.id,
        //'roleId': '-NngrYovmKAw_cp0pYfJ'
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

  static Future<String> deleteEvent(
      String eventId,
      // List<UserCustom> users, Восстановить если надо добавлять других пользователей
      String creatorId
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



      // TODO По хорошему надо удалять и мероприятия

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  static Future<List<Event>> getAllEvents() async {

    List<Event> events = [];
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

      Event event = Event.fromSnapshot(childSnapshot.child('event_info'));

      String favCount = await Event.getFavCount(event.id);
      String inFav = await Event.addedInFavOrNot(event.id);
      //bool fromPlace = eventFromPlace(event.placeId);

      event.inFav = inFav;
      event.addedToFavouritesCount = favCount;

      currentFeedEventsList.add(event);

      events.add(event);

    }

    // Возвращаем список
    return events;
  }

  /*static bool eventFromPlace (String placeId) {
    return placeId != '';
  }*/

  static Future<List<Event>> getFavEvents(String userId) async {

    List<Event> events = [];
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

        Event temp = await getEventById(event);

        if (temp.id != ''){
          currentFavEventsList.add(temp);
          events.add(temp);
        }

      }

    }
    // Возвращаем список
    return events;
  }

  static Future<List<Event>> getMyEvents(String userId) async {

    List<Event> events = [];
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

        Event temp = await getEventById(event);

        if (temp.id != ''){
          currentMyEventsList.add(temp);
          events.add(temp);
        }

      }

    }
    // Возвращаем список
    return events;
  }


  static List<Event> filterEvents(
      EventCategory eventCategoryFromFilter,
      City cityFromFilter,
      bool freePrice,
      bool today,
      bool onlyFromPlaceEvents,
      List<Event> eventsList
      ) {

    List<Event> events = [];

    for (int i = 0; i<eventsList.length; i++){

      bool result = checkFilter(
        eventCategoryFromFilter,
        cityFromFilter,
        freePrice,
        today,
        onlyFromPlaceEvents,
        eventsList[i],
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
      Event event,
      ) {

    City cityFromEvent = City.getCityByIdFromList(event.city);
    EventCategory categoryFromEvent = EventCategory.getEventCategoryFromCategoriesList(event.category);

    bool category = eventCategoryFromFilter.id == '' || eventCategoryFromFilter.id == categoryFromEvent.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromEvent.id;
    bool checkFreePrice = freePrice == false || event.price == '';
    bool checkToday = today == false || bool.parse(event.today!) == true;
    bool checkFromPlaceEvent = onlyFromPlaceEvents == false || event.placeId != '';

    return category && city && checkFreePrice && checkToday && checkFromPlaceEvent;


  }


  static void sortEvents(EventSortingOption sorting, List<Event> events) {

    switch (sorting){

      case EventSortingOption.nameAsc: events.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case EventSortingOption.nameDesc: events.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case EventSortingOption.favCountAsc: events.sort((a, b) => int.parse(a.inFavCounter!).compareTo(int.parse(b.inFavCounter!))); break;

      case EventSortingOption.favCountDesc: events.sort((a, b) => int.parse(b.inFavCounter!).compareTo(int.parse(a.inFavCounter!))); break;

    }

  }



  static Future<Event> getEventById(String eventId) async {

    Event returnedEvent = Event.empty();

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

      Event event = Event.fromSnapshot(childSnapshot.child('event_info'));

      if (event.id == eventId) {

        returnedEvent = event;
        String favCount = await Event.getFavCount(event.id);
        String inFav = await Event.addedInFavOrNot(event.id);
        String canEdit = await Event.canEditOrNot(event.id);
        event.canEdit = canEdit;
        event.inFav = inFav;
        event.addedToFavouritesCount = favCount;

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

  static EventTypeEnum getEventTypeEnum (String eventType) {
    switch (eventType){

      case 'once': return EventTypeEnum.once;
      case 'long': return EventTypeEnum.long;
      case 'regular': return EventTypeEnum.regular;
      case 'irregular': return EventTypeEnum.irregular;
      default: return EventTypeEnum.once;

    }
  }

  static String getNameEventTypeEnum (EventTypeEnum enumItem) {

    switch (enumItem){

      case EventTypeEnum.once: return 'once';
      case EventTypeEnum.long: return 'long';
      case EventTypeEnum.regular: return 'regular';
      case EventTypeEnum.irregular: return 'irregular';

    }
  }

}