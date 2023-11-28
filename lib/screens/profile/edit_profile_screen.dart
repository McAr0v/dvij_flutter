import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dvij_flutter/database_firebase/user_database.dart';
import 'package:dvij_flutter/elements/custom_button.dart';
import '../../classes/user_class.dart' as local_user;
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../elements/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_Uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final local_user.User userInfo;

  const EditProfileScreen({Key? key, required this.userInfo}) : super(key: key);



  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();

}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePickerService imagePickerService = ImagePickerService();
  final ImageUploader imageUploader = ImageUploader();
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
  File? _imageFile;
  bool loading = true;

  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Profile',
          (route) => false,
    );
  }

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(
      message: message,
      backgroundColor: color,
      showTime: showTime,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _pickImage() async {
    final File? pickedImage = await imagePickerService.pickImage(ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
        avatarController.text = _imageFile!.path;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    loading = true;
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
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
      ),
      body: Stack (
          children: [
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
            else SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                if (_imageFile != null) ImageInEditScreen(

                      backgroundImageFile: _imageFile,
                      onEditPressed: () => _pickImage()
                  )
                  else if (_imageFile == null && widget.userInfo.avatar != '' ) ImageInEditScreen(
                    onEditPressed: () => _pickImage(),
                    backgroundImageUrl: widget.userInfo.avatar,
                  ),

                  const SizedBox(height: 16.0),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Телефон',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.phone,
                    controller: whatsappController,
                    decoration: const InputDecoration(
                      labelText: 'Whatsapp',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: telegramController,
                    decoration: const InputDecoration(
                      labelText: 'Telegram',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Город',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.datetime,
                    controller: birthdateController,
                    decoration: const InputDecoration(
                      labelText: 'Дата рождения',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: sexController,
                    decoration: const InputDecoration(
                      labelText: 'Пол',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),

                  const SizedBox(height: 16.0),


                  CustomButton(
                    buttonText: 'Опубликовать',
                    onTapMethod: () async {
                      setState(() {
                        loading = true;
                      });
                      String? avatarURL;
                      if (_imageFile != null) {

                        //final File imageFile = File(_imageFile!.path);
                        final compressedImage = await imagePickerService.compressImage(_imageFile!);

                        avatarURL = await imageUploader.uploadImageInProfile(widget.userInfo.uid, compressedImage);

                      }

                      if (avatarURL != null) {

                        local_user.User updatedUser = local_user.User(
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
                          avatar: avatarURL,
                        );

                        String? editInDatabase = await userDatabase.writeUserData(updatedUser);

                        if (editInDatabase == 'success') {
                          setState(() {
                            loading = false;
                          });
                          showSnackBar(
                            "Прекрасно! Данные отредактированы!",
                            Colors.green,
                            5,
                          );

                          navigateToProfile();

                        }


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
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
              ]
              )
    );
  }
}