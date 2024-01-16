import 'package:firebase_database/firebase_database.dart';

class EventCategory {
  late String id; // Идентификатор города
  late String name; // Название города

  EventCategory({required this.name, required this.id});

  factory EventCategory.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');

    // Берем из них данные и заполняем в класс City. И возвращаем его
    return EventCategory(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
    );
  }


  // Статическая переменная для хранения списка городов
  static List<EventCategory> currentEventCategoryList = [];

  // Метод для получения списка городов из Firebase и сохранения в currentCityList
  static Future<void> getEventCategoryAndSave({bool order = true}) async {

    currentEventCategoryList = await getEventCategory(order: order);

  }

  // Функция фильтрации городов по вводимому значению

  static List<EventCategory> filterStrings(List<EventCategory> inputList, String filter) {
    List<EventCategory> newList = [];

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

  static Future<String> addAndEditEventCategory(String name, {String id = ''}) async {
    try {
      String? eventCategoryKey;

      // --- Указываем папку, где будут хранится города ----

      DatabaseReference eventCategoriesReference = FirebaseDatabase.instance.ref().child('event_categories');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newEventCategoryReference = eventCategoriesReference.push();
        // ---- Получаем уникальный ключ ----
        eventCategoryKey = newEventCategoryReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('event_categories').child(eventCategoryKey ?? id);

      // ---- Публикуем город -----
      await reference.set({
        'name': name,
        'id': eventCategoryKey ?? id
      });

      // Обновляем список наших городов в локальную переменную
      await getEventCategoryAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может город не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать город, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deleteEventCategory(String categoryId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('event_categories').child(categoryId);

      // Проверяем, существует ли город с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Категория мероприятий не найдена';
      }

      // Удаляем город
      await reference.remove();

      // Обновляем список наших городов в локальную переменную
      await getEventCategoryAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении Категории мероприятий: $error';
    }
  }

  // Сортировка городов по имени

  static void sortEventCategoryByName(List<EventCategory> eventCategories, bool order) {

    if (order) {
      eventCategories.sort((a, b) => a.name.compareTo(b.name));
    } else {
      eventCategories.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка городов из Firebase

  static Future<List<EventCategory>> getEventCategory({bool order = true}) async {

    List<EventCategory> eventCategories = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('event_categories');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов
      eventCategories.add(EventCategory.fromSnapshot(childSnapshot));
    }

    sortEventCategoryByName(eventCategories, order);

    // Возвращаем список
    return eventCategories;
  }

  // Метод для поиска города по id
  static Future<EventCategory?> getEventCategoryById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('event_categories');

    // Получаем снимок конкретного города, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс City данными из БД и возвращаем его ====
      return EventCategory.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return EventCategory(name: '', id: '');
    }
  }

  static String getEventCategoryName (String id) {
    String result = 'Категория не найдена';

    for (int i = 0; i < EventCategory.currentEventCategoryList.length; i++ )
    {
      if (EventCategory.currentEventCategoryList[i].id == id) {
        result = currentEventCategoryList[i].name;
      }
    }
    return result;
  }

  static EventCategory getEventCategoryFromCategoriesList (String id) {
    EventCategory result = EventCategory(name: 'Категория не найдена', id: '');

    for (int i = 0; i < EventCategory.currentEventCategoryList.length; i++ )
    {
      if (EventCategory.currentEventCategoryList[i].id == id) {
        result = currentEventCategoryList[i];
      }
    }
    return result;
  }

}