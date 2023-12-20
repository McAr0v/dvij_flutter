import 'package:firebase_database/firebase_database.dart';

class Gender {
  late String id; // Идентификатор пола
  late String name; // Название пола

  Gender({required this.name, required this.id});

  // Метод для преобразования данных из Firebase в объект Gender

  factory Gender.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');

    // Берем из них данные и заполняем в класс Gender И возвращаем его
    return Gender(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
    );
  }


  // Статическая переменная для хранения списка полов
  static List<Gender> currentGenderList = [];

  // Метод для получения списка городов из Firebase и сохранения в currentCityList
  static Future<void> getGenderAndSave({bool order = true}) async {

    currentGenderList = await getGenders(order: order);

  }

  // Функция фильтрации пола по вводимому значению

  static List<Gender> filterGenders(List<Gender> inputList, String filter) {
    List<Gender> newList = [];

    for (int i = 0; i<inputList.length; i++)
    {
      if (inputList[i].name.contains(filter))
      {
        newList.add(inputList[i]);
      }
    }

    return newList;
  }



  // Метод для добавления нового пола или редактирования пола в Firebase

  static Future<String> addAndEditGender(String name, {String id = ''}) async {
    try {
      String? genderKey;

      // --- Указываем папку, где будут хранится Пол ----

      DatabaseReference genderReference = FirebaseDatabase.instance.ref().child('genders');

      if (id == '') {

        // --- Генерируем уникальный ключ ---
        DatabaseReference newGenderReference = genderReference.push();
        // ---- Получаем уникальный ключ ----
        genderKey = newGenderReference.key; // Получаем уникальный ключ

      }

      // --- Создаем окончательный путь ----
      final DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('genders').child(genderKey ?? id);

      // ---- Публикуем город -----
      await reference.set({
        'name': name,
        'id': genderKey ?? id
      });

      // Обновляем список наших городов в локальную переменную
      await getGenderAndSave();

      // --- Возвращаем успех ----
      //TODO - Есть вариант, что тут может город не опубликоваться. Надо как то подумать, чтобы точно знать что он опубиковался
      return 'success';

    } catch (error) {
      // Видимо здесь проверка - если не удалось опубликовать город, то возвращаем ошибку
      return 'Error: $error';
    }
  }

  static Future<String> deleteGender(String genderId) async {
    try {
      DatabaseReference reference = FirebaseDatabase.instance.ref().child('genders').child(genderId);

      // Проверяем, существует ли пол с указанным ID
      DataSnapshot snapshot = await reference.get();
      if (!snapshot.exists) {
        return 'Такой пол не найден';
      }

      // Удаляем город
      await reference.remove();

      // Обновляем список наших полов в локальную переменную
      await getGenderAndSave();

      return 'success';
    } catch (error) {
      return 'Ошибка при удалении гендера: $error';
    }
  }

  // Сортировка списка полов по имени

  static void sortGendersByName(List<Gender> genders, bool order) {

    if (order) {
      genders.sort((a, b) => a.name.compareTo(b.name));
    } else {
      genders.sort((a, b) => b.name.compareTo(a.name));
    }
  }

  // Метод для получения списка гендеров из Firebase

  static Future<List<Gender>> getGenders({bool order = true}) async {

    List<Gender> genders = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('genders');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа гендера
    // и нам нужен каждый гендер, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (Gender.fromSnapshot) из снимка данных
      // и добавляем в список гендеров
      genders.add(Gender.fromSnapshot(childSnapshot));
    }

    sortGendersByName(genders, order);

    // Возвращаем список
    return genders;
  }

  // Метод для поиска гендера по id
  static Future<Gender?> getGenderById(String id) async {

    // Указываем путь
    final DatabaseReference reference =
    FirebaseDatabase.instance.ref().child('genders');

    // Получаем снимок конкретного гендера, по id
    DataSnapshot snapshot = await reference.child(id).get();

    if (snapshot.value != null) {

      // Заполняем класс Gender данными из БД и возвращаем его ====
      return Gender.fromSnapshot(snapshot);

    } else {
      // Если не нашел, возвращаем null
      //return null;
      return Gender(name: '', id: '');
    }
  }
}