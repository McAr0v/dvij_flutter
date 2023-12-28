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

  // --- ИНИЦИАЛИЗИРУЕМ БАЗУ ДАННЫХ -----
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

}