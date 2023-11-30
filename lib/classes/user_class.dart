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

  factory User.empty(String uid) {
    return User(
      uid: uid,
      role: '1113',
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: '',
      birthDate: '',
      sex: '',
      avatar: 'https://firebasestorage.googleapis.com/v0/b/dvij-flutter.appspot.com/o/avatars%2Fdvij_unknow_user.jpg?alt=media&token=b63ea5ef-7bdf-49e9-a3ef-1d34d676b6a7'
    );
  }

}