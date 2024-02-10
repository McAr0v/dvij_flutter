import 'dart:io';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../cities/cities_elements/city_element_in_edit_screen.dart';
import '../../cities/city_class.dart';
import '../../classes/role_in_app.dart';
import '../../classes/user_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../elements/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_Uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';
import '../places_elements/place_category_picker_page.dart';

class CreateOrEditPlaceScreen extends StatefulWidget {
  final Place placeInfo;

  const CreateOrEditPlaceScreen({Key? key, required this.placeInfo}) : super(key: key);



  @override
  CreateOrEditPlaceScreenState createState() => CreateOrEditPlaceScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class CreateOrEditPlaceScreenState extends State<CreateOrEditPlaceScreen> {

  // Инициализируем классы
  final ImagePickerService imagePickerService = ImagePickerService();
  final ImageUploader imageUploader = ImageUploader();

  late TextEditingController nameController;
  late TextEditingController descController;
  late City chosenCity;
  late TextEditingController streetController;
  late TextEditingController houseController;
  late TextEditingController phoneController;
  late TextEditingController whatsappController;
  late TextEditingController instagramController;
  late TextEditingController telegramController;
  late TextEditingController cityController;
  late TextEditingController imageController;


  late String placeId;
  late String creatorId;
  late String createdTime;

  String mondayStartTime = 'Выходной';
  String mondayFinishTime = 'Выходной';
  String tuesdayStartTime = 'Выходной';
  String tuesdayFinishTime = 'Выходной';
  String wednesdayStartTime = 'Выходной';
  String wednesdayFinishTime = 'Выходной';
  String thursdayStartTime = 'Выходной';
  String thursdayFinishTime = 'Выходной';
  String fridayStartTime = 'Выходной';
  String fridayFinishTime = 'Выходной';
  String saturdayStartTime = 'Выходной';
  String saturdayFinishTime = 'Выходной';
  String sundayStartTime = 'Выходной';
  String sundayFinishTime = 'Выходной';

  File? _imageFile;

  late DateTime selectedDate;
  late RoleInApp chosenRoleInApp;
  late int accessLevel;

  // ПЕРЕМЕННЫЕ ВРЕМЕНИ РАБОТЫ?

  bool loading = true;

  List<City> _cities = [];
  List<PlaceCategory> _categories = [];
  late PlaceCategory chosenCategory;

  /*String _selectedStartTime = "Выходной";
  String _selectedEndTime = "Выходной";*/

  final List<String> _timeList = [
    "Выходной",
    "00:00",
    "00:30",
    "01:00",
    "01:30",
    "02:00",
    "02:30",
    "03:00",
    "03:30",
    "04:00",
    "04:30",
    "05:00",
    "05:30",
    "06:00",
    "06:30",
    "07:00",
    "07:30",
    "08:00",
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00",
    "17:30",
    "18:00",
    "18:30",
    "19:00",
    "19:30",
    "20:00",
    "20:30",
    "21:00",
    "21:30",
    "22:00",
    "22:30",
    "23:00",
    "23:30",
    // Добавьте необходимые значения времени
  ];


  // --- Функция перехода на страницу профиля ----

  void navigateToPlaces() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Places',
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
        imageController.text = _imageFile!.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loading = true;
    _categories = PlaceCategory.currentPlaceCategoryList;

    accessLevel = UserCustom.accessLevel;

    if (widget.placeInfo.id == '') {

      DatabaseReference placeReference = FirebaseDatabase.instance.ref().child('places');

      // --- Генерируем уникальный ключ ---
      DatabaseReference newPlaceReference = placeReference.push();
      // ---- Получаем уникальный ключ ----
      placeId = newPlaceReference.key!; // Получаем уникальный ключ

    } else {

      placeId = widget.placeInfo.id;

    }

    if (widget.placeInfo.creatorId == '') {

      creatorId = UserCustom.currentUser!.uid;

    } else {

      creatorId = widget.placeInfo.creatorId;

    }

    if (widget.placeInfo.createDate == ''){
      DateTime now = DateTime.now();
      createdTime = '${now.day}.${now.month}.${now.year}';
    }
    else {
      createdTime = widget.placeInfo.createDate;
    }

    // Подгружаем в контроллеры содержимое из БД.
    Future.delayed(Duration.zero, () async {

      //category = '';
      nameController = TextEditingController(text: widget.placeInfo.name);
      descController = TextEditingController(text: widget.placeInfo.desc);

      phoneController = TextEditingController(text: widget.placeInfo.phone);
      whatsappController = TextEditingController(text: widget.placeInfo.whatsapp);
      telegramController = TextEditingController(text: widget.placeInfo.telegram);
      instagramController = TextEditingController(text: widget.placeInfo.instagram);
      cityController = TextEditingController(text: widget.placeInfo.city);
      streetController = TextEditingController(text: widget.placeInfo.street);
      houseController = TextEditingController(text: widget.placeInfo.house);

      imageController = TextEditingController(text: widget.placeInfo.imageUrl);

      _cities = City.currentCityList;
      _categories = PlaceCategory.currentPlaceCategoryList;

      chosenCategory = PlaceCategory.getPlaceCategoryFromCategoriesList(widget.placeInfo.category);

      chosenCity = City.getCityByIdFromList(widget.placeInfo.city);

      if (widget.placeInfo.mondayStartTime != '')
        {
          mondayStartTime = widget.placeInfo.mondayStartTime;
        }
      if (widget.placeInfo.mondayFinishTime != '')
        {
          mondayFinishTime = widget.placeInfo.mondayFinishTime;
        }

      if (widget.placeInfo.tuesdayStartTime != '')
      {
        tuesdayStartTime = widget.placeInfo.tuesdayStartTime;
      }
      if (widget.placeInfo.tuesdayFinishTime != '')
      {
        tuesdayFinishTime = widget.placeInfo.tuesdayFinishTime;
      }

      if (widget.placeInfo.wednesdayStartTime != '')
      {
        wednesdayStartTime = widget.placeInfo.wednesdayStartTime;
      }
      if (widget.placeInfo.wednesdayFinishTime != '')
      {
        wednesdayFinishTime = widget.placeInfo.wednesdayFinishTime;
      }

      if (widget.placeInfo.thursdayStartTime != '')
      {
        thursdayStartTime = widget.placeInfo.thursdayStartTime;
      }
      if (widget.placeInfo.thursdayFinishTime != '')
      {
        thursdayFinishTime = widget.placeInfo.thursdayFinishTime;
      }

      if (widget.placeInfo.fridayStartTime != '')
      {
        fridayStartTime = widget.placeInfo.fridayStartTime;
      }
      if (widget.placeInfo.fridayFinishTime != '')
      {
        fridayFinishTime = widget.placeInfo.fridayFinishTime;
      }

      if (widget.placeInfo.saturdayStartTime != '')
      {
        saturdayStartTime = widget.placeInfo.saturdayStartTime;
      }
      if (widget.placeInfo.saturdayFinishTime != '')
      {
        saturdayFinishTime = widget.placeInfo.saturdayFinishTime;
      }

      if (widget.placeInfo.sundayStartTime != '')
      {
        sundayStartTime = widget.placeInfo.sundayStartTime;
      }
      if (widget.placeInfo.sundayFinishTime != '')
      {
        sundayFinishTime = widget.placeInfo.sundayFinishTime;
      }

      /*if (widget.placeInfo.category != '')
        {
          category = PlaceCategory.getPlaceCategoryName(widget.placeInfo.category);
        }*/

      setState(() {
        loading = false;
      });
    });
  }

