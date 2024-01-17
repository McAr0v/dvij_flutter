import 'dart:io';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_type_enum.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/events_elements/event_category_picker_page.dart';
import 'package:dvij_flutter/elements/places_elements/place_category_picker_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../classes/city_class.dart';
import '../../classes/event_class.dart';
import '../../classes/role_in_app.dart';
import '../../classes/user_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import '../../elements/cities_elements/city_element_in_edit_screen.dart';
import '../../elements/custom_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../elements/events_elements/event_type_tab_element.dart';
import '../../elements/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_Uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';

class CreateOrEditEventScreen extends StatefulWidget {
  final Event eventInfo;

  const CreateOrEditEventScreen({Key? key, required this.eventInfo}) : super(key: key);



  @override
  _CreateOrEditEventScreenState createState() => _CreateOrEditEventScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class _CreateOrEditEventScreenState extends State<CreateOrEditEventScreen> {

  // Инициализируем классы
  // TODO - эти классы так надо инициализировать? помоему можно будет просто обращаться к ним и все
  final ImagePickerService imagePickerService = ImagePickerService();
  final ImageUploader imageUploader = ImageUploader();

  late TextEditingController headlineController;
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

  late String eventId;
  late String creatorId;
  late String createdTime;

  File? _imageFile;

  late DateTime selectedDate;
  late RoleInApp chosenRoleInApp;
  late int accessLevel;

  EventTypeEnum eventTypeEnum = EventTypeEnum.once;

  // ПЕРЕМЕННЫЕ ВРЕМЕНИ РАБОТЫ?

  bool loading = true;
  bool saving = false;
  bool tab1 = true;
  bool tab2 = false;
  bool tab3 = false;
  bool tab4 = false;

  List<City> _cities = [];
  List<EventCategory> _categories = [];
  late EventCategory chosenCategory;

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

  void navigateToEvents() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events',
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
    _categories = EventCategory.currentEventCategoryList;

    accessLevel = UserCustom.accessLevel;

    eventTypeEnum = Event.getEventTypeEnum(widget.eventInfo.eventType);

    if (widget.eventInfo.id == '') {

      DatabaseReference eventReference = FirebaseDatabase.instance.ref().child('events');

      // --- Генерируем уникальный ключ ---
      DatabaseReference newEventReference = eventReference.push();
      // ---- Получаем уникальный ключ ----
      eventId = newEventReference.key!; // Получаем уникальный ключ

    } else {

      eventId = widget.eventInfo.id;

    }

    if (widget.eventInfo.creatorId == '') {

      creatorId = UserCustom.currentUser!.uid;

    } else {

      creatorId = widget.eventInfo.creatorId;

    }

    if (widget.eventInfo.createDate == ''){
      DateTime now = DateTime.now();
      createdTime = '${now.day}.${now.month}.${now.year}';
    }
    else {
      createdTime = widget.eventInfo.createDate;
    }

    // Подгружаем в контроллеры содержимое из БД.
    Future.delayed(Duration.zero, () async {

      //category = '';
      headlineController = TextEditingController(text: widget.eventInfo.headline);
      descController = TextEditingController(text: widget.eventInfo.desc);

      phoneController = TextEditingController(text: widget.eventInfo.phone);
      whatsappController = TextEditingController(text: widget.eventInfo.whatsapp);
      telegramController = TextEditingController(text: widget.eventInfo.telegram);
      instagramController = TextEditingController(text: widget.eventInfo.instagram);
      cityController = TextEditingController(text: widget.eventInfo.city);
      streetController = TextEditingController(text: widget.eventInfo.street);
      houseController = TextEditingController(text: widget.eventInfo.house);

      imageController = TextEditingController(text: widget.eventInfo.imageUrl);

      _cities = City.currentCityList;
      _categories = EventCategory.currentEventCategoryList;

      chosenCategory = EventCategory.getEventCategoryFromCategoriesList(widget.eventInfo.category);

      chosenCity = City.getCityNameInCitiesList(widget.eventInfo.city);

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
          title: Text(widget.eventInfo.id != '' ? 'Редактирование мероприятия' : 'Создание мероприятия'),
        ),
        body: Stack (
            children: [
              if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка данных',)
              else if (saving) const LoadingScreen(loadingText: 'Подожди, идет сохранение данных',)
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
                    else if (_imageFile == null && widget.eventInfo.imageUrl != '' ) ImageInEditScreen(
                      onEditPressed: () => _pickImage(),
                      backgroundImageUrl: widget.eventInfo.imageUrl,
                    ),

                    const SizedBox(height: 16.0),

                    const SizedBox(height: 16.0),
                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.text,
                      controller: headlineController,
                      decoration: const InputDecoration(
                        labelText: 'Название мероприятия',
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        EventTypeTabElement(
                            onTap: (){
                              setState(() {
                                tab1 = true;
                                tab2 = false;
                                tab3 = false;
                                tab4 = false;
                              });
                            },
                            text: 'Разовое',
                            active: tab1
                        ),
                        EventTypeTabElement(
                            onTap: (){
                              setState(() {
                                tab2 = true;
                                tab1 = false;
                                tab3 = false;
                                tab4 = false;
                              });
                            },
                            text: 'Длительное',
                            active: tab2
                        ),
                        EventTypeTabElement(
                            onTap: (){
                              setState(() {
                                tab3 = true;
                                tab2 = false;
                                tab1 = false;
                                tab4 = false;
                              });
                            },
                            text: 'Регулярное',
                            active: tab3
                        ),
                        EventTypeTabElement(
                            onTap: (){
                              setState(() {
                                tab4 = true;
                                tab2 = false;
                                tab3 = false;
                                tab1 = false;
                              });
                            },
                            text: 'Разные даты',
                            active: tab4
                        ),
                      ],
                    ),

                    if (tab1) Column(
                      children: [
                        Text('tab1')
                      ],
                    ),

                    if (tab2) Column(
                      children: [
                        Text('tab2')
                      ],
                    ),

                    if (tab3) Column(
                      children: [
                        Text('tab3')
                      ],
                    ),

                    if (tab4) Column(
                      children: [
                        Text('tab4')
                      ],
                    ),

                    //EventTypeTabsWidget(eventType: eventTypeEnum),

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

                    // TODO - Сделать Переключалку - выбор места или ввод адреса
                    // TODO - Сделать если редактирование то автоматический выбор переключалки


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

                    const SizedBox(height: 40.0),

                    // --- КНОПКА Сохранить изменения -------

                    CustomButton(
                      buttonText: 'Сохранить изменения',
                      onTapMethod: () async {

                        // Включаем экран загрузки
                        setState(() {
                          saving = true;
                        });

                        // Создаем переменную для нового аватара
                        String? avatarURL;

                        // ---- ЕСЛИ ВЫБРАНА НОВАЯ КАРТИНКА -------
                        if (_imageFile != null) {

                          // Сжимаем изображение
                          final compressedImage = await imagePickerService.compressImage(_imageFile!);



                          // Выгружаем изображение в БД и получаем URL картинки
                          avatarURL = await imageUploader.uploadImageInPlace(eventId, compressedImage);

                          // Если URL аватарки есть
                          if (avatarURL != null) {
                            // TODO: Сделать вывод какой-то, что картинка загружена
                          } else {
                            // TODO: Сделать обработку ошибок, если не удалось загрузить картинку в базу данных пользователя
                          }
                        }

                        Event event = Event(
                            id: eventId,
                            eventType: 'eventType', // сделать функционал
                            headline: headlineController.text,
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
                            imageUrl: avatarURL ?? widget.eventInfo.imageUrl,
                            placeId: 'placeId', // сделать функционал
                            startDate: 'startDate', // сделать функционал
                            endDate: 'endDate', // сделать функционал
                            startTime: 'startTime', // сделать функционал
                            endTime: 'endTime', // сделать функционал
                            price: 'price' // сделать функционал
                        );

                        // Выгружаем пользователя в БД
                        String? editInDatabase = await Event.createOrEditEvent(event);

                        // Если выгрузка успешна
                        if (editInDatabase == 'success') {

                          Event newEvent = await Event.getEventById(eventId);

                          // Если в передаваемом месте нет имени, т.е это создание
                          if (widget.eventInfo.headline == ''){
                            // То добавляем в списки новое созданное место

                            Event.currentFeedEventsList.add(newEvent);
                            Event.currentMyEventsList.add(newEvent);

                          } else {

                            // Если редактирование то удаляем старые неотредактированные данные
                            Event.deleteEventFromCurrentEventLists(eventId);

                            // Добавляем обновленное
                            Event.currentFeedEventsList.add(newEvent);
                            Event.currentMyEventsList.add(newEvent);
                            if (bool.parse(newEvent.inFav!)) Event.currentFavEventsList.add(newEvent);

                          }


                          // Выключаем экран загрузки
                          setState(() {
                            saving = false;
                          });
                          // Показываем всплывающее сообщение
                          showSnackBar(
                            "Прекрасно! Данные опубликованы!",
                            Colors.green,
                            1,
                          );

                          // Уходим в профиль
                          navigateToEvents();

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

  Route _createPopupCategory(List<EventCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return EventCategoryPickerPage(categories: categories);
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