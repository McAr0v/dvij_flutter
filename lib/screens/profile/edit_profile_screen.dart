import 'dart:io';
import 'package:dvij_flutter/current_user/app_role.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/elements/date_elements/data_picker.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../cities/cities_elements/city_element_in_edit_screen.dart';
import '../../cities/city_class.dart';
import '../../current_user/genders_class.dart';
import '../../current_user/user_class.dart' as local_user;
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets_global/images/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';

class EditProfileScreen extends StatefulWidget {

  final local_user.UserCustom userInfo;

  const EditProfileScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class EditProfileScreenState extends State<EditProfileScreen> {

  // Инициализируем классы
  final ImagePickerService imagePickerService = ImagePickerService();
  final ImageUploader imageUploader = ImageUploader();

  late TextEditingController nameController;
  late TextEditingController lastnameController;
  late TextEditingController phoneController;
  late TextEditingController whatsappController;
  late TextEditingController instagramController;
  late TextEditingController telegramController;
  late TextEditingController cityController;
  late TextEditingController genderController;
  late TextEditingController avatarController;
  late City chosenCity;
  late Genders chosenGender;
  late DateTime selectedDate;
  late DateTime registrationDate;
  late AppRole appRole;

  File? _imageFile;
  bool loading = true;

  List<City> _cities = [];

  Future<void> _selectDate(BuildContext context, {bool needClearInitialDate = false}) async {
    DateTime initial = selectedDate;
    if (needClearInitialDate) initial = DateTime.now();

    final DateTime? picked = await showDatePicker(

      locale: const Locale('ru', 'RU'),
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Выбери дату',
      cancelText: 'Отмена',
      confirmText: 'Подтвердить',
      keyboardType: TextInputType.datetime,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }

  }

  // --- Функция перехода на страницу профиля ----

  void navigateToProfile() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Profile',
          (route) => false,
    );
  }

  // ----- Отображение всплывающего сообщения ----

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(
      message: message,
      backgroundColor: color,
      showTime: showTime,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ------ Функция выбора изображения -------

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
    cityController = TextEditingController(text: widget.userInfo.city.name);

    if (widget.userInfo.birthDate != DateTime(2100)) {
      selectedDate = widget.userInfo.birthDate;
    } else {
      selectedDate = DateTime(2100);
    }

    if (widget.userInfo.registrationDate != DateTime(2100)){
      registrationDate = widget.userInfo.registrationDate;
    } else {
      registrationDate = DateTime.now();
    }

    genderController = TextEditingController(text: widget.userInfo.gender.getGenderString(needTranslate: true));
    avatarController = TextEditingController(text: widget.userInfo.avatar);

    _cities = City.currentCityList;

    chosenCity = widget.userInfo.city;
    chosenGender = widget.userInfo.gender;
    appRole = widget.userInfo.role;

    setState(() {
      loading = false;
    });

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование профиля'),
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

                  // Новая картинка
                  if (_imageFile != null) ImageInEditScreen(

                      backgroundImageFile: _imageFile,
                      onEditPressed: () => _pickImage()
                  )

                  // Картинка из БД
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
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Фамилия',
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Телефон',
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.phone,
                    controller: whatsappController,
                    decoration: const InputDecoration(
                      labelText: 'Whatsapp',
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: telegramController,
                    decoration: const InputDecoration(
                      labelText: 'Telegram',
                    ),
                  ),

                  const SizedBox(height: 16.0),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram',
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  CityElementInEditScreen(
                    cityName: chosenCity.name,
                    onActionPressed: () {
                      //_showCityPickerDialog();
                      _showCityPickerDialog();
                    },
                  ),

                  const SizedBox(height: 16.0),

                  if (selectedDate == DateTime(2100))
                    DataPickerCustom(
                      onActionPressed: () {
                      _selectDate(context, needClearInitialDate: true);
                      },
                      date: 'Дата не выбрана',
                      labelText: 'Дата рождения',
                      )

                  else DataPickerCustom(
                      onActionPressed: () {
                        _selectDate(context);
                      },
                    date: DateMixin.getHumanDate('${selectedDate.year}-${selectedDate.month}-${selectedDate.day}', '-'),
                      labelText: 'Дата рождения'
                  ),

                  const SizedBox(height: 16.0),

                  GenderElementInEditScreen(
                    genderName: chosenGender.getGenderString(needTranslate: true),
                    onActionPressed: () {
                      _showGenderPickerDialog();
                    },
                  ),

                  const SizedBox(height: 40.0),

                  // --- КНОПКА Сохранить изменения -------

                  CustomButton(
                    buttonText: 'Сохранить изменения',
                    onTapMethod: () async {

                      // Включаем экран загрузки
                      setState(() {
                        loading = true;
                      });

                      // Создаем переменную для нового аватара
                      String? avatarURL;

                      // ---- ЕСЛИ ВЫБРАНА НОВАЯ КАРТИНКА -------
                      if (_imageFile != null) {

                        // Сжимаем изображение
                        final compressedImage = await imagePickerService.compressImage(_imageFile!);

                        // Выгружаем изображение в БД и получаем URL картинки
                        avatarURL = await imageUploader.uploadImage(widget.userInfo.uid, compressedImage, ImageFolderEnum.users);

                        // Если URL аватарки есть
                        if (avatarURL != null) {
                          showSnackBar(
                            "Изображение загружено",
                            Colors.green,
                            1,
                          );
                        } else {
                          showSnackBar(
                            "Изображение загружено",
                            Colors.green,
                            1,
                          );
                        }
                      }

                      // Заполняем пользователя
                      local_user.UserCustom updatedUser = local_user.UserCustom(
                        uid: widget.userInfo.uid,
                        email: widget.userInfo.email,
                        role: appRole,
                        name: nameController.text,
                        lastname: lastnameController.text,
                        phone: phoneController.text,
                        whatsapp: whatsappController.text,
                        telegram: telegramController.text,
                        instagram: instagramController.text,
                        city: chosenCity,
                        birthDate: selectedDate,
                        gender: chosenGender,
                        avatar: avatarURL ?? widget.userInfo.avatar,
                        registrationDate: registrationDate,
                        myPlaces: widget.userInfo.myPlaces,
                      );

                      // Выгружаем пользователя в БД
                      String? editInDatabase = await updatedUser.publishUserToDb();

                      // Если выгрузка успешна
                      if (editInDatabase == 'success') {

                        // Выключаем экран загрузки
                        setState(() {
                          loading = false;
                        });
                        // Показываем всплывающее сообщение
                        showSnackBar(
                          "Прекрасно! Данные отредактированы!",
                          Colors.green,
                          1,
                        );

                        // Уходим в профиль
                        navigateToProfile();

                      }

                    },
                  ),
                  const SizedBox(height: 16.0),
                  CustomButton(
                    state: CustomButtonState.error,
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

  void _showCityPickerDialog() async {
    final selectedCity = await Navigator.of(context).push(_createPopup(_cities));

    if (selectedCity != null) {
      setState(() {
        chosenCity = selectedCity;
      });
    }
  }

  void _showGenderPickerDialog() async {
    final selectedGender = await Navigator.of(context).push(_createPopupGender());

    if (selectedGender != null) {
      setState(() {
        chosenGender = selectedGender;
      });
    }
  }

  Route _createPopup(List<City> cities) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return CityPickerPage(cities: cities);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 100),

    );
  }

  Route _createPopupGender() {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return const GenderPickerPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 100),

    );
  }



}