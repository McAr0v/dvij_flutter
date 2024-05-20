import 'dart:io';
import 'package:dvij_flutter/classes/gender_class.dart';
import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/elements/date_elements/data_picker.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_picker_page.dart';
import 'package:dvij_flutter/elements/role_in_app_elements/role_in_app_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/role_in_app_elements/role_in_app_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../cities/cities_elements/city_element_in_edit_screen.dart';
import '../../cities/city_class.dart';
import '../../classes/genders_class.dart';
import '../../classes/role_in_app.dart';
import '../../classes/user_class.dart' as local_user;
import '../../classes/user_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets_global/images/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_Uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final local_user.UserCustom userInfo;

  const EditProfileScreen({Key? key, required this.userInfo}) : super(key: key);



  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class _EditProfileScreenState extends State<EditProfileScreen> {

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
  //late Gender chosenGender;
  late Genders chosenGender;
  late DateTime selectedDate;
  late DateTime registrationDate;
  late RoleInApp chosenRoleInApp;
  late int accessLevel;

  File? _imageFile;
  bool loading = true;

  List<City> _cities = [];
  List<Gender> _genders = [];
  List<RoleInApp> _rolesInApp = [];

  // DateTime selectedDate = DateTime.now();

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

    accessLevel = UserCustom.accessLevel;

    // Подгружаем в контроллеры содержимое из БД.
    Future.delayed(Duration.zero, () async {
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

      //genderController = TextEditingController(text: widget.userInfo.gender);
      genderController = TextEditingController(text: widget.userInfo.gender.getGenderString(needTranslate: true));
      avatarController = TextEditingController(text: widget.userInfo.avatar);

      _cities = City.currentCityList;
      _genders = Gender.currentGenderList;
      _rolesInApp = RoleInApp.currentRoleInAppList;

      chosenCity = widget.userInfo.city;
      //chosenGender = await Gender.getGenderById(widget.userInfo.gender) as Gender;
      chosenGender = widget.userInfo.gender;
      chosenRoleInApp = await RoleInApp.getRoleInAppById(widget.userInfo.role) as RoleInApp;

      setState(() {
        loading = false;
      });
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
                      //_showCityPickerDialog();
                      _showGenderPickerDialog();
                    },
                  ),

                  if (UserCustom.accessLevel >= 100) const SizedBox(height: 16.0),

                  if (UserCustom.accessLevel >= 100) RoleInAppElementInEditScreen(
                      onActionPressed: _showRoleInAppPickerDialog,
                    roleInAppName: chosenRoleInApp.name,
                  ),

                  /*TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: genderController,
                    decoration: const InputDecoration(
                      labelText: 'Пол',
                      //prefixIcon: Icon(Icons.email),
                    ),
                  ),*/

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
                        avatarURL = await imageUploader.uploadImageInProfile(widget.userInfo.uid, compressedImage);

                        // Если URL аватарки есть
                        if (avatarURL != null) {
                          // TODO: Сделать вывод какой-то, что картинка загружена
                        } else {
                          // TODO: Сделать обработку ошибок, если не удалось загрузить картинку в базу данных пользователя
                        }
                      }

                      // Заполняем пользователя
                      local_user.UserCustom updatedUser = local_user.UserCustom(
                        uid: widget.userInfo.uid,
                        email: widget.userInfo.email,
                        role: chosenRoleInApp.id,
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
                        myEvents: widget.userInfo.myEvents,
                        myPromos: widget.userInfo.myPromos,
                        myPlaces: widget.userInfo.myPlaces,
                        favEvents: widget.userInfo.favEvents,
                        favPlaces: widget.userInfo.favPlaces,
                        favPromos: widget.userInfo.favPromos
                      );

                      // Выгружаем пользователя в БД
                      String? editInDatabase = await UserCustom.writeUserData(updatedUser);

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
                    state: 'error',
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
      print("Selected city: ${selectedCity.name}, ID: ${selectedCity.id}");
    }
  }

  void _showGenderPickerDialog() async {
    final selectedGender = await Navigator.of(context).push(_createPopupGender());

    if (selectedGender != null) {
      setState(() {
        chosenGender = selectedGender;
      });
      //print("Selected gender: ${selectedGender.name}, ID: ${selectedGender.id}");
    }
  }

  void _showRoleInAppPickerDialog() async {
    final selectedRoleInApp = await Navigator.of(context).push(_createPopupRoleInApp(_rolesInApp));

    if (selectedRoleInApp != null) {
      setState(() {
        chosenRoleInApp = selectedRoleInApp;
      });
      print("Selected roleInApp: ${selectedRoleInApp.name}, ID: ${selectedRoleInApp.id}");
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
      transitionDuration: Duration(milliseconds: 100),

    );
  }

  Route _createPopupGender() {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return GenderPickerPage();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 100),

    );
  }

  Route _createPopupRoleInApp(List<RoleInApp> roleInApp) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return RoleInAppPickerPage(rolesInApp: roleInApp);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 100),

    );
  }

}