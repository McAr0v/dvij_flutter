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

    // Создаем пустой список акций
    PromoList promosToReturn = PromoList();

    // Дублируем уже скачанный список акций
    PromoList downloadedPromosList = PromoListsManager.currentFeedPromosList;

    // Если скаченных акций нет или нам нужно обновить список
    if (downloadedPromosList.promosList.isEmpty || refresh) {
      // Подгружаем заново список акций
      PromoList tempList = await getListFromDb();
      // Дублируем его в список скаченных
      downloadedPromosList = tempList;
    }

    // Читаем каждую акцию из списка скаченных
    for (PromoCustom promo in downloadedPromosList.promosList){
      // Если создатель у акции как ID пользователя
      if (promo.creatorId == userId){
        // Добавляем в список акций
        promosToReturn.promosList.add(promo);
      } else if (promo.placeId != '' && myPlaces.isNotEmpty) {
        // Если создатель не я, то проверяем акцию на заведение
        // есть ли у меня как у администратора заведения права на редактирование акции
        // Пробегаемся по списку моих мест
        for (MyPlaces place in myPlaces){
          // Если роль не читатель и не организатор
          if (place.placeId == promo.placeId
              && (place.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.reader && place.placeRole.roleInPlaceEnum != PlaceUserRoleEnum.org)){
            // Так же добавляем в список
            promosToReturn.promosList.add(promo);
            break;
          }
        }
      }
    }

    return promosToReturn;
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

      case PromoSortingOption.fromDb: promosList; break;

      case PromoSortingOption.createDateAsc: promosList.sort((a,b) => b.createDate.compareTo(a.createDate)); break;

      case PromoSortingOption.createDateDesc: promosList.sort((a,b) => a.createDate.compareTo(b.createDate)); break;

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
  }

  @override
  void deleteEntityFromCurrentEntitiesLists(String promoId) {
    PromoListsManager.currentFeedPromosList.promosList.removeWhere((promo) => promo.id == promoId);
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