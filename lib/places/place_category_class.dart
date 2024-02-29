import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/interfaces/app_services_interface.dart';
import 'package:dvij_flutter/places/place_extensions.dart';
import 'package:firebase_database/firebase_database.dart';

class PlaceCategory with MixinDatabase implements IAppServices<PlaceCategory> {
  late String id; // Идентификатор города
  late String name; // Название города

  PlaceCategory({required this.name, required this.id});

  factory PlaceCategory.fromSnapshot(DataSnapshot snapshot) {
    return PlaceCategory(
      id: snapshot.child('id').value.toString(),
      name: snapshot.child('name').value.toString(),
    );
  }

  static PlaceCategory empty = PlaceCategory(name: '', id: '');

  // Статическая переменная для хранения списка городов
  static List<PlaceCategory> currentPlaceCategoryList = [];

  // Метод для получения списка городов из Firebase и сохранения в currentCityList
  static Future<void> getPlaceCategoryAndSave({bool order = true}) async {

    PlaceCategory temp = PlaceCategory.empty;
    currentPlaceCategoryList = await empty.getEntitiesListFromDb();

  }

  Map<String, dynamic> generateInfoForDb() {
    return <String, dynamic> {
      'id': id,
      'name': name
    };
  }

  @override
  Future<String> addOrEditEntityInDb() async {
    String? key;

    PlaceCategory category = PlaceCategory(name: name, id: id);

    if (id == ''){
      key = MixinDatabase.generateKey();
      category.id = key ?? '';
    }

    String path = 'place_categories/${category.id}';

    Map<String, dynamic> info = category.generateInfoForDb();

    String result = await MixinDatabase.publishToDB(path, info);

    await getPlaceCategoryAndSave();

    return result;
  }

  @override
  Future<String> deleteEntityFromDb() async {
    String path = 'place_categories/$id';

    String result = await MixinDatabase.deleteFromDb(path);

    await getPlaceCategoryAndSave();

    return result;
  }

  @override
  Future<List<PlaceCategory>> getEntitiesListFromDb({bool order = true}) async {
    List<PlaceCategory> categories = [];

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('place_categories');

    if (snapshot != null){
      for (var childSnapshot in snapshot.children) {
        categories.add(PlaceCategory.fromSnapshot(childSnapshot));
      }
    }

    categories.sortPlaceCategories(order);

    return categories;
  }

  static PlaceCategory getPlaceCategoryFromCategoriesList (String id) {
    PlaceCategory temp = PlaceCategory.empty;
    return temp.getEntityByIdFromList(id);
  }

  @override
  PlaceCategory getEntityByIdFromList(String id) {
    PlaceCategory result = PlaceCategory.empty;

    for (int i = 0; i < PlaceCategory.currentPlaceCategoryList.length; i++ )
    {
      if (PlaceCategory.currentPlaceCategoryList[i].id == id) {
        result = currentPlaceCategoryList[i];
      }
    }
    return result;
  }
}