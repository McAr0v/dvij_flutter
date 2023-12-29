import 'package:firebase_database/firebase_database.dart';

class Place {
  String id;
  String name;
  String desc;
  String creatorId;
  String createDate;
  String category;
  String city;
  String street;
  String house;
  String phone;
  String whatsapp; // Формат даты (например, "yyyy-MM-dd")
  String telegram;
  String instagram;
  String imageUrl;
  String mondayStartTime;
  String mondayFinishTime;
  String tuesdayStartTime;
  String tuesdayFinishTime;
  String wednesdayStartTime;
  String wednesdayFinishTime;
  String thursdayStartTime;
  String thursdayFinishTime;
  String fridayStartTime;
  String fridayFinishTime;
  String saturdayStartTime;
  String saturdayFinishTime;
  String sundayStartTime;
  String sundayFinishTime;

  Place({
    required this.id,
    required this.name,
    required this.desc,
    required this.creatorId,
    required this.createDate,
    required this.category,
    required this.city,
    required this.street,
    required this.house,
    required this.phone,
    required this.whatsapp,
    required this.telegram,
    required this.instagram,
    required this.imageUrl,
    required this.mondayStartTime,
    required this.mondayFinishTime,
    required this.tuesdayStartTime,
    required this.tuesdayFinishTime,
    required this.wednesdayStartTime,
    required this.wednesdayFinishTime,
    required this.thursdayStartTime,
    required this.thursdayFinishTime,
    required this.fridayStartTime,
    required this.fridayFinishTime,
    required this.saturdayStartTime,
    required this.saturdayFinishTime,
    required this.sundayStartTime,
    required this.sundayFinishTime,
  });

  factory Place.fromSnapshot(DataSnapshot snapshot) {
    // Указываем путь к нашим полям
    DataSnapshot idSnapshot = snapshot.child('id');
    DataSnapshot nameSnapshot = snapshot.child('name');
    DataSnapshot descSnapshot = snapshot.child('desc');
    DataSnapshot creatorIdSnapshot = snapshot.child('creatorId');
    DataSnapshot createDateSnapshot = snapshot.child('createDate');
    DataSnapshot categorySnapshot = snapshot.child('category');
    DataSnapshot citySnapshot = snapshot.child('city');
    DataSnapshot streetSnapshot = snapshot.child('street');
    DataSnapshot houseSnapshot = snapshot.child('house');
    DataSnapshot phoneSnapshot = snapshot.child('phone');
    DataSnapshot whatsappSnapshot = snapshot.child('whatsapp');
    DataSnapshot telegramSnapshot = snapshot.child('telegram');
    DataSnapshot instagramSnapshot = snapshot.child('instagram');
    DataSnapshot imageUrlSnapshot = snapshot.child('imageUrl');
    DataSnapshot mondayStartTimeSnapshot = snapshot.child('mondayStartTime');
    DataSnapshot mondayFinishTimeSnapshot = snapshot.child('mondayFinishTime');
    DataSnapshot tuesdayStartTimeSnapshot = snapshot.child('tuesdayStartTime');
    DataSnapshot tuesdayFinishTimeSnapshot = snapshot.child('tuesdayFinishTime');
    DataSnapshot wednesdayStartTimeSnapshot = snapshot.child('wednesdayStartTime');
    DataSnapshot wednesdayFinishTimeSnapshot = snapshot.child('wednesdayFinishTime');
    DataSnapshot thursdayStartTimeSnapshot = snapshot.child('thursdayStartTime');
    DataSnapshot thursdayFinishTimeSnapshot = snapshot.child('thursdayFinishTime');
    DataSnapshot fridayStartTimeSnapshot = snapshot.child('fridayStartTime');
    DataSnapshot fridayFinishTimeSnapshot = snapshot.child('fridayFinishTime');
    DataSnapshot saturdayStartTimeSnapshot = snapshot.child('saturdayStartTime');
    DataSnapshot saturdayFinishTimeSnapshot = snapshot.child('saturdayFinishTime');
    DataSnapshot sundayStartTimeSnapshot = snapshot.child('sundayStartTime');
    DataSnapshot sundayFinishTimeSnapshot = snapshot.child('sundayFinishTime');

    return Place(
      id: idSnapshot.value.toString() ?? '',
      name: nameSnapshot.value.toString() ?? '',
      desc: descSnapshot.value.toString() ?? '',
      creatorId: creatorIdSnapshot.value.toString() ?? '',
      createDate: createDateSnapshot.value.toString() ?? '',
      category: categorySnapshot.value.toString() ?? '',
      city: citySnapshot.value.toString() ?? '',
      street: streetSnapshot.value.toString() ?? '',
      house: houseSnapshot.value.toString() ?? '',
      phone: phoneSnapshot.value.toString() ?? '',
      whatsapp: whatsappSnapshot.value.toString() ?? '',
      telegram: telegramSnapshot.value.toString() ?? '',
      instagram: instagramSnapshot.value.toString() ?? '',
      imageUrl: imageUrlSnapshot.value.toString() ?? '',
      mondayStartTime: mondayStartTimeSnapshot.value.toString() ?? '',
      mondayFinishTime: mondayFinishTimeSnapshot.value.toString() ?? '',
      tuesdayStartTime: tuesdayStartTimeSnapshot.value.toString() ?? '',
      tuesdayFinishTime: tuesdayFinishTimeSnapshot.value.toString() ?? '',
      wednesdayStartTime: wednesdayStartTimeSnapshot.value.toString() ?? '',
      wednesdayFinishTime: wednesdayFinishTimeSnapshot.value.toString() ?? '',
      thursdayStartTime: thursdayStartTimeSnapshot.value.toString() ?? '',
      thursdayFinishTime: thursdayFinishTimeSnapshot.value.toString() ?? '',
      fridayStartTime: fridayStartTimeSnapshot.value.toString() ?? '',
      fridayFinishTime: fridayFinishTimeSnapshot.value.toString() ?? '',
      saturdayStartTime: saturdayStartTimeSnapshot.value.toString() ?? '',
      saturdayFinishTime: saturdayFinishTimeSnapshot.value.toString() ?? '',
      sundayFinishTime: sundayFinishTimeSnapshot.value.toString() ?? '',
      sundayStartTime: sundayStartTimeSnapshot.value.toString() ?? ''

    );
  }