  Widget _buildTimeDropdown(
      String label, String selectedTime, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedTime,
          onChanged: onChanged,
          items: _timeList.map((String time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time),
            );
          }).toList(),
        ),
        Text(label, style: Theme.of(context).textTheme.labelMedium,),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.placeInfo.id != '' ? 'Редактирование места' : 'Создание места'),
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
                    else if (_imageFile == null && widget.placeInfo.imageUrl != '' ) ImageInEditScreen(
                      onEditPressed: () => _pickImage(),
                      backgroundImageUrl: widget.placeInfo.imageUrl,
                    ),

                    const SizedBox(height: 16.0),

                    const SizedBox(height: 16.0),
                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.text,
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название места',
                      ),
                    ),

                    const SizedBox(height: 16.0),
                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.multiline,
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onEditingComplete: () {
                        // Обработка события, когда пользователь нажимает Enter
                        // Вы можете добавить здесь любой код, который нужно выполнить при нажатии Enter
                      },
                    ),

                    const SizedBox(height: 16.0),

                    if (chosenCity.id == '') CityElementInEditScreen(
                      cityName: 'Город не выбран',
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showCityPickerDialog();
                      },
                    ),

                    if (chosenCity.id != "") CityElementInEditScreen(
                      cityName: chosenCity.name,
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showCityPickerDialog();
                      },
                    ),

                    const SizedBox(height: 16.0),

                    // ---- ВОТ ТУТ ДЕЛАЮ ----

                    if (chosenCategory.id == '') CategoryElementInEditScreen(
                      categoryName: 'Категория не выбрана',
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showCategoryPickerDialog();
                      },
                    ),

                    if (chosenCategory.id != "") CategoryElementInEditScreen(
                      categoryName: chosenCategory.name,
                      onActionPressed: () {
                        //_showCityPickerDialog();
                        _showCategoryPickerDialog();
                      },
                    ),

                    const SizedBox(height: 16.0),

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.text,
                      controller: streetController,
                      decoration: const InputDecoration(
                        labelText: 'Улица',
                      ),
                    ),

                    const SizedBox(height: 16.0),
                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.text,
                      controller: houseController,
                      decoration: const InputDecoration(
                        labelText: 'Номер дома',
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

                    const SizedBox(height: 30.0),

                    Text('Режим работы:', style: Theme.of(context).textTheme.titleMedium,),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('ПН:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", mondayStartTime, (String? time) {
                          setState(() {
                            mondayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", mondayFinishTime, (String? time) {
                          setState(() {
                            mondayFinishTime = time!;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('ВТ:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", tuesdayStartTime, (String? time) {
                          setState(() {
                            tuesdayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", tuesdayFinishTime, (String? time) {
                          setState(() {
                            tuesdayFinishTime = time!;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('СР:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", wednesdayStartTime, (String? time) {
                          setState(() {
                            wednesdayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", wednesdayFinishTime, (String? time) {
                          setState(() {
                            wednesdayFinishTime = time!;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('ЧТ:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", thursdayStartTime, (String? time) {
                          setState(() {
                            thursdayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", thursdayFinishTime, (String? time) {
                          setState(() {
                            thursdayFinishTime = time!;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('ПТ:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", fridayStartTime, (String? time) {
                          setState(() {
                            fridayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", fridayFinishTime, (String? time) {
                          setState(() {
                            fridayFinishTime = time!;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('СБ:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", saturdayStartTime, (String? time) {
                          setState(() {
                            saturdayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", saturdayFinishTime, (String? time) {
                          setState(() {
                            saturdayFinishTime = time!;
                          });
                        }),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('ВС:', style: Theme.of(context).textTheme.bodyMedium,),
                        SizedBox(width: 20.0),
                        _buildTimeDropdown("Начало рабочего дня", sundayStartTime, (String? time) {
                          setState(() {
                            sundayStartTime = time!;
                          });
                        }),
                        SizedBox(width: 30.0),
                        _buildTimeDropdown("Конец рабочего дня", sundayFinishTime, (String? time) {
                          setState(() {
                            sundayFinishTime = time!;
                          });
                        }),
                      ],
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
                          avatarURL = await ImageUploader.uploadImageInPlace(placeId, compressedImage);

                          // Если URL аватарки есть
                          if (avatarURL != null) {
                            // TODO: Сделать вывод какой-то, что картинка загружена
                          } else {
                            // TODO: Сделать обработку ошибок, если не удалось загрузить картинку в базу данных пользователя
                          }
                        }

                        Place place = Place(
                            id: placeId,
                            name: nameController.text,
                            desc: descController.text,
                            creatorId: creatorId,
                            createDate: createdTime,
                            category: chosenCategory.id,
                            city: chosenCity.id,
                            street: streetController.text,
                            house: houseController.text,
                            phone: phoneController.text,
                            whatsapp: whatsappController.text,
                            telegram: telegramController.text,
                            instagram: instagramController.text,
                            imageUrl: avatarURL ?? widget.placeInfo.imageUrl,
                            mondayStartTime: mondayStartTime,
                            mondayFinishTime: mondayFinishTime,
                            tuesdayStartTime: tuesdayStartTime,
                            tuesdayFinishTime: tuesdayFinishTime,
                            wednesdayStartTime: wednesdayStartTime,
                            wednesdayFinishTime: wednesdayFinishTime,
                            thursdayStartTime: thursdayStartTime,
                            thursdayFinishTime: thursdayFinishTime,
                            fridayStartTime: fridayStartTime,
                            fridayFinishTime: fridayFinishTime,
                            saturdayStartTime: saturdayStartTime,
                            saturdayFinishTime: saturdayFinishTime,
                            sundayStartTime: sundayStartTime,
                            sundayFinishTime: sundayFinishTime
                        );

                        // Выгружаем пользователя в БД
                        String? editInDatabase = await Place.createOrEditPlace(place);

                        // Если выгрузка успешна
                        if (editInDatabase == 'success') {

                          Place newPlace = await Place.getPlaceById(placeId);

                          // Если в передаваемом месте нет имени, т.е это создание
                          if (widget.placeInfo.name == ''){
                            // То добавляем в списки новое созданное место
                            Place.currentFeedPlaceList.add(newPlace);
                            Place.currentMyPlaceList.add(newPlace);
                          } else {


                            // Если редактирование то удаляем старые неотредактированные данные
                            Place.deletePlaceFormCurrentPlaceLists(placeId);

                            // Добавляем обновленное
                            Place.currentFeedPlaceList.add(newPlace);
                            Place.currentMyPlaceList.add(newPlace);
                            if (bool.parse(newPlace.inFav!)) Place.currentFavPlaceList.add(newPlace);

                          }



                          // Выключаем экран загрузки
                          setState(() {
                            loading = false;
                          });
                          // Показываем всплывающее сообщение
                          showSnackBar(
                            "Прекрасно! Данные опубликованы!",
                            Colors.green,
                            1,
                          );

                          // Уходим в профиль
                          navigateToPlaces();

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

  void _showCategoryPickerDialog() async {
    final selectedCategory = await Navigator.of(context).push(_createPopupCategory(_categories));

    if (selectedCategory != null) {
      setState(() {
        chosenCategory = selectedCategory;
      });
      print("Selected category: ${selectedCategory.name}, ID: ${selectedCategory.id}");
    }
  }

  Route _createPopupCategory(List<PlaceCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return PlaceCategoryPickerPage(categories: categories);
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