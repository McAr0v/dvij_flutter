import 'package:dvij_flutter/interfaces/lists_interface.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/promos/promo_sorting_options.dart';
import 'package:dvij_flutter/promos/promos_list_manager.dart';
import 'package:firebase_database/firebase_database.dart';
import '../cities/city_class.dart';
import '../current_user/user_class.dart';
import '../database/database_mixin.dart';
import '../places/users_my_place/my_places_class.dart';
import '../users/place_users_roles.dart';

class PromoList implements ILists<PromoList, PromoCustom, PromoSortingOption>{
  List<PromoCustom> promosList = [];

  PromoList({List<PromoCustom>? promosList}){
    this.promosList = promosList ?? this.promosList;
  }

  @override
  String toString() {
    if (promosList.isEmpty){
      return 'Список акций пуст';
    } else {
      String result = '';
      for (PromoCustom promo in promosList){
        result = '$result${promo.id} - ${promo.headline}, ';
      }
      return result;
    }
  }

  @override
  Future<PromoList> getListFromDb() async {
    PromoList promos = PromoList();
    PromoListsManager.currentFeedPromosList = PromoList();

    DataSnapshot? promosSnapshot = await MixinDatabase.getInfoFromDB('promos');

    if (promosSnapshot != null) {
      for (var promoIdsFolder in promosSnapshot.children) {

        PromoCustom promo = PromoCustom.emptyPromo.getEntityFromSnapshot(promoIdsFolder);

        PromoListsManager.currentFeedPromosList.promosList.add(promo);
        promos.promosList.add(promo);

      }
    }
    return promos;
  }

  @override
  Future<PromoList> getFavListFromDb(String userId, {bool refresh = false}) async {
    PromoList promos = PromoList();
    PromoListsManager.currentFavPromoList = PromoList();

    PromoList downloadedPromosList = PromoListsManager.currentFeedPromosList;

    if (downloadedPromosList.promosList.isEmpty || refresh) {
      PromoList tempList = await getListFromDb();
      downloadedPromosList = tempList;
    }

    for (PromoCustom promo in downloadedPromosList.promosList){
      if (promo.favUsersIds.contains(userId)){
        promos.promosList.add(promo);
      }
    }


    /*



    EventsList downloadedEventsList = EventListsManager.currentFeedEventsList;

    if (downloadedEventsList.eventsList.isEmpty || refresh) {
      EventsList tempList = await getListFromDb();
      downloadedEventsList = tempList;
    }

    for (EventCustom event in downloadedEventsList.eventsList){
      if (event.favUsersIds.contains(userId)){
        events.eventsList.add(event);
      }
    }

     */

    // TODO !!! Сделать загрузку списка избранного при загрузке информации пользователя. Здесь обращаться к уже готовому списку
    // TODO !!! Не забыть реализовать обновление списка избранных при добавлении и удалении из избранных

    // --- Читаем папку избранных сущностей у пользователя ----

    /*String favPath = 'users/$userId/favPromos/';
    DataSnapshot? favFolder = await MixinDatabase.getInfoFromDB(favPath);

    if (favFolder != null) {
      for (var idFolder in favFolder.children) {

        DataSnapshot idSnapshot = idFolder.child('promoId');

        // ---- Считываем ID и добавляем в список ID
        if (idSnapshot.exists){
          promosId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список ID не пустой

    if (promosId.isNotEmpty){

      // Если список всей ленты не пустой и не была вызвана функция обновления, то будем забирать данные из него
      if (PromoListsManager.currentFeedPromosList.promosList.isNotEmpty && !refresh){

        for (String id in promosId) {
          PromoCustom favPromo = getEntityFromFeedListById(id);
          if (favPromo.id != ''){
            if (favPromo.id == id){
              PromoListsManager.currentFavPromoList.promosList.add(favPromo);
              promos.promosList.add(favPromo);
            }
          }
        }

      } else {

        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (String promo in promosId){

          PromoCustom temp = PromoCustom.emptyPromo;
          temp = await temp.getEntityByIdFromDb(promo);

          if (temp.id != ''){
            PromoListsManager.currentFavPromoList.promosList.add(temp);
            promos.promosList.add(temp);
          }
        }
      }
    }*/
    return promos;
  }

