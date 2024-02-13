import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/interfaces/app_services_interface.dart';
import 'package:dvij_flutter/promos/promo_extensions.dart';
import 'package:firebase_database/firebase_database.dart';

class PromoCategory with MixinDatabase implements IAppServices<PromoCategory> {
  late String id; // Идентификатор
  late String name; // Название

  PromoCategory({required this.name, required this.id});

  factory PromoCategory.fromSnapshot(DataSnapshot snapshot) {
    return PromoCategory(
      id: snapshot.child('id').value.toString(),
      name: snapshot.child('name').value.toString(),
    );
  }


  // Статическая переменная для хранения списка
  static List<PromoCategory> currentPromoCategoryList = [];

  static PromoCategory empty = PromoCategory(name: '', id: '');

  Map<String, dynamic> generateInfoForDb() {
    return <String, dynamic> {
      'id': id,
      'name': name
    };
  }

  @override
  Future<String> addOrEditEntityInDb() async {
    String? key;

    PromoCategory category = PromoCategory(name: name, id: id);

    if (id == ''){
      key = MixinDatabase.generateKey();
      category.id = key ?? '';
    }

    String path = 'promo_categories/${category.id}';

    Map<String, dynamic> info = category.generateInfoForDb();

    String result = await MixinDatabase.publishToDB(path, info);

    await getPromoCategoryAndSave();

    return result;

  }

  @override
  Future<String> deleteEntityFromDb() async {

    String path = 'promo_categories/$id';

    String result = await MixinDatabase.deleteFromDb(path);

    await getPromoCategoryAndSave();

    return result;
  }

  @override
  Future<List<PromoCategory>> getEntitiesListFromDb({bool order = true}) async {

    List<PromoCategory> categories = [];

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('promo_categories');

    if (snapshot != null){
      for (var childSnapshot in snapshot.children) {
        categories.add(PromoCategory.fromSnapshot(childSnapshot));
      }
    }

    categories.sortPromoCategories(order);

    return categories;
  }

  @override
  PromoCategory getEntityByIdFromList(String id) {
    PromoCategory result = PromoCategory(name: '', id: '');

    for (int i = 0; i<currentPromoCategoryList.length; i++){
      if (currentPromoCategoryList[i].id == id) {
        return currentPromoCategoryList[i];
      }
    }

    return result;

  }

  // Метод для получения списка из Firebase и сохранения
  static Future<void> getPromoCategoryAndSave({bool order = true}) async {

    PromoCategory tempCategory = PromoCategory.empty;
    currentPromoCategoryList = await tempCategory.getEntitiesListFromDb(order: order);

  }

  static PromoCategory getPromoCategoryFromCategoriesList (String id) {
    PromoCategory result = PromoCategory(name: '', id: '');

    return result.getEntityByIdFromList(id);
  }

}