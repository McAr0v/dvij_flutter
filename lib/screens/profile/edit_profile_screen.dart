import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/database_firebase/user_database.dart';
import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/elements/pop_up_dialog.dart';
import '../../authentication/auth_with_email.dart';
import '../../classes/user_class.dart' as local_user;
import '../../elements/custom_snack_bar.dart';

class EditProfileScreen extends StatefulWidget {
  final local_user.User userInfo;

  const EditProfileScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController lastnameController;
  late TextEditingController phoneController;
  late TextEditingController whatsappController;
  late TextEditingController instagramController;
  late TextEditingController telegramController;
  late TextEditingController cityController;
  late TextEditingController birthdateController;
  late TextEditingController sexController;
  late TextEditingController avatarController;
  final UserDatabase userDatabase = UserDatabase();
  // Добавьте другие контроллеры для полей, которые вы хотите редактировать

  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Profile', // Название маршрута, которое вы задаете в MaterialApp
          (route) => false,
    );
  }

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userInfo.name);
    lastnameController = TextEditingController(text: widget.userInfo.lastname);
    phoneController = TextEditingController(text: widget.userInfo.phone);
    whatsappController = TextEditingController(text: widget.userInfo.whatsapp);
    telegramController = TextEditingController(text: widget.userInfo.telegram);
    instagramController = TextEditingController(text: widget.userInfo.instagram);
    cityController = TextEditingController(text: widget.userInfo.city);
    birthdateController = TextEditingController(text: widget.userInfo.birthDate);
    sexController = TextEditingController(text: widget.userInfo.sex);
    avatarController = TextEditingController(text: widget.userInfo.avatar);
    // Инициализируйте остальные контроллеры для других полей
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать профиль'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Добавьте поля для редактирования
            buildTextField('Имя', nameController),
            const SizedBox(height: 16.0),
            buildTextField('Фамилия', lastnameController),
            const SizedBox(height: 16.0),
            buildTextField('Телефон', phoneController),
            const SizedBox(height: 16.0),
            buildTextField('Whatsapp', whatsappController),
            const SizedBox(height: 16.0),
            buildTextField('Telegram', telegramController),
            const SizedBox(height: 16.0),
            buildTextField('Instagram', instagramController),
            const SizedBox(height: 16.0),
            buildTextField('Город', cityController),
            const SizedBox(height: 16.0),
            buildTextField('Дата рождения', birthdateController),
            const SizedBox(height: 16.0),
            buildTextField('Пол', sexController),
            const SizedBox(height: 16.0),
            buildTextField('Аватар', avatarController),

            // Добавьте другие поля для редактирования

            const SizedBox(height: 16.0),
            CustomButton(
              buttonText: 'Опубликовать',
              onTapMethod: () async {

                String? editInDatabase = await userDatabase.writeUserData(local_user.User(
                    uid: widget.userInfo.uid,
                    role: widget.userInfo.role,
                    name: nameController.text,
                    lastname: lastnameController.text,
                    phone: phoneController.text,
                    whatsapp: whatsappController.text,
                    telegram: telegramController.text,
                    instagram: instagramController.text,
                    city: cityController.text,
                    birthDate: birthdateController.text,
                    sex: sexController.text,
                    avatar: avatarController.text
                ));

                if (editInDatabase == 'success'){

                  showSnackBar(
                      "Прекрасно! Данные отредактированы!",
                      Colors.green,
                      5
                  );

                  navigateToProfile();

                } else {

                  // TODO: Сделать обработку ошибок, если не удалось загрузить в базу данных пользователя

                }
              },
            ),
            const SizedBox(height: 16.0),
            CustomButton(
              state: 'secondary',
              buttonText: 'Отмена',
              onTapMethod: () {
                Navigator.pop(context); // Возвращаемся на предыдущий экран без сохранения изменений
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

}