  @override
  PromoCustom getEntityFromFeedListById(String id) {
    return PromoListsManager.currentFeedPromosList.promosList.firstWhere((
        element) => element.id == id, orElse: () => PromoCustom.emptyPromo);
  }

  @override
  Future<PromoList> getMyListFromDb(String userId, {bool refresh = false}) async {

    List<MyPlaces> myPlaces = UserCustom.currentUser!.myPlaces;

    PromoList promos = PromoList();
    PromoListsManager.currentMyPromoList = PromoList();
    PromoList downloadedPromosList = PromoListsManager.currentFeedPromosList;

    if (downloadedPromosList.promosList.isEmpty || refresh) {
      PromoList tempList = await getListFromDb();
      downloadedPromosList = tempList;
    }

    for (PromoCustom promo in downloadedPromosList.promosList){
      if (promo.creatorId == userId){
        promos.promosList.add(promo);
      } else if (promo.placeId != '' && myPlaces.isNotEmpty) {
        for (MyPlaces place in myPlaces){
          if (place.placeId == promo.placeId
              && (place.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.reader && place.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.org)){
            promos.promosList.add(promo);
            break;
          }
        }
      }
    }

    /*


    EventsList events = EventsList();
    EventListsManager.currentMyEventsList = EventsList();





     */

    // --- Читаем папку моих сущностей у пользователя ----

    /*String myPath = 'users/$userId/myPromos/';
    DataSnapshot? myFolder = await MixinDatabase.getInfoFromDB(myPath);

    if (myFolder != null) {
      for (var idFolder in myFolder.children) {

        // ---- Считываем ID и добавляем в список ID

        DataSnapshot idSnapshot = idFolder.child('promoId');

        if (idSnapshot.exists){
          promoId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список ID не пустой, и не была вызвана функция обновления
    if (promoId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (PromoListsManager.currentFeedPromosList.promosList.isNotEmpty && !refresh) {
        for (String id in promoId) {
          PromoCustom myPromo = getEntityFromFeedListById(id);
          if (myPromo.id == id) {
            PromoListsManager.currentMyPromoList.promosList.add(myPromo);
            promos.promosList.add(myPromo);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var promo in promoId){
          PromoCustom temp = PromoCustom.emptyPromo;
          temp = await temp.getEntityByIdFromDb(promo);
          if (temp.id != ''){
            PromoListsManager.currentMyPromoList.promosList.add(temp);
            promos.promosList.add(temp);
          }
        }
      }
    }*/
    return promos;
  }

