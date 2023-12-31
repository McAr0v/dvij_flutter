import 'package:firebase_database/firebase_database.dart';

class City {
  late String id; // Идентификатор города
  late String name; // Название города

  City({required this.name, required this.id});

  // Метод для преобразования данных из Firebase в объект City

  factory City.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return City(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
    );
  }


  // Статическая переменная для хранения списка городов
  static List<City> currentCityList = [];

  // Метод для получения списка городов из Firebase и сохранения в currentCityList
  static Future<void> getCitiesAndSave({bool order = true}) async {

    currentCityList = await getCities(order: order);

  }

  // Функция фильтрации городов по вводимому значению

  static List<City> filterStrings(List<City> inputList, String filter) {
    List<City> newList = [];

    for (int i = 0; i<inputList.length; i++)
    {
      if (inputList[i].name.contains(filter))
      {
        newList.add(inputList[i]);
      }
    }

    return newList;
  }



  // Метод для добавления нового города или редактирования города в Firebase

  static Future<String> addAndEditCity(String name, {String id = ''}) async {
    try {
      String? cityKey;

      // --- Указываем папку, где будут хранится города ----

      DatabaseReference citiesReference = FirebaseDatabase.instance.ref().child('cities');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newCityReference = citiesReference.push();
        // ---- Получаем уникальный ключ ----
        cityKey = newCityReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('cities').child(cityKey ?? id);

      // ---- Публикуем город -----
      await reference.set({
        'name': name,
        'id': cityKey ?? id
      });

      // Обновляем список наших городов в локальную переменную
      await getCitiesAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может город не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать город, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deleteCity(String cityId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('cities').child(cityId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Город не найден';
      }

      // Удаляем город
      await reference.remove();

      // Обновляем список наших городов в локальную переменную
      await getCitiesAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении города: $error';
    }
  }

  // Сортировка городов по имени

  static void sortCitiesByName(List<City> cities, bool order) {

    if (order) cities.sort((a, b) => a.name.compareTo(b.name));
    else {
      cities.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка городов из Firebase

  static Future<List<City>> getCities({bool order = true}) async {

    List<City> cities = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('cities');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов
      cities.add(City.fromSnapshot(childSnapshot));
    }

    sortCitiesByName(cities, order);

    // Возвращаем список
    return cities;
  }

  // Метод для поиска города по id
  static Future<City?> getCityById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('cities');

    // Получаем снимок конкретного города, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс City данными из БД и возвращаем его ====
      return City.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return City(name: '', id: '');
    }
  }

  static String getCityName (String id) {
    String result = 'Город не найден';

    for (int i = 0; i < City.currentCityList.length; i++ )
      {
        if (City.currentCityList[i].id == id) {
          result = currentCityList[i].name;
        }
      }
    return result;
  }

  static City getCityNameInCitiesList (String id) {
    City result = City(name: 'Город не найден', id: '');

    for (int i = 0; i < City.currentCityList.length; i++ )
    {
      if (City.currentCityList[i].id == id) {
        result = currentCityList[i];
      }
    }
    return result;
  }

}