  factory Place.empty() {
    return Place(
        id: '',
        name: '',
        desc: '',
        creatorId: '',
        createDate: '',
        category: '',
        city: '',
        street: '',
        house: '',
        phone: '',
        whatsapp: '',
        telegram: '',
        instagram: '',
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7',
        mondayStartTime: '',
        mondayFinishTime: '',
        tuesdayStartTime: '',
        tuesdayFinishTime: '',
        wednesdayStartTime: '',
        wednesdayFinishTime: '',
        thursdayStartTime: '',
        thursdayFinishTime: '',
        fridayStartTime: '',
        fridayFinishTime: '',
        saturdayStartTime: '',
        saturdayFinishTime: '',
        sundayStartTime: '',
        sundayFinishTime: ''
    );
  }

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  // Метод для добавления нового пола или редактирования пола в Firebase

  // --- ФУНКЦИЯ ЗАПИСИ ДАННЫХ Места -----
  static Future<String?> createOrEditPlace(Place place) async {

    try {

      String placePath = 'places/${place.id}/place_info';

      // Записываем данные пользователя в базу данных
      await FirebaseDatabase.instance.ref().child(placePath).set({
        'id': place.id,
        'name': place.name,
        'desc': place.desc,
        'creatorId': place.creatorId,
        'createDate': place.createDate,
        'category': place.category,
        'city': place.city,
        'street': place.street,
        'house': place.house,
        'phone': place.phone,
        'whatsapp': place.whatsapp,
        'telegram': place.telegram,
        'instagram': place.instagram,
        'imageUrl': place.imageUrl,
        'mondayStartTime': place.mondayStartTime,
        'mondayFinishTime': place.mondayFinishTime,
        'tuesdayStartTime': place.tuesdayStartTime,
        'tuesdayFinishTime': place.tuesdayFinishTime,
        'wednesdayFinishTime': place.wednesdayFinishTime,
        'wednesdayStartTime': place.wednesdayStartTime,
        'thursdayStartTime': place.thursdayStartTime,
        'thursdayFinishTime': place.thursdayFinishTime,
        'fridayStartTime': place.fridayStartTime,
        'fridayFinishTime': place.fridayFinishTime,
        'saturdayStartTime': place.saturdayStartTime,
        'saturdayFinishTime': place.saturdayFinishTime,
        'sundayStartTime': place.sundayStartTime,
        'sundayFinishTime': place.sundayFinishTime,

      });

      // Если успешно
      return 'success';

    } catch (e) {
      // Если ошибки
      // TODO Сделать обработку ошибок. Наверняка есть какие то, которые можно различать и писать что случилось
      print('Error writing user data: $e');
      return 'Failed to write user data. Error: $e';
    }
  }

  static Future<List<Place>> getAllPlaces() async {

    List<Place> places = [];

    // Указываем путь
    final DatabaseReference reference = FirebaseDatabase.instance.ref().child('places');

    // Получаем снимок данных папки
    DataSnapshot snapshot = await reference.get();

    // Итерируем по каждому дочернему элементу
    // Здесь сделано так потому что мы не знаем ключа города
    // и нам нужен каждый город, независимо от ключа

    for (var childSnapshot in snapshot.children) {
      // заполняем город (City.fromSnapshot) из снимка данных
      // и обавляем в список городов

      places.add(Place.fromSnapshot(childSnapshot.child('place_info')));
    }

    // sortCitiesByName(places, order);

    // Возвращаем список
    return places;
  }

}