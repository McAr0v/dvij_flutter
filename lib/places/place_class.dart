import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/constants/constants.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/events/event_class.dart';
import 'package:dvij_flutter/events/events_list_manager.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/promos/promos_list_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../database/database_mixin.dart';
import '../dates/date_mixin.dart';
import '../dates/time_mixin.dart';
import '../image_uploader/image_uploader.dart';
import '../interfaces/entity_interface.dart';
import '../users/place_user_class.dart';
import '../users/place_users_roles.dart';

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
  List<String> favUsersIds;
  bool inFav;
  bool nowIsOpen;
  List<String> eventsList;
  List<String> promosList;

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
    required this.favUsersIds,
    required this.inFav,
    required this.nowIsOpen,
    required this.eventsList,
    required this.promosList,

  });

  factory Place.fromSnapshot(DataSnapshot snapshot) {

    Place emptyPlace = Place.empty();

    DataSnapshot infoSnapshot = snapshot.child('place_info');
    DataSnapshot favSnapshot = snapshot.child('addedToFavourites');
    DataSnapshot eventsSnapshot = snapshot.child('events');
    DataSnapshot promosSnapshot = snapshot.child('promos');

    PlaceCategory placeCategory = PlaceCategory(name: '', id: infoSnapshot.child('category').value.toString());
    City city = City(name: '', id: infoSnapshot.child('city').value.toString());
    RegularDate openingHours = RegularDate();
    String openingHoursString = infoSnapshot.child('openingHours').value.toString();
    bool nowIsOpen = false;

    List<String> events = emptyPlace.getNeededIdsFromSnapshot(eventsSnapshot, 'eventId');
    List<String> promos = emptyPlace.getNeededIdsFromSnapshot(promosSnapshot, 'promoId');

    if (openingHoursString != ''){
      openingHours = openingHours.getFromJson(openingHoursString);
      nowIsOpen = openingHours.todayOrNot();
    }

    return Place(
      id: infoSnapshot.child('id').value.toString(),
      name: infoSnapshot.child('name').value.toString(),
      desc: infoSnapshot.child('desc').value.toString(),
      creatorId: infoSnapshot.child('creatorId').value.toString(),
      createDate: DateMixin.getDateFromString(infoSnapshot.child('createDate').value.toString()),
      category: placeCategory.getEntityByIdFromList(infoSnapshot.child('category').value.toString()),
      city: city.getEntityByIdFromList(infoSnapshot.child('city').value.toString()),
      street: infoSnapshot.child('street').value.toString(),
      house: infoSnapshot.child('house').value.toString(),
      phone: infoSnapshot.child('phone').value.toString(),
      whatsapp: infoSnapshot.child('whatsapp').value.toString(),
      telegram: infoSnapshot.child('telegram').value.toString(),
      instagram: infoSnapshot.child('instagram').value.toString(),
      imageUrl: infoSnapshot.child('imageUrl').value.toString(),
      openingHours: openingHours,
      nowIsOpen: nowIsOpen,
      inFav: emptyPlace.addedInFavOrNot(favSnapshot),
      favUsersIds: emptyPlace.getFavIdsList(favSnapshot),
      eventsList: events,
      promosList: promos,
    );
  }

  factory Place.empty(){
    return Place(
        id: '',
        name: '',
        desc: '',
        creatorId: '',
        createDate: DateTime(2100),
        category: PlaceCategory.empty,
        city: City.empty(),
        street: '',
        house: '',
        phone: '',
        whatsapp: '',
        telegram: '',
        instagram: '',
        imageUrl: AppConstants.defaultAvatar,
        openingHours: RegularDate(),
        favUsersIds: [],
        eventsList: [],
        promosList: [],
        nowIsOpen: false,
        inFav: false
    );
  }

  @override
  Future<String> publishToDb() async {


    // Задаем пути для публикации

    // -- Путь самого заведения ---
    String entityPath = 'places/$id/place_info';
    // -- Путь данных создателя ---
    String creatorPath = 'users/$creatorId/myPlaces/$id';

    // --- Генерируем словарь для публикации заведения в БД
    Map<String, dynamic> data = generateEntityDataCode();


    // Объявляем класс роли в заведении для генерации роли создателя
    PlaceUserRole creatorPlaceRole = PlaceUserRole();

    // --- Генерируем словарь для публикации данных создателя
    Map <String, dynamic> creatorDataToAdminsList = {
      'placeId': id,
      'roleId': creatorPlaceRole.generatePlaceRoleEnumForPlaceUser(PlaceUserRoleEnum.creator)
    };

    // --- Публикуем данные ----
    String entityPublishResult = await MixinDatabase.publishToDB(entityPath, data);
    String creatorPublishResult = await MixinDatabase.publishToDB(creatorPath, creatorDataToAdminsList);

    // TODO Может быть косяк, если редактирование - админу дастся доступ создателя! Проверить
    // Добавляем заведение в список моих заведений в пользователя
    // В нем по идее есть проверка - содержится ли это заведение уже в списке моих или нет
    if (UserCustom.currentUser != null){
      UserCustom.currentUser!.addPlaceToMy(id);
    }

    // Переменная для возвращения результата операции
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
  Future<List<String>> getNeededIdsFromDb(String folderPath, String fieldName) async {
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

  List<String> getNeededIdsFromSnapshot(DataSnapshot? snapshot, String fieldName) {
    List<String> list = [];

    if (snapshot != null){
      for (var neededFolder in snapshot.children){
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

    ImageUploader imageUploader = ImageUploader();
    PlaceUser placeUser = PlaceUser();

    // Путь самого заведения
    String entityPath = 'places/$id';
    // Путь создателя заведения
    String creatorPath = 'users/$creatorId/myPlaces/$id';

    await imageUploader.removeImage(ImageFolderEnum.places, id);

    // Удаляем мероприятия от имени заведения

    if (eventsList.isNotEmpty) {
      EventCustom emptyEvent = EventCustom.emptyEvent;
      for (String eventId in eventsList){
        EventCustom tempEvent = EventCustom.emptyEvent;
        if (EventListsManager.currentFeedEventsList.eventsList.isNotEmpty){
          tempEvent = emptyEvent.getEntityFromFeedList(eventId);
        } else {
          tempEvent = await emptyEvent.getEntityByIdFromDb(eventId);
        }

        await tempEvent.deleteFromDb();

       }
    }

    // Удаляем акции от имени заведения

    if (promosList.isNotEmpty) {
      PromoCustom emptyPromo = PromoCustom.emptyPromo;
      for (String promoId in promosList){
        PromoCustom tempPromo = PromoCustom.emptyPromo;
        if (PromoListsManager.currentFeedPromosList.promosList.isNotEmpty){
          tempPromo = emptyPromo.getEntityFromFeedList(promoId);
        } else {
          tempPromo = await emptyPromo.getEntityByIdFromDb(promoId);
        }

        await tempPromo.deleteFromDb();

      }
    }

    // Удаляем заведение
    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);

    // Удаляем запись у создателя
    await MixinDatabase.deleteFromDb(creatorPath);

    // Получаем список админов
    List<PlaceUser> admins = await placeUser.getAdminsFromDb(id);

    // Удаляем записи у админов
    for (PlaceUser adminUser in admins){
      String adminPath = 'users/${adminUser.uid}/myPlaces/$id';
      await MixinDatabase.deleteFromDb(adminPath);
    }

    // Удаляем записи у пользователей, добавивших в избранное
    for (String favUser in favUsersIds){
      String favUserPath = 'users/$favUser/favPlaces/$id';
      await MixinDatabase.deleteFromDb(favUserPath);
    }

    // Возвращаем результат удаления самого заведения
    return entityDeleteResult;
  }

  @override
  bool checkFilter(Map<String, dynamic> mapOfArguments) {

    PlaceCategory placeCategoryFromFilter = mapOfArguments['placeCategoryFromFilter'];
    City cityFromFilter = mapOfArguments['cityFromFilter'];
    bool haveEventsFromFilter = mapOfArguments['haveEventsFromFilter'];
    bool havePromosFromFilter = mapOfArguments['havePromosFromFilter'];
    bool nowIsOpenFromFilter = mapOfArguments['nowIsOpenFromFilter'];

    bool category = placeCategoryFromFilter.id == '' || placeCategoryFromFilter.id == this.category.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == this.city.id;
    bool checkNowIsOpen = nowIsOpenFromFilter == false ||  nowIsOpen;
    bool events = haveEventsFromFilter == false || eventsList.isNotEmpty;
    bool promos = havePromosFromFilter == false || promosList.isNotEmpty;

    return category && city && checkNowIsOpen && events && promos;
  }

  @override
  Future<Place> getEntityByIdFromDb(String entityId) async {
    Place returnedPlace = Place.empty();

    String path = 'places/$entityId';

    DataSnapshot? entitySnapshot = await MixinDatabase.getInfoFromDB(path);

    if (entitySnapshot != null && entitySnapshot.exists){
      return Place.fromSnapshot(entitySnapshot);
    }
    return returnedPlace;
  }

  @override
  Future<String> addToFav() async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String placePath = 'places/$id/addedToFavourites/${UserCustom.currentUser?.uid}';

      Map<String, dynamic> placeData = MixinDatabase.generateDataCode('userId', UserCustom.currentUser?.uid);

      String placePublish = await MixinDatabase.publishToDB(placePath, placeData);

      if (!favUsersIds.contains(UserCustom.currentUser!.uid)){
        favUsersIds.add(UserCustom.currentUser!.uid);
        inFav = true;
      }

      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
        updateCurrentEntityInEntitiesList();
      }

      String result = 'success';

      if (placePublish != 'success') result = placePublish;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  @override
  Future<String> deleteFromFav() async {

    if (UserCustom.currentUser?.uid != null && UserCustom.currentUser?.uid != ''){

      String placePath = 'places/$id/addedToFavourites/${UserCustom.currentUser?.uid}';

      String placeDelete = await MixinDatabase.deleteFromDb(placePath);

      if (favUsersIds.contains(UserCustom.currentUser!.uid)){
        favUsersIds.removeWhere((element) => element == UserCustom.currentUser?.uid);
        inFav = false;
      }

      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
        updateCurrentEntityInEntitiesList();
      }

      String result = 'success';

      if (placeDelete != 'success') result = placeDelete;

      return result;

    } else {
      return 'Пользователь не зарегистрирован';
    }
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> writeUserRoleInPlace(String placeId, String userId, String roleId) async {

    String userPath = 'users/$userId/myPlaces/$placeId';

    Map<String, dynamic> userData = {
      'placeId': placeId,
      'roleId': roleId,
    };

    String userRolePublish = await MixinDatabase.publishToDB(userPath, userData);

    return userRolePublish;

    /*try {

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
      return 'Failed to write user data. Error: $e';
    }*/
  }

  static Future<String?> deleteUserRoleInPlace(String placeId, String userId) async {

    String userPath = "users/$userId/myPlaces/$placeId";

    String userDelete = await MixinDatabase.deleteFromDb(userPath);

    return userDelete;

    /*try {

      String placePath = 'places/$placeId/managers/$userId';
      String userPath = 'users/$userId/myPlaces/$placeId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).remove();
      await FirebaseDatabase.instance.ref().child(userPath).remove();

      // Если успешно
      return 'success';

    } catch (e) {
      return 'Failed to write user data. Error: $e';
    }*/
  }

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
    placeList.updateCurrentListFavInformation(id, favUsersIds, inFav);
  }

  @override
  bool addedInFavOrNot(DataSnapshot? snapshot) {
    if (UserCustom.currentUser?.uid != null)
    {
      if (snapshot != null) {
        DataSnapshot idSnapshot = snapshot.child(UserCustom.currentUser!.uid).child('userId');
        if (idSnapshot.exists){
          if (idSnapshot.value.toString() == UserCustom.currentUser!.uid) return true;
        }
      }
    }

    return false;
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
  Place getEntityFromSnapshot(DataSnapshot snapshot) {
    Place returnedPlace = Place.empty();

    if (snapshot.exists){
      return Place.fromSnapshot(snapshot);
    }
    return returnedPlace;
  }

  List<DropdownMenuItem<PlaceSortingOption>> getPlaceSortingOptionsList(){
    return [
      const DropdownMenuItem(
        value: PlaceSortingOption.nameAsc,
        child: Text('По имени: А-Я'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.nameDesc,
        child: Text('По имени: Я-А'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.favCountAsc,
        child: Text('Менее популярные'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.favCountDesc,
        child: Text('Самые популярные'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.promoCountAsc,
        child: Text('Акции: по возрастанию'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.promoCountDesc,
        child: Text('Акции: по убыванию'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.eventCountAsc,
        child: Text('Мероприятия: по возрастанию'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.eventCountDesc,
        child: Text('Мероприятия: по убыванию'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.createDateAsc,
        child: Text('Сначала старые'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.createDateDesc,
        child: Text('Сначала новые'),
      ),
    ];
  }

  @override
  void updateCurrentEntityInEntitiesList() {
    PlaceList placeList = PlaceList();
    placeList.updateCurrentEntityInEntitiesList(this);
  }

}