  /// ФУНКЦИЯ ГЕНЕРАЦИИ СЛОВАРЯ ДЛЯ ФИЛЬТРА
  /// <br><br>
  /// Автоматически генерирует ключ-значение, для передачи
  /// в функцию [filterLists]
  Map<String, dynamic> generateMapForFilter (
      PromoCategory promoCategoryFromFilter,
      City cityFromFilter,
      bool today,
      bool onlyFromPlacePromos,
      DateTime selectedStartDatePeriod,
      DateTime selectedEndDatePeriod
      ){
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
  void filterLists(Map<String, dynamic> mapOfArguments) {

    PromoCategory promoCategoryFromFilter = mapOfArguments['promoCategoryFromFilter'];
    City cityFromFilter = mapOfArguments['cityFromFilter'];
    bool today = mapOfArguments['today'];
    bool onlyFromPlacePromos = mapOfArguments['onlyFromPlacePromos'];
    DateTime selectedStartDatePeriod = mapOfArguments['selectedStartDatePeriod'];
    DateTime selectedEndDatePeriod = mapOfArguments['selectedEndDatePeriod'];

    PromoList promos = PromoList();

    for (PromoCustom promo in promosList){
      bool result = promo.checkFilter(
          generateMapForFilter(promoCategoryFromFilter, cityFromFilter, today, onlyFromPlacePromos, selectedStartDatePeriod, selectedEndDatePeriod)
      );

      if (result) {
        promos.promosList.add(promo);
      }
    }
    promosList = promos.promosList;
  }

  @override
  void sortEntitiesList(PromoSortingOption sorting) {
    switch (sorting){

      case PromoSortingOption.nameAsc: promosList.sort((a, b) => a.headline.compareTo(b.headline)); break;

      case PromoSortingOption.nameDesc: promosList.sort((a, b) => b.headline.compareTo(a.headline)); break;

      case PromoSortingOption.favCountAsc: promosList.sort((a, b) => a.favUsersIds.length.compareTo(b.favUsersIds.length)); break;

      case PromoSortingOption.favCountDesc: promosList.sort((a, b) => b.favUsersIds.length.compareTo(a.favUsersIds.length)); break;

    }
  }

  @override
  void deleteEntityFromCurrentFavList(String entityId) {
    PromoListsManager.currentFavPromoList.promosList.removeWhere((promo) => promo.id == entityId);
  }

  @override
  void addEntityToCurrentFavList(String entityId) {
    for (var promo in PromoListsManager.currentFeedPromosList.promosList){
      if (promo.id == entityId){
        PromoListsManager.currentFavPromoList.promosList.add(promo);
        break;
      }
    }
  }

  @override
  void updateCurrentListFavInformation(String entityId, List<String> usersIdsList, bool inFav) {
    // ---- Функция обновления списка из БД при добавлении или удалении из избранного

    for (PromoCustom promo in PromoListsManager.currentFeedPromosList.promosList){
      if (promo.id == entityId){
        promo.favUsersIds = usersIdsList;
        promo.inFav = inFav;
        break;
      }
    }

    for (PromoCustom promo in PromoListsManager.currentFavPromoList.promosList){
      if (promo.id == entityId){
        promo.favUsersIds = usersIdsList;
        promo.inFav = inFav;
        break;
      }
    }

    for (PromoCustom promo in PromoListsManager.currentMyPromoList.promosList){
      if (promo.id == entityId){
        promo.favUsersIds = usersIdsList;
        promo.inFav = inFav;
        break;
      }
    }
  }

  @override
  void deleteEntityFromCurrentEntitiesLists(String promoId) {
    PromoListsManager.currentFeedPromosList.promosList.removeWhere((promo) => promo.id == promoId);
    PromoListsManager.currentFavPromoList.promosList.removeWhere((promo) => promo.id == promoId);
    PromoListsManager.currentMyPromoList.promosList.removeWhere((promo) => promo.id == promoId);
  }

  @override
  Future<PromoList> getEntitiesFromStringList(List<String> listInString) async {
    PromoList promosList = PromoList();

    for (int i = 0; i < listInString.length; i++){
      PromoCustom tempPromo = promosList.getEntityFromFeedListById(listInString[i]);

      if (tempPromo.id != ''){
        promosList.promosList.add(tempPromo);
      } else {
        tempPromo = await tempPromo.getEntityByIdFromDb(listInString[i]);
        if (tempPromo.id != ''){
          promosList.promosList.add(tempPromo);
        }
      }
    }

    return promosList;
  }

  @override
  void addEntityFromCurrentEntitiesLists(PromoCustom entity) {
    PromoListsManager.currentFeedPromosList.promosList.add(entity);
    PromoListsManager.currentMyPromoList.promosList.add(entity);
    if(entity.inFav) PromoListsManager.currentFavPromoList.promosList.add(entity);
  }

  @override
  void updateCurrentEntityInEntitiesList(PromoCustom newPromo) {
    for (PromoCustom oldPromo in PromoListsManager.currentFeedPromosList.promosList){
      if (oldPromo.id == newPromo.id){
        oldPromo = newPromo;
        break;
      }
    }
  }
}