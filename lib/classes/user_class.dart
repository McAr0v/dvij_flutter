class User {
  String uid;
  String role;
  String name;
  String lastname;
  String phone;
  String whatsapp;
  String telegram;
  String instagram;
  String city;
  String birthDate; // Формат даты (например, "yyyy-MM-dd")
  String sex;
  String avatar;

  User({
    required this.uid,
    required this.role,
    required this.name,
    required this.lastname,
    required this.phone,
    required this.whatsapp,
    required this.telegram,
    required this.instagram,
    required this.city,
    required this.birthDate,
    required this.sex,
    required this.avatar,
  });
}