import 'package:firebase_database/firebase_database.dart';

class PlaceCategory {
  late String id; // Идентификатор города
  late String name; // Название города

  PlaceCategory({required this.name, required this.id});

  factory PlaceCategory.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return PlaceCategory(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
    );
  }


  // Статическая переменная для хранения списка городов
  static List<PlaceCategory> currentPlaceCategoryList = [];

  // Метод для получения списка городов из Firebase и сохранения в currentCityList
  static Future<void> getPlaceCategoryAndSave({bool order = true}) async {

    currentPlaceCategoryList = await getPlaceCategory(order: order);

  }

  // Функция фильтрации городов по вводимому значению

  static List<PlaceCategory> filterStrings(List<PlaceCategory> inputList, String filter) {
    List<PlaceCategory> newList = [];

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

  static Future<String> addAndEditPlaceCategory(String name, {String id = ''}) async {
    try {
      String? placeCategoryKey;

      // --- Указываем папку, где будут хранится города ----

      DatabaseReference placeCategoriesReference = FirebaseDatabase.instance.ref().child('place_categories');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newPlaceCategoryReference = placeCategoriesReference.push();
        // ---- Получаем уникальный ключ ----
        placeCategoryKey = newPlaceCategoryReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('place_categories').child(placeCategoryKey ?? id);

      // ---- Публикуем город -----
      await reference.set({
        'name': name,
        'id': placeCategoryKey ?? id
      });

      // Обновляем список наших городов в локальную переменную
      await getPlaceCategoryAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может город не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать город, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deletePlaceCategory(String categoryId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('place_categories').child(categoryId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Категория места не найдена';
      }

      // Удаляем город
      await reference.remove();

      // Обновляем список наших городов в локальную переменную
      await getPlaceCategoryAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении Категории места: $error';
    }
  }

  // Сортировка городов по имени

  static void sortPlaceCategoryByName(List<PlaceCategory> placeCategories, bool order) {

    if (order) {
      placeCategories.sort((a, b) => a.name.compareTo(b.name));
    } else {
      placeCategories.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка городов из Firebase

  static Future<List<PlaceCategory>> getPlaceCategory({bool order = true}) async {

    List<PlaceCategory> placeCategories = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('place_categories');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов
      placeCategories.add(PlaceCategory.fromSnapshot(childSnapshot));
    }

    sortPlaceCategoryByName(placeCategories, order);

    // Возвращаем список
    return placeCategories;
  }

  // Метод для поиска города по id
  static Future<PlaceCategory?> getPlaceCategoryById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('place_categories');

    // Получаем снимок конкретного города, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс City данными из БД и возвращаем его ====
      return PlaceCategory.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return PlaceCategory(name: '', id: '');
    }
  }

  static String getPlaceCategoryName (String id) {
    String result = 'Категория не найдена';

    for (int i = 0; i < PlaceCategory.currentPlaceCategoryList.length; i++ )
    {
      if (PlaceCategory.currentPlaceCategoryList[i].id == id) {
        result = currentPlaceCategoryList[i].name;
      }
    }
    return result;
  }
}