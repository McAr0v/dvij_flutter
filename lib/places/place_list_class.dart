import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/places/place_list_manager.dart';
import 'package:dvij_flutter/places/place_sorting_options.dart';
import 'package:firebase_database/firebase_database.dart';

import '../cities/city_class.dart';
import '../database/database_mixin.dart';
import '../interfaces/lists_interface.dart';
import '../users/place_admins_item_class.dart';

class PlaceList implements ILists<PlaceList, Place, PlaceSortingOption>{
  List<Place> placeList = [];

  PlaceList({List<Place>? placeList}){
    this.placeList = placeList ?? this.placeList;
  }

  @override
  void addEntityFromCurrentEntitiesLists(Place entity) {
    PlaceListManager.currentFeedPlacesList.placeList.add(entity);
    PlaceListManager.currentMyPlacesList.placeList.add(entity);
    if(entity.inFav != null && entity.inFav!) PlaceListManager.currentFavPlacesList.placeList.add(entity);
  }

  @override
  void addEntityToCurrentFavList(String entityId) {
    for (var place in PlaceListManager.currentFeedPlacesList.placeList){
      if (place.id == entityId){
        PlaceListManager.currentFavPlacesList.placeList.add(place);
        break;
      }
    }
  }

  @override
  void deleteEntityFromCurrentEntitiesLists(String id) {
    PlaceListManager.currentFeedPlacesList.placeList.removeWhere((place) => place.id == id);
    PlaceListManager.currentFavPlacesList.placeList.removeWhere((place) => place.id == id);
    PlaceListManager.currentMyPlacesList.placeList.removeWhere((place) => place.id == id);
  }

  @override
  void deleteEntityFromCurrentFavList(String entityId) {
    PlaceListManager.currentFavPlacesList.placeList.removeWhere((place) => place.id == entityId);
  }

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
        element) => element.id == id, orElse: () => Place.emptyPlace);
  }

  @override
  Future<PlaceList> getFavListFromDb(String userId, {bool refresh = false}) async {
    PlaceList places = PlaceList();
    PlaceListManager.currentFavPlacesList = PlaceList();
    List<String> placesId = [];

    String myPath = 'users/$userId/favPlaces/';
    DataSnapshot? myFolder = await MixinDatabase.getInfoFromDB(myPath);

    if (myFolder != null) {
      for (var idFolder in myFolder.children) {

        // ---- Считываем ID и добавляем в список ID

        DataSnapshot idSnapshot = idFolder.child('placeId');

        if (idSnapshot.exists){
          placesId.add(idSnapshot.value.toString());
        }
      }
    }

    // Если список ID не пустой, и не была вызвана функция обновления
    if (placesId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty && !refresh) {
        for (String id in placesId) {
          Place myPlace = getEntityFromFeedListById(id);
          if (myPlace.id == id) {
            PlaceListManager.currentFavPlacesList.placeList.add(myPlace);
            places.placeList.add(myPlace);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var place in placesId){
          Place temp = Place.emptyPlace;
          temp = await temp.getEntityByIdFromDb(place);
          if (temp.id != ''){
            PlaceListManager.currentFavPlacesList.placeList.add(temp);
            places.placeList.add(temp);
          }
        }
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

        Place place = Place.emptyPlace;

        place = place.getEntityFromSnapshot(placeIdsFolder);

        PlaceListManager.currentFeedPlacesList.placeList.add(place);
        places.placeList.add(place);

      }
    }
    return places;
  }

  @override
  Future<PlaceList> getMyListFromDb(String userId, {bool refresh = false}) async {
    PlaceList places = PlaceList();
    PlaceListManager.currentMyPlacesList = PlaceList();
    List<String> placesId = [];

    if (UserCustom.currentUser != null) {
      placesId = UserCustom.currentUser!.myPlaces;
    }

    // Если список ID не пустой, и не была вызвана функция обновления
    if (placesId.isNotEmpty){

      // Если список всей ленты не пустой, то будем забирать данные из него
      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty && !refresh) {
        for (String id in placesId) {
          Place myPlace = getEntityFromFeedListById(id);
          if (myPlace.id == id) {
            PlaceListManager.currentMyPlacesList.placeList.add(myPlace);
            places.placeList.add(myPlace);
          }
        }
      } else {
        // Если список ленты не прогружен, то считываем каждую сущность из БД
        for (var place in placesId){
          Place temp = Place.emptyPlace;
          temp = await temp.getEntityByIdFromDb(place);
          if (temp.id != ''){
            PlaceListManager.currentMyPlacesList.placeList.add(temp);
            places.placeList.add(temp);
          }
        }
      }
    }
    return places;
  }

  @override
  void sortEntitiesList(PlaceSortingOption sorting) {
    switch (sorting){

      case PlaceSortingOption.nameAsc: placeList.sort((a, b) => a.name.compareTo(b.name)); break;

      case PlaceSortingOption.nameDesc: placeList.sort((a, b) => b.name.compareTo(a.name)); break;

      case PlaceSortingOption.promoCountAsc: placeList.sort((a, b) => a.promoCount!.compareTo(b.promoCount!)); break;

      case PlaceSortingOption.promoCountDesc: placeList.sort((a, b) => b.promoCount!.compareTo(a.promoCount!)); break;

      case PlaceSortingOption.eventCountAsc: placeList.sort((a, b) => a.eventsCount!.compareTo(b.eventsCount!)); break;

      case PlaceSortingOption.eventCountDesc: placeList.sort((a, b) => b.eventsCount!.compareTo(a.eventsCount!)); break;

      case PlaceSortingOption.favCountAsc: placeList.sort((a, b) => a.addedToFavouritesCount!.compareTo(b.addedToFavouritesCount!)); break;

      case PlaceSortingOption.favCountDesc: placeList.sort((a, b) => b.addedToFavouritesCount!.compareTo(a.addedToFavouritesCount!)); break;

    }
  }

  @override
  void updateCurrentListFavInformation(String entityId, int favCounter, bool inFav) {
    for (Place place in PlaceListManager.currentFeedPlacesList.placeList){
      if (place.id == entityId){
        place.addedToFavouritesCount = favCounter;
        place.inFav = inFav;
        break;
      }
    }

    for (Place place in PlaceListManager.currentFavPlacesList.placeList){
      if (place.id == entityId){
        place.addedToFavouritesCount = favCounter;
        place.inFav = inFav;
        break;
      }
    }

    for (Place place in PlaceListManager.currentMyPlacesList.placeList){
      if (place.id == entityId){
        place.addedToFavouritesCount = favCounter;
        place.inFav = inFav;
        break;
      }
    }
  }

  void updateCurrentListAdminsInformation(String entityId, List<PlaceAdminsListItem> admins) {
    for (Place place in PlaceListManager.currentFeedPlacesList.placeList){
      if (place.id == entityId){
        place.admins = admins;
        break;
      }
    }

    for (Place place in PlaceListManager.currentFavPlacesList.placeList){
      if (place.id == entityId){
        place.admins = admins;
        break;
      }
    }

    for (Place place in PlaceListManager.currentMyPlacesList.placeList){
      if (place.id == entityId){
        place.admins = admins;
        break;
      }
    }
  }

}