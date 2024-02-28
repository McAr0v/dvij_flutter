import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../database/database_mixin.dart';
import '../dates/date_mixin.dart';
import '../dates/time_mixin.dart';
import '../interfaces/entity_interface.dart';
import '../users/place_admins_item_class.dart';
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
  int? addedToFavouritesCount;
  int? eventsCount;
  int? promoCount;
  bool? inFav;
  bool? nowIsOpen;
  List<String>? eventsList;
  List<String>? promosList;
  List<PlaceAdminsListItem>? admins;

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
    this.eventsCount,
    this.inFav,
    this.promoCount,
    this.nowIsOpen,
    this.eventsList,
    this.promosList,
    this.admins

  });

  factory Place.fromSnapshot(DataSnapshot snapshot) {
    DataSnapshot infoSnapshot = snapshot.child('place_info');
    DataSnapshot favSnapshot = snapshot.child('addedToFavourites');
    DataSnapshot eventsSnapshot = snapshot.child('events');
    DataSnapshot promosSnapshot = snapshot.child('promos');
    DataSnapshot managersSnapshot = snapshot.child('managers');


    PlaceCategory placeCategory = PlaceCategory(name: '', id: infoSnapshot.child('category').value.toString());
    City city = City(name: '', id: infoSnapshot.child('city').value.toString());
    RegularDate openingHours = RegularDate();
    String openingHoursString = infoSnapshot.child('openingHours').value.toString();
    bool nowIsOpen = false;

    List<String> events = emptyPlace.getNeededIdsFromSnapshot(eventsSnapshot, 'eventId');
    List<String> promos = emptyPlace.getNeededIdsFromSnapshot(promosSnapshot, 'promoId');
    List<PlaceAdminsListItem> adminsList = [];

    if (openingHoursString != ''){
      openingHours = openingHours.getFromJson(openingHoursString);
      nowIsOpen = openingHours.todayOrNot();
    }

    for (var idFolder in managersSnapshot.children){
      PlaceAdminsListItem tempAdmin = PlaceAdminsListItem();
      PlaceUserRole tempRole = PlaceUserRole();
      tempAdmin.userId = idFolder.child('userId').value.toString();
      tempAdmin.placeRole = tempRole.getPlaceUserRole(tempRole.getPlaceUserEnumFromString(idFolder.child('roleId').value.toString()));
      adminsList.add(tempAdmin);
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
      addedToFavouritesCount: emptyPlace.getFavCount(favSnapshot),
      eventsList: events,
      promosList: promos,
      eventsCount: events.length,
      promoCount: promos.length,
      admins: adminsList

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
    // Путь самого заведения
    String entityPath = 'places/$id';
    // Путь создателя заведения
    String creatorPath = 'users/$creatorId/myPromos/$id';

    // Получаем списки добавивших заведение в избранное
    // TODO - сделать такое же удаление добавивших в изрбанное, как в заведениях, в мероприятиях и акциях
    List<String> favUsersList = await getNeededIds('places/$id/addedToFavourites', 'userId');

    // TODO По хорошему надо удалять и мероприятия и акции из удаляемых заведений

    // Удаляем заведение
    String entityDeleteResult = await MixinDatabase.deleteFromDb(entityPath);
    // Удаляем запись у создателя
    String creatorDeleteResult = await MixinDatabase.deleteFromDb(creatorPath);

    // Удаляем записи у админов
    for (PlaceAdminsListItem admin in admins!){
      String adminPath = 'users/${admin.userId}/myPlaces/$id';
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

    String path = 'places/$entityId';

    DataSnapshot? entitySnapshot = await MixinDatabase.getInfoFromDB(path);

    if (entitySnapshot != null){
      return Place.fromSnapshot(entitySnapshot);
    }
    return returnedPlace;
  }


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
      return 'Failed to write user data. Error: $e';
    }
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
    placeList.updateCurrentListFavInformation(id, addedToFavouritesCount!, inFav!);
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
  int getFavCount(DataSnapshot snapshot) {
    if (snapshot.exists) {
      return snapshot.children.length;
    } else {
      return 0;
    }
  }

  @override
  Place getEntityFromSnapshot(DataSnapshot snapshot) {
    Place returnedPlace = Place.emptyPlace;

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
        child: Text('В избранном: по возрастанию'),
      ),
      const DropdownMenuItem(
        value: PlaceSortingOption.favCountDesc,
        child: Text('В избранном: по убыванию'),
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
    ];
  }

}