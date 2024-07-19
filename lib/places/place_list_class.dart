import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:dvij_flutter/places/users_my_place/my_places_class.dart';
import 'package:firebase_database/firebase_database.dart';
import '../cities/city_class.dart';
import '../database/database_mixin.dart';
import '../interfaces/lists_interface.dart';

class PlaceList implements ILists<PlaceList, Place, PlaceSortingOption>{
  List<Place> placeList = [];

  PlaceList({List<Place>? placeList}){
    this.placeList = placeList ?? this.placeList;
  }

  @override
  void addEntityFromCurrentEntitiesLists(Place entity) {
    PlaceListManager.currentFeedPlacesList.placeList.add(entity);
  }

  /*@override
  void addEntityToCurrentFavList(String entityId) {
    for (var place in PlaceListManager.currentFeedPlacesList.placeList){
      if (place.id == entityId){
        PlaceListManager.currentFavPlacesList.placeList.add(place);
        break;
      }
    }
  }*/

  @override
  void deleteEntityFromCurrentEntitiesLists(String id) {
    PlaceListManager.currentFeedPlacesList.placeList.removeWhere((place) => place.id == id);
    //PlaceListManager.currentFavPlacesList.placeList.removeWhere((place) => place.id == id);
    //PlaceListManager.currentMyPlacesList.placeList.removeWhere((place) => place.id == id);
  }

  /*@override
  void deleteEntityFromCurrentFavList(String entityId) {
    PlaceListManager.currentFavPlacesList.placeList.removeWhere((place) => place.id == entityId);
  }*/

  /// ФУНКЦИЯ ГЕНЕРАЦИИ СЛОВАРЯ ФИЛЬТРА ДЛЯ ПЕРЕДАЧИ В ФУНКЦИЮ
  /// <br><br>
  /// Автоматически делает словарь из данных фильтра, по которым
  /// будет производиться фильтрация сущности
  Map<String, dynamic> generateMapForFilter(
      PlaceCategory placeCategoryFromFilter,
      City cityFromFilter,
      bool haveEventsFromFilter,
      bool nowIsOpenFromFilter,
      bool havePromosFromFilter,
      ) {
    return {
      'placeCategoryFromFilter': placeCategoryFromFilter,
      'cityFromFilter': cityFromFilter,
      'haveEventsFromFilter': haveEventsFromFilter,
      'havePromosFromFilter': havePromosFromFilter,
      'nowIsOpenFromFilter': nowIsOpenFromFilter,
    };
  }

  @override
  void filterLists(Map<String, dynamic> mapOfArguments) {

    PlaceList places = PlaceList();

    for (Place place in placeList){

      bool result = place.checkFilter(
          mapOfArguments
      );

      if (result) {
        places.placeList.add(place);
      }
    }
    placeList = places.placeList;
  }

  @override
  Future<PlaceList> getEntitiesFromStringList(List<String> listInString) async {
    PlaceList placeList = PlaceList();

    for (int i = 0; i < listInString.length; i++){
      Place tempPlace = placeList.getEntityFromFeedListById(listInString[i]);

      if (tempPlace.id != ''){
        placeList.placeList.add(tempPlace);
      } else {
        tempPlace = await tempPlace.getEntityByIdFromDb(listInString[i]);
        if (tempPlace.id != ''){
          placeList.placeList.add(tempPlace);
        }
      }
    }

    return placeList;
  }

  @override
  Place getEntityFromFeedListById(String id) {
    return PlaceListManager.currentFeedPlacesList.placeList.firstWhere((
        element) => element.id == id, orElse: () => Place.empty());
  }

  @override
  Future<PlaceList> getFavListFromDb(String userId, {bool refresh = false}) async {
    PlaceList places = PlaceList();

    PlaceList downloadedPlacesList = PlaceListManager.currentFeedPlacesList;

    if (downloadedPlacesList.placeList.isEmpty || refresh) {
      PlaceList tempList = await getListFromDb();
      downloadedPlacesList = tempList;
    }

    for (Place place in downloadedPlacesList.placeList){
      if (place.favUsersIds.contains(userId)){
        places.placeList.add(place);
      }
    }
    return places;
  }

