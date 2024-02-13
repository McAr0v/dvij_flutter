import 'package:dvij_flutter/cities/city_list_extention.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/interfaces/app_services_interface.dart';
import 'package:firebase_database/firebase_database.dart';

class City with MixinDatabase implements IAppServices<City> {
  late String id;
  late String name;

  City({required this.name, required this.id});

  factory City.fromSnapshot(DataSnapshot snapshot) {
    return City(
      id: snapshot.child('id').value.toString(),
      name: snapshot.child('name').value.toString(),
    );
  }

  static List<City> currentCityList = [];
  static City emptyCity = City(name: '', id: '');

  static Future<void> getCitiesAndSave({bool order = true}) async {
    currentCityList = await emptyCity.getEntitiesListFromDb(order: order);
  }

  Map<String, dynamic> generateCityDataCode() {
    return <String, dynamic> {
      'id': id,
      'name': name
    };
  }

  @override
  Future<String> addOrEditEntityInDb() async {
    String? cityKey;

    City city = City(name: name, id: id);

    if (id == ''){
      cityKey = MixinDatabase.generateKey();
      city.id = cityKey ?? '';
    }

    String path = 'cities/${city.id}';

    Map<String, dynamic> cityData = city.generateCityDataCode();

    String result = await MixinDatabase.publishToDB(path, cityData);

    await getCitiesAndSave();

    return result;
  }

  @override
  Future<String> deleteEntityFromDb() async {

    String path = 'cities/$id';

    String result = await MixinDatabase.deleteFromDb(path);

    await getCitiesAndSave();

    return result;
  }

  @override
  Future<List<City>> getEntitiesListFromDb({bool order = true}) async {
    List<City> cities = [];

    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB('cities');

    if (snapshot != null){
      for (var childSnapshot in snapshot.children) {
        cities.add(City.fromSnapshot(childSnapshot));
      }
    }

    cities.sortCities(order);

    return cities;
  }

  static City getCityByIdFromList(String id) {
      return City(name: '', id: id).getEntityByIdFromList(id);
  }

  @override
  City getEntityByIdFromList(String id) {
    for (int i = 0; i<currentCityList.length; i++){
      if (currentCityList[i].id == id) {
        return currentCityList[i];
      }
    }
    return City(name: '', id: '');
  }

}