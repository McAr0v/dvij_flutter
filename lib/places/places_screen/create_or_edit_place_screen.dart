import 'dart:io';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../cities/cities_elements/city_element_in_edit_screen.dart';
import '../../cities/city_class.dart';
import '../../current_user/user_class.dart';
import '../../dates/regular_date_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets_global/images/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../elements/types_of_date_time_pickers/regular_two_type_date_time_picker_widget.dart';
import '../../image_uploader/image_uploader.dart';
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
  late DateTime createdTime;

  List<String> regularStartTimes = TimeMixin.fillTimeListWithDefaultValues('Не выбрано', 7);
  List<String> regularFinishTimes = TimeMixin.fillTimeListWithDefaultValues('Не выбрано', 7);

  File? _imageFile;

  late DateTime selectedDate;

  // ПЕРЕМЕННЫЕ ВРЕМЕНИ РАБОТЫ?

  bool loading = true;

  List<City> _cities = [];
  List<PlaceCategory> _categories = [];
  late PlaceCategory chosenCategory;

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

    // Получаем или генерируем ключ
    if (widget.placeInfo.id == '') {
      placeId = MixinDatabase.generateKey()!;
    } else {
      placeId = widget.placeInfo.id;
    }

    // Получаем Id создателя
    if (widget.placeInfo.creatorId == '') {
      creatorId = UserCustom.currentUser!.uid;
    } else {
      creatorId = widget.placeInfo.creatorId;
    }

    // Устанавливаем дату создания
    if (widget.placeInfo.createDate == DateTime(2100)){
      createdTime = DateTime.now();
    }
    else {
      createdTime = widget.placeInfo.createDate;
    }

    // Подгружаем в контроллеры содержимое из БД.

    nameController = TextEditingController(text: widget.placeInfo.name);
    descController = TextEditingController(text: widget.placeInfo.desc);

    phoneController = TextEditingController(text: widget.placeInfo.phone);
    whatsappController = TextEditingController(text: widget.placeInfo.whatsapp);
    telegramController = TextEditingController(text: widget.placeInfo.telegram);
    instagramController = TextEditingController(text: widget.placeInfo.instagram);
    cityController = TextEditingController(text: widget.placeInfo.city.name);
    streetController = TextEditingController(text: widget.placeInfo.street);
    houseController = TextEditingController(text: widget.placeInfo.house);

    imageController = TextEditingController(text: widget.placeInfo.imageUrl);

    _cities = City.currentCityList;
    _categories = PlaceCategory.currentPlaceCategoryList;

    chosenCategory = widget.placeInfo.category;

    chosenCity = widget.placeInfo.city;

    _fillRegularList();

    setState(() {
      loading = false;
    });

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

                    CityElementInEditScreen(
                      cityName: chosenCity.id == ''? 'Город не выбран' : chosenCity.name,
                      onActionPressed: () {
                        _showCityPickerDialog();
                      },
                    ),

                    const SizedBox(height: 16.0),

                    CategoryElementInEditScreen(
                      categoryName: chosenCategory.id == ''? 'Категория не выбрана': chosenCategory.name,
                      onActionPressed: () {
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

                    Column(
                      children: List.generate(regularStartTimes.length, (index) {
                        return RegularTwoTypeDateTimePickerWidget(
                          startTimeLabelText: "Открытие",
                          endTimeLabelText: 'Закрытие',
                          startTime: regularStartTimes[index],
                          endTime: regularFinishTimes[index],
                          index: index,
                          onStartTimeChanged: (String? time) {
                            setState(() {
                              regularStartTimes[index] = time!;
                            });
                          },
                          onEndTimeChanged: (String? time) {
                            setState(() {
                              regularFinishTimes[index] = time!;
                            });
                          },
                        );
                      }).toList(),
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
                        String? imageUrl;

                        // ---- ЕСЛИ ВЫБРАНА НОВАЯ КАРТИНКА -------
                        if (_imageFile != null) {

                          // Сжимаем изображение
                          final compressedImage = await imagePickerService.compressImage(_imageFile!);

                          // Выгружаем изображение в БД и получаем URL картинки
                          //imageUrl = await ImageUploader.uploadImageInPlace(placeId, compressedImage);
                          imageUrl = await imageUploader.uploadImage(placeId, compressedImage, ImageFolderEnum.places);

                        }

                        Place place = Place(
                            id: placeId,
                            name: nameController.text,
                            desc: descController.text,
                            creatorId: creatorId,
                            createDate: createdTime,
                            category: chosenCategory,
                            city: chosenCity,
                            street: streetController.text,
                            house: houseController.text,
                            phone: phoneController.text,
                            whatsapp: whatsappController.text,
                            telegram: telegramController.text,
                            instagram: instagramController.text,
                            imageUrl: imageUrl ?? widget.placeInfo.imageUrl,
                            openingHours: widget.placeInfo.openingHours.generateDateForEntity(
                                RegularDate.generateOnceMapForEntity(regularStartTimes, regularFinishTimes)
                            ),
                            eventsList: widget.placeInfo.eventsList,
                            promosList: widget.placeInfo.promosList,
                            favUsersIds: widget.placeInfo.favUsersIds
                        );

                        // Выгружаем пользователя в БД
                        String? editInDatabase = await place.publishToDb();

                        // Если выгрузка успешна
                        if (editInDatabase == 'success') {

                          Place newPlace = await place.getEntityByIdFromDb(placeId);

                          if (widget.placeInfo.name == ''){
                            // То добавляем в списки новое созданное место
                            newPlace.addEntityToCurrentEntitiesLists();
                          } else {
                            // Если редактирование, удаляем старое объявление
                            place.deleteEntityFromCurrentEntityLists();

                            // Добавляем отредактированное
                            newPlace.addEntityToCurrentEntitiesLists();
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

  void _showCategoryPickerDialog() async {
    final selectedCategory = await Navigator.of(context).push(_createPopupCategory(_categories));

    if (selectedCategory != null) {
      setState(() {
        chosenCategory = selectedCategory;
      });
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
      transitionDuration: const Duration(milliseconds: 100),

    );
  }

  void _fillRegularList (){

    for (int i = 0; i<regularStartTimes.length; i++){

      regularStartTimes[i] = widget.placeInfo.openingHours.getDayFromIndex(i).startTime.toString();
      regularFinishTimes[i] = widget.placeInfo.openingHours.getDayFromIndex(i).endTime.toString();

    }
  }

}