import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_mixin.dart';
import '../dates/date_mixin.dart';
import '../dates/time_mixin.dart';
import '../interfaces/entity_interface.dart';

class Place with MixinDatabase, TimeMixin implements IEntity<Place> {
  String id;
  String name;
  String desc;
  String creatorId;
  DateTime createDate;
  PlaceCategory category;
  City city;
  String street;
  String house;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String imageUrl;
  RegularDate openingHours;
  int? addedToFavouritesCount;
  int? eventsCount;
  int? promoCount;
  bool? canEdit;
  bool? inFav;
  bool? nowIsOpen;
  List<String>? eventsList;
  List<String>? promosList;

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
    required this.openingHours,
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
    PlaceCategory placeCategory = PlaceCategory(name: '', id: snapshot.child('category').value.toString());
    City city = City(name: '', id: snapshot.child('city').value.toString());
    RegularDate openingHours = RegularDate();
    String openingHoursString = snapshot.child('openingHours').value.toString();
    bool nowIsOpen = false;

    if (openingHoursString != ''){
      openingHours = openingHours.getFromJson(openingHoursString);
      nowIsOpen = openingHours.todayOrNot();
    }

    return Place(
      id: snapshot.child('id').value.toString(),
      name: snapshot.child('name').value.toString(),
      desc: snapshot.child('desc').value.toString(),
      creatorId: snapshot.child('creatorId').value.toString(),
      createDate: DateMixin.getDateFromString(snapshot.child('createDate').value.toString()),
      category: placeCategory.getEntityByIdFromList(snapshot.child('category').value.toString()),
      city: city.getEntityByIdFromList(snapshot.child('city').value.toString()),
      street: snapshot.child('street').value.toString(),
      house: snapshot.child('house').value.toString(),
      phone: snapshot.child('phone').value.toString(),
      whatsapp: snapshot.child('whatsapp').value.toString(),
      telegram: snapshot.child('telegram').value.toString(),
      instagram: snapshot.child('instagram').value.toString(),
      imageUrl: snapshot.child('imageUrl').value.toString(),
      openingHours: openingHours,
      nowIsOpen: nowIsOpen
    );
  }

  /// Переменная пустого [Place]
  static Place emptyPlace = Place(
      id: '',
      name: '',
      desc: '',
      creatorId: '',
      createDate: DateTime(2100),
      category: PlaceCategory.empty,
      city: City.emptyCity,
      street: '',
      house: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
      openingHours: RegularDate(),
  );

  @override
  Future<String> publishToDb() async {
    String entityPath = 'places/$id/place_info';
    String creatorPath = 'users/$creatorId/myPlaces/$id';

    Map<String, dynamic> data = generateEntityDataCode();
    Map<String, dynamic> dataToCreatorAndPlace = {
      'placeId': id,
      'roleId': '-NngrYovmKAw_cp0pYfJ'
    };

    String entityPublishResult = await MixinDatabase.publishToDB(entityPath, data);
    String creatorPublishResult = await MixinDatabase.publishToDB(creatorPath, dataToCreatorAndPlace);

    String result = 'success';

    if (entityPublishResult != 'success') result = entityPublishResult;
    if (creatorPublishResult != 'success') result = creatorPublishResult;

    return result;

  }

  /// Функция получения списка нужных ID
  /// <br><br>
  /// Нужна для удаления записей у админов при удалении заведения, получения списка мероприятий и тд
  /// <br><br>
  /// [folderPath] - Путь до папки с нужными Id (например: places/$id/managers)
  /// <br>
  /// [fieldName] - Название поля с нужным Id (например: userId)
  Future<List<String>> getNeededIds(String folderPath, String fieldName) async {
    List<String> list = [];

    DataSnapshot? foldersSnapshot = await MixinDatabase.getInfoFromDB(folderPath);

    if (foldersSnapshot != null){
      for (var neededFolder in foldersSnapshot.children){
        if (neededFolder.exists){
          String entity = neededFolder.child(fieldName).value.toString();
          list.add(entity);
        }
      }
    }

    return list;

  }

  @override
  Future<String> deleteFromDb() async {
    // Путь самого заведения
    String entityPath = 'places/$id';
    // Путь создателя заведения
    String creatorPath = 'users/$creatorId/myPromos/$id';

    // Получаем списки админов заведения
    List<String> adminsList = await getNeededIds('places/$id/managers', 'userId');
    // Получаем списки добавивших заведение в избранное
    // TODO - сделать такое же удаление добавивших в изрбанное, как в заведениях, в мероприятиях и акциях
    List<String> favUsersList = await getNeededIds('places/$id/addedToFavourites', 'userId');

    // TODO По хорошему надо удалять и мероприятия и акции из удаляемых заведений

    // Удаляем заведение
    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);
    // Удаляем запись у создателя
    String creatorDeleteResult = await MixinDatabase.deleteFromDb(creatorPath);

    // Удаляем записи у админов
    for (String admin in adminsList){
      String adminPath = 'users/$admin/myPlaces/$id';
      String deleteAdminResult = await MixinDatabase.deleteFromDb(adminPath);
    }

    // Удаляем записи у пользователей, добавивших в избранное
    for (String favUser in favUsersList){
      String favUserPath = 'users/$favUser/favPlaces/$id';
      String deleteAdminResult = await MixinDatabase.deleteFromDb(favUserPath);
    }

    // Возвращаем результат удаления самого заведения
    return entityDeleteResult;
  }
  /*static List<Place> filterPlaces(
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
  }*/



  @override
  bool checkFilter(Map<String, dynamic> mapOfArguments) {

    PlaceCategory placeCategoryFromFilter = mapOfArguments['placeCategoryFromFilter'];
    City cityFromFilter = mapOfArguments['cityFromFilter'];
    bool haveEventsFromFilter = mapOfArguments['haveEventsFromFilter'];
    bool havePromosFromFilter = mapOfArguments['havePromosFromFilter'];
    bool nowIsOpenFromFilter = mapOfArguments['nowIsOpenFromFilter'];

    bool category = placeCategoryFromFilter.id == '' || placeCategoryFromFilter.id == this.category.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == this.city.id;
    bool checkNowIsOpen = nowIsOpenFromFilter == false ||  nowIsOpen!;
    bool events = haveEventsFromFilter == false || eventsCount! > 0;
    bool promos = havePromosFromFilter == false || promoCount! > 0;

    return category && city && checkNowIsOpen && events && promos;
  }

  @override
  Future<Place> getEntityByIdFromDb(String entityId) async {
    Place returnedPlace = Place.emptyPlace;

    String path = 'places/$entityId/place_info';

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(path);

    if (snapshot != null){
      Place place = Place.fromSnapshot(snapshot);
      place.inFav = await place.addedInFavOrNot();
      place.addedToFavouritesCount = await place.getFavCount();
      place.eventsList = await place.getNeededIds('places/${place.id}/events/', 'eventId');
      place.promosList = await place.getNeededIds('places/${place.id}/promos/', 'promoId');
      place.eventsCount = place.eventsList?.length;
      place.promoCount = place.promosList?.length;
      // TODO - разработать функционал CanEdit для заведений

      returnedPlace = place;
    }
    // Возвращаем список
    return returnedPlace;
  }

  /*static Future<String> getFavCount(String placeId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/addedToFavourites');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }*/

  /*static Future<String> getEventsCount(String placeId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/events');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }*/

  /*static Future<String> getEventsList(String placeId) async {

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

  }*/

  /*static Future<String> getPromosList(String placeId) async {

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

  }*/

  /*static Future<String> addedInFavOrNot(String placeId) async {

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

  }*/

  /*static Future<String> canEditOrNot(String placeId) async {

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

  }*/

  @override
  Future<String> addToFav() async {
    PlaceList favPlaces = PlaceList();

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String placePath = 'places/$id/addedToFavourites/${UserCustom.currentUser?.uid}';
      String userPath = 'users/${UserCustom.currentUser?.uid}/favPlaces/$id';

      Map<String, dynamic> placeData = MixinDatabase.generateDataCode('userId', UserCustom.currentUser?.uid);
      Map<String, dynamic> userData = MixinDatabase.generateDataCode('placeId', id);

      String placePublish = await MixinDatabase.publishToDB(placePath, placeData);
      String userPublish = await MixinDatabase.publishToDB(userPath, userData);

      favPlaces.addEntityToCurrentFavList(id);

      String result = 'success';

      if (placePublish != 'success') result = placePublish;
      if (userPublish != 'success') result = userPublish;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  @override
  Future<String> deleteFromFav() async {
    PlaceList favPLaces = PlaceList();

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String eventPath = 'places/$id/addedToFavourites/${UserCustom.currentUser?.uid}';
      String userPath = 'users/${UserCustom.currentUser?.uid}/favPlaces/$id';

      String eventDelete = await MixinDatabase.deleteFromDb(eventPath);
      String userDelete = await MixinDatabase.deleteFromDb(userPath);

      favPLaces.deleteEntityFromCurrentFavList(id);

      String result = 'success';

      if (eventDelete != 'success') result = eventDelete;
      if (userDelete != 'success') result = userDelete;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  /*static void deletePlaceFromCurrentFavList(String placeId){

    currentFavPlaceList.removeWhere((place) => place.id == placeId);

  }

  static void addPlaceToCurrentFavList(String placeId){

    for (var place in currentFeedPlaceList){
      if (place.id == placeId){
        currentFavPlaceList.add(place);
        break;
      }
    }
  }*/


  /*static void updateCurrentPlaceListFavInformation(String placeId, String favCounter, String inFav){
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

  }*/

  /*static void deletePlaceFormCurrentPlaceLists(String placeId){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    currentFeedPlaceList.removeWhere((place) => place.id == placeId);
    currentFavPlaceList.removeWhere((place) => place.id == placeId);
    currentMyPlaceList.removeWhere((place) => place.id == placeId);
  }*/



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

  /*static Future<Place> getPlaceFromList(String placeId) async {
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
  }*/



  @override
  Future<String> deleteEntityIdFromPlace(String placeId) {
    Future<String> result = 'Эта функция не используется в заведениях' as Future<String>;
    return result;
  }

  @override
  Map<String, dynamic> generateEntityDataCode() {

    return <String, dynamic> {
      'id': id,
      'name': name,
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
      'openingHours': openingHours.generateDateStingForDb(),
    };
  }



  @override
  Place getEntityFromFeedList(String id) {
    PlaceList placeList = PlaceList();
    return placeList.getEntityFromFeedListById(id);
  }

  @override
  void deleteEntityFromCurrentEntityLists() {
    PlaceList placeList = PlaceList();
    placeList.deleteEntityFromCurrentEntitiesLists(id);
  }

  @override
  void addEntityToCurrentEntitiesLists() {
    PlaceList placeList = PlaceList();
    placeList.addEntityFromCurrentEntitiesLists(this);
  }

  @override
  void updateCurrentListFavInformation() {
    PlaceList placeList = PlaceList();
    placeList.updateCurrentListFavInformation(id, addedToFavouritesCount!, inFav!);
  }

  @override
  Future<bool> addedInFavOrNot() async {
    if (UserCustom.currentUser?.uid != null)
    {
      DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('places/$id/addedToFavourites/${UserCustom.currentUser?.uid}');

      if (snapshot != null){
        for (var childSnapshot in snapshot.children) {
          if (childSnapshot.value == UserCustom.currentUser?.uid) return true;
        }
      }
    }

    return false;
  }

  @override
  Future<int> getFavCount() async {
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('places/$id/addedToFavourites');

    if (snapshot != null) {
      return snapshot.children.length;
    } else {
      return 0;
    }
  }

}