import 'package:firebase_database/firebase_database.dart';

class PromoCategory {
  late String id; // Идентификатор
  late String name; // Название

  PromoCategory({required this.name, required this.id});

  factory PromoCategory.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');

    // Берем из них данные и заполняем в класс И возвращаем его
    return PromoCategory(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
    );
  }


  // Статическая переменная для хранения списка
  static List<PromoCategory> currentPromoCategoryList = [];

  // Метод для получения списка из Firebase и сохранения
  static Future<void> getPromoCategoryAndSave({bool order = true}) async {

    currentPromoCategoryList = await getPromoCategory(order: order);

  }

  // Функция фильтрации списка по вводимому значению

  static List<PromoCategory> filterStrings(List<PromoCategory> inputList, String filter) {
    List<PromoCategory> newList = [];

    for (int i = 0; i<inputList.length; i++)
    {
      if (inputList[i].name.contains(filter))
      {
        newList.add(inputList[i]);
      }
    }

    return newList;
  }



  // Метод для добавления нового элемента или редактирования в Firebase

  static Future<String> addAndEditPromoCategory(String name, {String id = ''}) async {
    try {
      String? promoCategoryKey;

      // --- Указываем папку, где будут хранится ----

      DatabaseReference promoCategoriesReference = FirebaseDatabase.instance.ref().child('promo_categories');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newPromoCategoryReference = promoCategoriesReference.push();
        // ---- Получаем уникальный ключ ----
        promoCategoryKey = newPromoCategoryReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('promo_categories').child(promoCategoryKey ?? id);

      // ---- Публикуем -----
      await reference.set({
        'name': name,
        'id': promoCategoryKey ?? id
      });

      // Обновляем список в локальную переменную
      await getPromoCategoryAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может город не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать город, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deletePromoCategory(String categoryId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('promo_categories').child(categoryId);

      // Проверяем, существует ли элемент с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Категория акций не найдена';
      }

      // Удаляем город
      await reference.remove();

      // Обновляем список наших элементов в локальную переменную
      await getPromoCategoryAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении Категории акций: $error';
    }
  }

  // Сортировка городов по имени

  static void sortPromoCategoryByName(List<PromoCategory> promoCategories, bool order) {

    if (order) {
      promoCategories.sort((a, b) => a.name.compareTo(b.name));
    } else {
      promoCategories.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка городов из Firebase

  static Future<List<PromoCategory>> getPromoCategory({bool order = true}) async {

    List<PromoCategory> promoCategories = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('promo_categories');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов
      promoCategories.add(PromoCategory.fromSnapshot(childSnapshot));
    }

    sortPromoCategoryByName(promoCategories, order);

    // Возвращаем список
    return promoCategories;
  }

  // Метод для поиска города по id
  static Future<PromoCategory?> getPromoCategoryById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('promo_categories');

    // Получаем снимок конкретного города, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс City данными из БД и возвращаем его ====
      return PromoCategory.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return PromoCategory(name: '', id: '');
    }
  }

  static String getPromoCategoryName (String id) {
    String result = 'Категория не найдена';

    for (int i = 0; i < PromoCategory.currentPromoCategoryList.length; i++ )
    {
      if (PromoCategory.currentPromoCategoryList[i].id == id) {
        result = currentPromoCategoryList[i].name;
      }
    }
    return result;
  }

  static PromoCategory getPromoCategoryFromCategoriesList (String id) {
    PromoCategory result = PromoCategory(name: 'Категория не найдена', id: '');

    for (int i = 0; i < PromoCategory.currentPromoCategoryList.length; i++ )
    {
      if (PromoCategory.currentPromoCategoryList[i].id == id) {
        result = currentPromoCategoryList[i];
      }
    }
    return result;
  }

}