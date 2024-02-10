import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/methods/days_functions.dart';
import 'package:firebase_database/firebase_database.dart';

class Place {
  String id;
  String name;
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
  String mondayStartTime;
  String mondayFinishTime;
  String tuesdayStartTime;
  String tuesdayFinishTime;
  String wednesdayStartTime;
  String wednesdayFinishTime;
  String thursdayStartTime;
  String thursdayFinishTime;
  String fridayStartTime;
  String fridayFinishTime;
  String saturdayStartTime;
  String saturdayFinishTime;
  String sundayStartTime;
  String sundayFinishTime;
  String? addedToFavouritesCount;
  String? eventsCount;
  String? promoCount;
  String? canEdit;
  String? inFav;
  String? nowIsOpen;
  String? eventsList;
  String? promosList;

  Place({
    required this.id,
    required this.name,
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
    required this.mondayStartTime,
    required this.mondayFinishTime,
    required this.tuesdayStartTime,
    required this.tuesdayFinishTime,
    required this.wednesdayStartTime,
    required this.wednesdayFinishTime,
    required this.thursdayStartTime,
    required this.thursdayFinishTime,
    required this.fridayStartTime,
    required this.fridayFinishTime,
    required this.saturdayStartTime,
    required this.saturdayFinishTime,
    required this.sundayStartTime,
    required this.sundayFinishTime,
    this.addedToFavouritesCount,
    this.canEdit,
    this.eventsCount,
    this.inFav,
    this.promoCount,
    this.nowIsOpen,
    this.eventsList,
    this.promosList

  });

  factory Place.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');
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
    DataSnapshot mondayStartTimeSnapshot = snapshot.child('mondayStartTime');
    DataSnapshot mondayFinishTimeSnapshot = snapshot.child('mondayFinishTime');
    DataSnapshot tuesdayStartTimeSnapshot = snapshot.child('tuesdayStartTime');
    DataSnapshot tuesdayFinishTimeSnapshot = snapshot.child('tuesdayFinishTime');
    DataSnapshot wednesdayStartTimeSnapshot = snapshot.child('wednesdayStartTime');
    DataSnapshot wednesdayFinishTimeSnapshot = snapshot.child('wednesdayFinishTime');
    DataSnapshot thursdayStartTimeSnapshot = snapshot.child('thursdayStartTime');
    DataSnapshot thursdayFinishTimeSnapshot = snapshot.child('thursdayFinishTime');
    DataSnapshot fridayStartTimeSnapshot = snapshot.child('fridayStartTime');
    DataSnapshot fridayFinishTimeSnapshot = snapshot.child('fridayFinishTime');
    DataSnapshot saturdayStartTimeSnapshot = snapshot.child('saturdayStartTime');
    DataSnapshot saturdayFinishTimeSnapshot = snapshot.child('saturdayFinishTime');
    DataSnapshot sundayStartTimeSnapshot = snapshot.child('sundayStartTime');
    DataSnapshot sundayFinishTimeSnapshot = snapshot.child('sundayFinishTime');

