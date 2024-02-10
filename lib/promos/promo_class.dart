import 'package:dvij_flutter/cities/city_class.dart';
import 'package:dvij_flutter/classes/date_type_enum.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/promos/promo_sorting_options.dart';
import 'package:dvij_flutter/classes/user_class.dart';
import 'package:dvij_flutter/methods/days_functions.dart';
import 'package:firebase_database/firebase_database.dart';

import '../methods/date_functions.dart';
import '../events/event_category_class.dart';
import '../events/event_sorting_options.dart';

class PromoCustom {
  String id;
  String promoType;
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
  String onceDay;
  String longDays;
  String regularDays;
  String irregularDays;
  String? addedToFavouritesCount;
  String? canEdit;
  String? inFav;
  String? today;

  PromoCustom({
    required this.id,
    required this.promoType,
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
    this.addedToFavouritesCount,
    this.canEdit,
    this.inFav,
    this.today,

  });

  factory PromoCustom.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot promoTypeSnapshot = snapshot.child('promoType');
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

    return PromoCustom(
        id: idSnapshot.value.toString() ?? '',
        promoType: promoTypeSnapshot.value.toString() ?? '',
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
        onceDay: onceDayDateSnapshot.value.toString() ?? '',
        longDays: longDaysSnapshot.value.toString() ?? '',
        regularDays: regularDaysSnapshot.value.toString() ?? '',
        irregularDays: irregularDaysSnapshot.value.toString() ?? ''

    );
  }

  static List<PromoCustom> currentFeedPromoList = [];
  static List<PromoCustom> currentFavPromoList = [];
  static List<PromoCustom> currentMyPromoList = [];

  static PromoCustom emptyPromo = PromoCustom(
      id: '',
      promoType: '',
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
      onceDay: '',
      longDays: '',
      regularDays: '',
      irregularDays: ''

  );

  factory PromoCustom.empty() {
    return PromoCustom(
        id: '',
        promoType: '',
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
  static Future<String?> createOrEditPromo(PromoCustom promo) async {

    try {

      String promoPath = 'promos/${promo.id}/promo_info';
      String creatorPath = 'users/${promo.creatorId}/myPromos/${promo.id}';
      String placePath = 'places/${promo.placeId}/promos/${promo.id}';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(promoPath).set({
        'id': promo.id,
        'promoType': promo.promoType,
        'headline': promo.headline,
        'desc': promo.desc,
        'creatorId': promo.creatorId,
        'createDate': promo.createDate,
        'category': promo.category,
        'city': promo.city,
        'street': promo.street,
        'house': promo.house,
        'phone': promo.phone,
        'whatsapp': promo.whatsapp,
        'telegram': promo.telegram,
        'instagram': promo.instagram,
        'imageUrl': promo.imageUrl,
        'placeId': promo.placeId ?? '',
        'onceDay': promo.onceDay,
        'longDays': promo.longDays,
        'regularDays': promo.regularDays,
        'irregularDays': promo.irregularDays,

      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(creatorPath).set({
        'promoId': promo.id,
        //'roleId': '-NngrYovmKAw_cp0pYfJ'
      });

      if (promo.placeId != '') {
        await FirebaseDatabase.instance.ref().child(placePath).set(
            {
              'promoId': promo.id,
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

  static Future<String> deletePromo(
      String promoId,
      // List<UserCustom> users, Восстановить если надо добавлять других пользователей
      String creatorId,
      String placeId
      ) async {
    try {

      DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos').child(promoId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Акция не найдена';
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
        DatabaseReference userReference = FirebaseDatabase.instance.ref().child('users').child(creatorId).child('myPromos').child(promoId);

        await userReference.remove();
      }

      if (placeId != '') {
        await PromoCustom.deletePromoIdFromPlace(promoId, placeId);
      }



      // TODO По хорошему надо удалять и акции

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении акции: $error';
    }
  }

  static Future<String> deletePromoIdFromPlace(
      String promoId,
      // List<UserCustom> users, Восстановить если надо добавлять других пользователей
      String placeId
      ) async {
    try {

      DatabaseReference reference = FirebaseDatabase.instance.ref().child('places/$placeId/promos').child(promoId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Акция не найдена';
      }

      // Удаляем место
      await reference.remove();

      return 'success';

    } catch (error) {
      return '$error';
    }
  }

  static Future<List<PromoCustom>> getAllPromos() async {

    List<PromoCustom> promos = [];
    currentFeedPromoList = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      PromoCustom promo = PromoCustom.fromSnapshot(childSnapshot.child('promo_info'));

      String favCount = await PromoCustom.getFavCount(promo.id);
      String inFav = await PromoCustom.addedInFavOrNot(promo.id);
      //bool fromPlace = eventFromPlace(event.placeId);

      promo.inFav = inFav;
      promo.addedToFavouritesCount = favCount;
      promo.today = todayPromoOrNot(promo).toString();

      currentFeedPromoList.add(promo);

      promos.add(promo);

    }

    // Возвращаем список
    return promos;
  }

  /*static bool eventFromPlace (String placeId) {
    return placeId != '';
  }*/

  static Future<List<PromoCustom>> getFavPromos(String userId) async {

    List<PromoCustom> promos = [];
    currentFavPromoList = [];
    List<String> promosId = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users/$userId/favPromos/');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      DataSnapshot idSnapshot = childSnapshot.child('promoId');

      if (idSnapshot.exists){
        promosId.add(idSnapshot.value.toString());
      }
    }

    if (promosId.isNotEmpty){

      for (var promo in promosId){

        PromoCustom temp = await getPromoById(promo);

        if (temp.id != ''){
          currentFavPromoList.add(temp);
          promos.add(temp);
        }

      }

    }
    // Возвращаем список
    return promos;
  }

  static Future<List<PromoCustom>> getMyPromos(String userId) async {

    List<PromoCustom> promos = [];
    currentMyPromoList = [];
    List<String> promosId = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('users/$userId/myPromos/');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      DataSnapshot idSnapshot = childSnapshot.child('promoId');

      if (idSnapshot.exists){
        promosId.add(idSnapshot.value.toString());
      }
    }

    if (promosId.isNotEmpty){

      for (var promo in promosId){

        PromoCustom temp = await getPromoById(promo);

        if (temp.id != ''){
          currentMyPromoList.add(temp);
          promos.add(temp);
        }

      }

    }
    // Возвращаем список
    return promos;
  }


  static List<PromoCustom> filterPromos(
      PromoCategory promoCategoryFromFilter,
      City cityFromFilter,
      bool today,
      bool onlyFromPlacePromos,
      List<PromoCustom> promosList,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    List<PromoCustom> promos = [];

    for (int i = 0; i<promosList.length; i++){

      bool result = checkFilter(
          promoCategoryFromFilter,
          cityFromFilter,
          today,
          onlyFromPlacePromos,
          promosList[i],
          selectedStartDatePeriod,
          selectedEndDatePeriod
      );

      if (result) {
        promos.add(promosList[i]);
      }
    }
    // Возвращаем список
    return promos;
  }

  static bool checkFilter (
      PromoCategory promoCategoryFromFilter,
      City cityFromFilter,
      bool today,
      bool onlyFromPlacePromos,
      PromoCustom promo,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod,
      ) {

    City cityFromEvent = City.getCityByIdFromList(promo.city);
    EventCategory categoryFromEvent = EventCategory.getEventCategoryFromCategoriesList(promo.category);

    bool category = promoCategoryFromFilter.id == '' || promoCategoryFromFilter.id == categoryFromEvent.id;
    bool city = cityFromFilter.id == '' || cityFromFilter.id == cityFromEvent.id;
    bool checkToday = today == false || bool.parse(promo.today!) == true;
    bool checkFromPlaceEvent = onlyFromPlacePromos == false || promo.placeId != '';
    bool checkDate = selectedStartDatePeriod == DateTime(2100) || checkPromosDatesForFilter(promo, selectedStartDatePeriod, selectedEndDatePeriod);

    return category && city && checkToday && checkFromPlaceEvent && checkDate;


  }


  static void sortPromos(PromoSortingOption sorting, List<PromoCustom> events) {

    switch (sorting){

      case PromoSortingOption.nameAsc: events.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case PromoSortingOption.nameDesc: events.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case PromoSortingOption.favCountAsc: events.sort((a, b) => int.parse(a.addedToFavouritesCount!).compareTo(int.parse(b.addedToFavouritesCount!))); break;

      case PromoSortingOption.favCountDesc: events.sort((a, b) => int.parse(b.addedToFavouritesCount!).compareTo(int.parse(a.addedToFavouritesCount!))); break;

    }

  }



  static Future<PromoCustom> getPromoById(String promoId) async {

    PromoCustom returnedPromo = PromoCustom.empty();

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      PromoCustom promo = PromoCustom.fromSnapshot(childSnapshot.child('promo_info'));

      if (promo.id == promoId) {

        returnedPromo = promo;
        String favCount = await PromoCustom.getFavCount(promo.id);
        String inFav = await PromoCustom.addedInFavOrNot(promo.id);
        String canEdit = await PromoCustom.canEditOrNot(promo.id);
        promo.canEdit = canEdit;
        promo.inFav = inFav;
        promo.addedToFavouritesCount = favCount;
        promo.today = todayPromoOrNot(promo).toString();
      }
    }

    // Возвращаем список
    return returnedPromo;
  }



  static Future<String> getFavCount(String promoId) async {

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos/$promoId/addedToFavourites');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    return snapshot.children.length.toString();

  }

  static Future<String> addedInFavOrNot(String promoId) async {

    String addedToFavourites = 'false';

    if (UserCustom.currentUser?.uid != null)
    {

      final DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos/$promoId/addedToFavourites/${UserCustom.currentUser?.uid}');

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

  static Future<String> canEditOrNot(String promoId) async {

    String canEdit = 'false';

    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos/$promoId/canEdit');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      if (childSnapshot.value == UserCustom.currentUser?.uid) canEdit = 'true';

    }

    return canEdit;

  }

  static Future<String> addPromoToFav(String promoId) async {

    try {

      if (UserCustom.currentUser?.uid != null){
        String promoPath = 'promos/$promoId/addedToFavourites/${UserCustom.currentUser?.uid}';
        String userPath = 'users/${UserCustom.currentUser?.uid}/favPromos/$promoId';

        // Записываем данные пользователя в базу данных
        await FirebaseDatabase.instance.ref().child(promoPath).set({
          'userId': UserCustom.currentUser?.uid,
        });

        await FirebaseDatabase.instance.ref(userPath).set(
            {
              'promoId': promoId,
            }
        );

        addPromoToCurrentFavList(promoId);

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

  static void deletePromoFromCurrentFavList(String promoId){

    currentFavPromoList.removeWhere((promo) => promo.id == promoId);

  }

  static void addPromoToCurrentFavList(String promoId){

    for (var promo in currentFeedPromoList){
      if (promo.id == promoId){
        currentFavPromoList.add(promo);
        break;
      }
    }
  }


  static void updateCurrentPromoListFavInformation(String promoId, String favCounter, String inFav){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    for (int i = 0; i<currentFeedPromoList.length; i++){
      // Если ID совпадает
      if (currentFeedPromoList[i].id == promoId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentFeedPromoList[i].addedToFavouritesCount = favCounter;
        currentFeedPromoList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<currentFavPromoList.length; i++){
      // Если ID совпадает
      if (currentFavPromoList[i].id == promoId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentFavPromoList[i].addedToFavouritesCount = favCounter;
        currentFavPromoList[i].inFav = inFav;
        break;
      }
    }

    for (int i = 0; i<currentMyPromoList.length; i++){
      // Если ID совпадает
      if (currentMyPromoList[i].id == promoId){
        // Обновляем данные об состоянии этого заведения как избранного
        currentMyPromoList[i].addedToFavouritesCount = favCounter;
        currentMyPromoList[i].inFav = inFav;
        break;
      }
    }

  }

  static void deletePromoFromCurrentPromoLists(String promoId){
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    currentFeedPromoList.removeWhere((promo) => promo.id == promoId);
    currentFavPromoList.removeWhere((promo) => promo.id == promoId);
    currentMyPromoList.removeWhere((promo) => promo.id == promoId);
  }

  static Future<String> deletePromoFromFav(String promoId) async {
    try {
      if (UserCustom.currentUser?.uid != null){
        DatabaseReference reference = FirebaseDatabase.instance.ref().child('promos/$promoId/addedToFavourites').child(UserCustom.currentUser!.uid);

        // Проверяем, существует ли город с указанным ID
        DataSnapshot snapshot = await reference.get();
        if (!snapshot.exists) {
          return 'Пользователь не найден';
        }

        // Удаляем город
        await reference.remove();

        DatabaseReference referenceUser = FirebaseDatabase.instance.ref().child('users/${UserCustom.currentUser?.uid}/favPromos').child(promoId);

        DataSnapshot snapshotUser = await referenceUser.get();
        if (!snapshotUser.exists) {
          return 'Акция у пользователя не найдена';
        }

        // Удаляем город
        await referenceUser.remove();

      }

      deletePromoFromCurrentFavList(promoId);

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> writeUserRoleInPromo(String promoId, String userId, String roleId) async {

    try {

      String placePath = 'promos/$promoId/managers/$userId';
      String userPath = 'users/$userId/myPromos/$promoId';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).set({
        'userId': userId,
        'roleId': roleId,
      });

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(userPath).set({
        'eventId': promoId,
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

  static Future<String?> deleteUserRoleInPromo(String promoId, String userId) async {

    try {

      String placePath = 'promos/$promoId/managers/$userId';
      String userPath = 'users/$userId/myPromos/$promoId';

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

  static DateTypeEnum getPromoTypeEnum (String promoType) {
    switch (promoType){

      case 'once': return DateTypeEnum.once;
      case 'long': return DateTypeEnum.long;
      case 'regular': return DateTypeEnum.regular;
      case 'irregular': return DateTypeEnum.irregular;
      default: return DateTypeEnum.once;

    }
  }

  static Future<List<PromoCustom>> getPromosList(String promosListInString, {String decimal = ','}) async {
    List<PromoCustom> tempList = [];

    List<String> splittedString = promosListInString.split(decimal);

    for (int i = 0; i < splittedString.length; i++){
      PromoCustom tempPromo = getPromoFromFeedList(splittedString[i]);

      if (tempPromo.id != ''){
        tempList.add(tempPromo);
      } else {
        tempPromo = await getPromoById(splittedString[i]);
        if (tempPromo.id != ''){
          tempList.add(tempPromo);
        }
      }
    }

    return tempList;

  }

  static PromoCustom getPromoFromFeedList (String promoId){

    PromoCustom result = PromoCustom.emptyPromo;

    if (currentFeedPromoList.isNotEmpty){
      for (int i = 0; i < currentFeedPromoList.length; i++ )
      {
        if (currentFeedPromoList[i].id == promoId) {
          return currentFeedPromoList[i];
        }
      }
    }

    return result;

  }

}