  @override
  Future<PlaceList> getListFromDb() async {
    PlaceList places = PlaceList();
    PlaceListManager.currentFeedPlacesList = PlaceList();

    DataSnapshot? placesSnapshot = await MixinDatabase.getInfoFromDB('places');

    if (placesSnapshot != null) {
      for (var placeIdsFolder in placesSnapshot.children) {

        Place place = Place.empty();

        place = place.getEntityFromSnapshot(placeIdsFolder);

        PlaceListManager.currentFeedPlacesList.placeList.add(place);
        places.placeList.add(place);

      }
    }
    return places;
  }

  @override
  Future<PlaceList> getMyListFromDb(String userId, {bool refresh = false}) async {
    PlaceList placesToReturn = PlaceList();

    List<MyPlaces> myPlaces = UserCustom.currentUser!.myPlaces;

    // Все нижеследующее имеет смысл, если есть хоть 1 мое заведение
    if (myPlaces.isNotEmpty){

      // Если список всех заведений пустой или нужно обновить список, подгружаем из базы данных
      if (PlaceListManager.currentFeedPlacesList.placeList.isEmpty || refresh) {
        await getListFromDb();
      }

      // Если общий список заведений не пустой
      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
        // Подгружаем сущности моих заведений и добавляем в список
        for (MyPlaces tempMyPlace in myPlaces) {
          Place searchingPlace = getEntityFromFeedListById(tempMyPlace.placeId);
          if (searchingPlace.id == tempMyPlace.placeId) {
            placesToReturn.placeList.add(searchingPlace);
          }
        }
      }

    }
    return placesToReturn;
  }

  @override
  void sortEntitiesList(PlaceSortingOption sorting) {
    switch (sorting){

      case PlaceSortingOption.nameAsc: placeList.sort((a, b) => a.name.compareTo(b.name)); break;

      case PlaceSortingOption.nameDesc: placeList.sort((a, b) => b.name.compareTo(a.name)); break;

      case PlaceSortingOption.promoCountAsc: placeList.sort((a, b) => a.promosList.length.compareTo(b.promosList.length)); break;

      case PlaceSortingOption.promoCountDesc: placeList.sort((a, b) => b.promosList.length.compareTo(a.promosList.length)); break;

      case PlaceSortingOption.eventCountAsc: placeList.sort((a, b) => a.eventsList.length.compareTo(b.eventsList.length)); break;

      case PlaceSortingOption.eventCountDesc: placeList.sort((a, b) => b.eventsList.length.compareTo(a.eventsList.length)); break;

      case PlaceSortingOption.favCountAsc: placeList.sort((a, b) => a.favUsersIds.length.compareTo(b.favUsersIds.length)); break;

      case PlaceSortingOption.favCountDesc: placeList.sort((a, b) => b.favUsersIds.length.compareTo(a.favUsersIds.length)); break;

      case PlaceSortingOption.createDateAsc: placeList.sort((a,b) => a.createDate.compareTo(b.createDate)); break;

      case PlaceSortingOption.createDateDesc: placeList.sort((a,b) => b.createDate.compareTo(a.createDate)); break;

    }
  }

  @override
  void updateCurrentListFavInformation(String entityId, List<String> usersIdsList, bool inFav) {
    for (Place place in PlaceListManager.currentFeedPlacesList.placeList){
      if (place.id == entityId){
        place.favUsersIds = usersIdsList;
        place.inFav = inFav;
        break;
      }
    }

    /*for (Place place in PlaceListManager.currentFavPlacesList.placeList){
      if (place.id == entityId){
        place.favUsersIds = usersIdsList;
        place.inFav = inFav;
        break;
      }
    }

    for (Place place in PlaceListManager.currentMyPlacesList.placeList){
      if (place.id == entityId){
        place.favUsersIds = usersIdsList;
        place.inFav = inFav;
        break;
      }
    }*/
  }

  @override
  void updateCurrentEntityInEntitiesList(Place newPlace) {
    for (Place oldPlace in PlaceListManager.currentFeedPlacesList.placeList){
      if (oldPlace.id == newPlace.id){
        oldPlace = newPlace;
        break;
      }
    }
  }

}