    return Place(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
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
      mondayStartTime: mondayStartTimeSnapshot.value.toString() ?? '',
      mondayFinishTime: mondayFinishTimeSnapshot.value.toString() ?? '',
      tuesdayStartTime: tuesdayStartTimeSnapshot.value.toString() ?? '',
      tuesdayFinishTime: tuesdayFinishTimeSnapshot.value.toString() ?? '',
      wednesdayStartTime: wednesdayStartTimeSnapshot.value.toString() ?? '',
      wednesdayFinishTime: wednesdayFinishTimeSnapshot.value.toString() ?? '',
      thursdayStartTime: thursdayStartTimeSnapshot.value.toString() ?? '',
      thursdayFinishTime: thursdayFinishTimeSnapshot.value.toString() ?? '',
      fridayStartTime: fridayStartTimeSnapshot.value.toString() ?? '',
      fridayFinishTime: fridayFinishTimeSnapshot.value.toString() ?? '',
      saturdayStartTime: saturdayStartTimeSnapshot.value.toString() ?? '',
      saturdayFinishTime: saturdayFinishTimeSnapshot.value.toString() ?? '',
      sundayFinishTime: sundayFinishTimeSnapshot.value.toString() ?? '',
      sundayStartTime: sundayStartTimeSnapshot.value.toString() ?? ''

    );
  }

  static List<Place> currentFeedPlaceList = [];
  static List<Place> currentFavPlaceList = [];
  static List<Place> currentMyPlaceList = [];

  static Place emptyPlace = Place(
      id: '',
      name: '',
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
      mondayStartTime: '',
      mondayFinishTime: '',
      tuesdayStartTime: '',
      tuesdayFinishTime: '',
      wednesdayStartTime: '',
      wednesdayFinishTime: '',
      thursdayStartTime: '',
      thursdayFinishTime: '',
      fridayStartTime: '',
      fridayFinishTime: '',
      saturdayStartTime: '',
      saturdayFinishTime: '',
      sundayStartTime: '',
      sundayFinishTime: ''
  );

  factory Place.empty() {
    return Place(
        id: '',
        name: '',
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
        mondayStartTime: '',
        mondayFinishTime: '',
        tuesdayStartTime: '',
        tuesdayFinishTime: '',
        wednesdayStartTime: '',
        wednesdayFinishTime: '',
        thursdayStartTime: '',
        thursdayFinishTime: '',
        fridayStartTime: '',
        fridayFinishTime: '',
        saturdayStartTime: '',
        saturdayFinishTime: '',
        sundayStartTime: '',
        sundayFinishTime: ''
    );
  }

  // TODO убрать время каждого дня в отдельности и сделать списками

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  // Метод для добавления нового пола или редактирования пола в Firebase

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> createOrEditPlace(Place place) async {

    try {

      String placePath = 'places/${place.id}/place_info';
      String creatorPath = 'users/${place.creatorId}/myPlaces/${place.id}';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).set({
        'id': place.id,
        'name': place.name,
        'desc': place.desc,
        'creatorId': place.creatorId,
        'createDate': place.createDate,
        'category': place.category,
        'city': place.city,
        'street': place.street,
        'house': place.house,
        'phone': place.phone,
        'whatsapp': place.whatsapp,
        'telegram': place.telegram,
        'instagram': place.instagram,
        'imageUrl': place.imageUrl,
        'mondayStartTime': place.mondayStartTime,
        'mondayFinishTime': place.mondayFinishTime,
        'tuesdayStartTime': place.tuesdayStartTime,
        'tuesdayFinishTime': place.tuesdayFinishTime,
        'wednesdayFinishTime': place.wednesdayFinishTime,
        'wednesdayStartTime': place.wednesdayStartTime,
        'thursdayStartTime': place.thursdayStartTime,
        'thursdayFinishTime': place.thursdayFinishTime,
        'fridayStartTime': place.fridayStartTime,
        'fridayFinishTime': place.fridayFinishTime,
        'saturdayStartTime': place.saturdayStartTime,
        'saturdayFinishTime': place.saturdayFinishTime,
        'sundayStartTime': place.sundayStartTime,
        'sundayFinishTime': place.sundayFinishTime,

      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(creatorPath).set({
        'placeId': place.id,
        'roleId': '-NngrYovmKAw_cp0pYfJ'
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

  static Future<String> deletePlace(String placeId, List<UserCustom> users, String creatorId) async {
    try {

      DatabaseReference reference = FirebaseDatabase.instance.ref().child('places').child(placeId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Место не найдено';
      }

      // Удаляем место
      await reference.remove();

      // Удалить админские записи у пользователей

      for (var user in users) {

        DatabaseReference userReference = FirebaseDatabase.instance.ref().child('users').child(user.uid).child('myPlaces').child(placeId);

        await userReference.remove();

      }

      // Удаляем создателя

      if (creatorId != '') {
        DatabaseReference userReference = FirebaseDatabase.instance.ref().child('users').child(creatorId).child('myPlaces').child(placeId);

        await userReference.remove();
      }



      // TODO По хорошему надо удалять и мероприятия

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  static Future<List<Place>> getAllPlaces() async {

    List<Place> places = [];
    currentFeedPlaceList = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      Place place = Place.fromSnapshot(childSnapshot.child('place_info'));

      String favCount = await Place.getFavCount(place.id);
      String eventsCount = await Place.getEventsCount(place.id);
      String promosCount = await Place.getPromoCount(place.id);
      String inFav = await Place.addedInFavOrNot(place.id);
      bool nowIsOpenInPlace = nowIsOpenPlace(place);

      place.eventsList = await getEventsList(place.id);
      place.promosList = await getPromosList(place.id);

      place.inFav = inFav;
      place.addedToFavouritesCount = favCount;
      place.eventsCount = eventsCount;
      place.promoCount = promosCount;
      place.nowIsOpen = nowIsOpenInPlace.toString();


      currentFeedPlaceList.add(place);

      places.add(place);

    }

    // Возвращаем список
    return places;
  }

  static Future<List<Place>> getFavPlaces(String userId) async {

    List<Place> places = [];
    currentFavPlaceList = [];
    List<String> placesId = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users/$userId/favPlaces/');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      DataSnapshot idSnapshot = childSnapshot.child('placeId');

      if (idSnapshot.exists){
        placesId.add(idSnapshot.value.toString());
      }
    }

    if (placesId.isNotEmpty){

      for (var place in placesId){

        Place temp = await getPlaceById(place);

        if (temp.id != ''){
          currentFavPlaceList.add(temp);
          places.add(temp);
        }

      }

    }
    // Возвращаем список
    return places;
  }

  static Future<List<Place>> getMyPlaces(String userId) async {

    List<Place> places = [];
    currentMyPlaceList = [];
    List<String> placesId = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users/$userId/myPlaces/');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      DataSnapshot idSnapshot = childSnapshot.child('placeId');

      if (idSnapshot.exists){
        placesId.add(idSnapshot.value.toString());
      }
    }

    if (placesId.isNotEmpty){

      for (var place in placesId){

        Place temp = await getPlaceById(place);

        if (temp.id != ''){
          currentMyPlaceList.add(temp);
          places.add(temp);
        }

      }

    }
    // Возвращаем список
    return places;
  }

  static List<Place> filterPlaces(
      PlaceCategory placeCategoryFromFilter,
      City cityFromFilter,
      bool nowIsOpen,
      bool haveEventsFromFilter,
      bool havePromosFromFilter,
      List<Place> placesList
      ) {

    List<Place> places = [];

    for (int i = 0; i<placesList.length; i++){

      bool result = checkFilter(
          placeCategoryFromFilter,
          cityFromFilter,
          nowIsOpen,
          haveEventsFromFilter,
          havePromosFromFilter,
          placesList[i],
          //cityFromPlace,
          //categoryFromPlace
      );

      if (result) {
        places.add(placesList[i]);
      }
    }
    // Возвращаем список
    return places;
  }

  static bool checkFilter (
      PlaceCategory placeCategoryFromFilter,
      City cityFromFilter,
      bool nowIsOpenFromFilter,
      bool haveEventsFromFilter,
      bool havePromosFromFilter,
      Place place,
      //City cityFromPlace,
      //PlaceCategory categoryFromPlace
      ) {



    City cityFromPlace = City.getCityByIdFromList(place.city);
    PlaceCategory categoryFromPlace = PlaceCategory.getPlaceCategoryFromCategoriesList(place.category);

    bool category = placeCategoryFromFilter.id == '' || placeCategoryFromFilter.id == categoryFromPlace.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromPlace.id;
    bool checkNowIsOpen = nowIsOpenFromFilter == false ||  bool.parse(place.nowIsOpen!);
    bool events = haveEventsFromFilter == false || int.parse(place.eventsCount!) > 0;
    bool promos = havePromosFromFilter == false || int.parse(place.promoCount!) > 0;

    return category && city && checkNowIsOpen && events && promos;


  }

  static void sortPlaces(PlaceSortingOption sorting, List<Place> places) {

    switch (sorting){

      case PlaceSortingOption.nameAsc: places.sort((a, b) => a.name.compareTo(b.name)); break;

      case PlaceSortingOption.nameDesc: places.sort((a, b) => b.name.compareTo(a.name)); break;

      case PlaceSortingOption.promoCountAsc: places.sort((a, b) => int.parse(a.promoCount!).compareTo(int.parse(b.promoCount!))); break;

      case PlaceSortingOption.promoCountDesc: places.sort((a, b) => int.parse(b.promoCount!).compareTo(int.parse(a.promoCount!))); break;

      case PlaceSortingOption.eventCountAsc: places.sort((a, b) => int.parse(a.eventsCount!).compareTo(int.parse(b.eventsCount!))); break;

      case PlaceSortingOption.eventCountDesc: places.sort((a, b) => int.parse(b.eventsCount!).compareTo(int.parse(a.eventsCount!))); break;

      case PlaceSortingOption.favCountAsc: places.sort((a, b) => int.parse(a.addedToFavouritesCount!).compareTo(int.parse(b.addedToFavouritesCount!))); break;

      case PlaceSortingOption.favCountDesc: places.sort((a, b) => int.parse(b.addedToFavouritesCount!).compareTo(int.parse(a.addedToFavouritesCount!))); break;

    }

  }

  static Future<Place> getPlaceById(String placeId) async {

    Place returnedPlace = Place.empty();

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      Place place = Place.fromSnapshot(childSnapshot.child('place_info'));

      if (place.id == placeId) {

        returnedPlace = place;
        String favCount = await Place.getFavCount(place.id);
        String eventsCount = await Place.getEventsCount(place.id);
        String promosCount = await Place.getPromoCount(place.id);
        String inFav = await Place.addedInFavOrNot(place.id);
        String canEdit = await Place.canEditOrNot(place.id);
        bool nowIsOpenInPlace = nowIsOpenPlace(place);

        place.eventsList = await getEventsList(place.id);
        place.promosList = await getPromosList(place.id);
        place.nowIsOpen = nowIsOpenInPlace.toString();
        place.canEdit = canEdit;
        place.inFav = inFav;
        place.addedToFavouritesCount = favCount;
        place.eventsCount = eventsCount;
        place.promoCount = promosCount;


      }

    }

    // Возвращаем список
    return returnedPlace;
  }

  static Future<String> getFavCount(String placeId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/addedToFavourites');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }

  static Future<String> getEventsCount(String placeId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/events');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }

  static Future<String> getEventsList(String placeId) async {

    List<String> eventsList = [];

    String result = '';

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/events');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    for (var childSnapshot in snapshot.children) {
      // заполняем роль (RoleInApp.fromSnapshot) из снимка данных
      // и добавляем в список ролей

      DataSnapshot eventIdSnapshot = childSnapshot.child('eventId');

      if (eventIdSnapshot.exists) {
        eventsList.add(eventIdSnapshot.value.toString());
      }

    }

    for (int i = 0; i<eventsList.length; i++){
      if (i != eventsList.length - 1){
        result = '$result${eventsList[i]},';
      } else {
        result = '$result${eventsList[i]}';
      }
    }

    return result;

  }

  static Future<String> getPromosList(String placeId) async {

    List<String> promosList = [];

    String result = '';

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/promos');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    for (var childSnapshot in snapshot.children) {
      // заполняем роль (RoleInApp.fromSnapshot) из снимка данных
      // и добавляем в список ролей

      DataSnapshot eventIdSnapshot = childSnapshot.child('promoId');

      if (eventIdSnapshot.exists) {
        promosList.add(eventIdSnapshot.value.toString());
      }

    }

    for (int i = 0; i<promosList.length; i++){
      if (i != promosList.length - 1){
        result = '$result${promosList[i]},';
      } else {
        result = '$result${promosList[i]}';
      }
    }

    return result;

  }

  static Future<String> getPromoCount(String placeId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/promos');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }

  static Future<String> addedInFavOrNot(String placeId) async {

    String addedToFavourites = 'false';

    if (UserCustom.currentUser?.uid != null)
      {

        final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/addedToFavourites/${UserCustom.currentUser?.uid}');

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

  static Future<String> canEditOrNot(String placeId) async {

    String canEdit = 'false';

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/canEdit');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      if (childSnapshot.value == UserCustom.currentUser?.uid) canEdit = 'true';

    }

    return canEdit;

  }

  static Future<String> addPlaceToFav(String placeId) async {

    try {

      if (UserCustom.currentUser?.uid != null){
        String placePath = 'places/$placeId/addedToFavourites/${UserCustom.currentUser?.uid}';
        String userPath = 'users/${UserCustom.currentUser?.uid}/favPlaces/$placeId';

        // Записываем данные пользователя в базу данных
        await FirebaseDatabase.instance.ref().child(placePath).set({
          'userId': UserCustom.currentUser?.uid,
        });

        await FirebaseDatabase.instance.ref(userPath).set(
            {
              'placeId': placeId,
            }
        );

        addPlaceToCurrentFavList(placeId);

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

  static void deletePlaceFromCurrentFavList(String placeId){

    currentFavPlaceList.removeWhere((place) => place.id == placeId);

  }

  static void addPlaceToCurrentFavList(String placeId){

    for (var place in currentFeedPlaceList){
      if (place.id == placeId){
        currentFavPlaceList.add(place);
        break;
      }
    }
  }


  static void updateCurrentPlaceListFavInformation(String placeId, String favCounter, String inFav){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    for (int i = 0; i<currentFeedPlaceList.length; i++){
      // Если ID совпадает
      if (currentFeedPlaceList[i].id == placeId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentFeedPlaceList[i].addedToFavouritesCount = favCounter;
        currentFeedPlaceList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<currentFavPlaceList.length; i++){
      // Если ID совпадает
      if (currentFavPlaceList[i].id == placeId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentFavPlaceList[i].addedToFavouritesCount = favCounter;
        currentFavPlaceList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<currentMyPlaceList.length; i++){
      // Если ID совпадает
      if (currentMyPlaceList[i].id == placeId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentMyPlaceList[i].addedToFavouritesCount = favCounter;
        currentMyPlaceList[i].inFav = inFav;
        break;
      }
    }

  }

  static void deletePlaceFormCurrentPlaceLists(String placeId){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    currentFeedPlaceList.removeWhere((place) => place.id == placeId);
    currentFavPlaceList.removeWhere((place) => place.id == placeId);
    currentMyPlaceList.removeWhere((place) => place.id == placeId);
  }

  static Future<String> deletePlaceFromFav(String placeId) async {
    try {
      if (UserCustom.currentUser?.uid != null){
        DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/addedToFavourites').child(UserCustom.currentUser!.uid);

        // Проверяем, существует ли город с указанным ID
        DataSnapshot snapshot = await reference.get();
        if (!snapshot.exists) {
          return 'Пользователь не найден';
        }

        // Удаляем город
        await reference.remove();

        DatabaseReference referenceUser = FirebaseDatabase.instance.ref().child('users/${UserCustom.currentUser?.uid}/favPlaces').child(placeId);

        DataSnapshot snapshotUser = await referenceUser.get();
        if (!snapshotUser.exists) {
          return 'Заведение у пользователя не найдено';
        }

        // Удаляем город
        await referenceUser.remove();

      }

      deletePlaceFromCurrentFavList(placeId);

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> writeUserRoleInPlace(String placeId, String userId, String roleId) async {

    try {

      String placePath = 'places/$placeId/managers/$userId';
      String userPath = 'users/$userId/myPlaces/$placeId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).set({
        'userId': userId,
        'roleId': roleId,
      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(userPath).set({
        'placeId': placeId,
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

  static Future<String?> deleteUserRoleInPlace(String placeId, String userId) async {

    try {

      String placePath = 'places/$placeId/managers/$userId';
      String userPath = 'users/$userId/myPlaces/$placeId';

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

  static Future<Place> getPlaceFromList(String placeId) async {
    Place tempPlace = Place.emptyPlace;

    if (currentFeedPlaceList.isNotEmpty){
      for (Place place in currentFeedPlaceList){
        if (place.id == placeId){
          tempPlace = place;
          break;
        }
      }
    } else {
      tempPlace = await getPlaceById(placeId);
    }
    return tempPlace;
  }

}