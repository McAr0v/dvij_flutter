import 'dart:io';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_type_enum.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/checkbox_with_desc.dart';
import 'package:dvij_flutter/elements/events_elements/event_category_picker_page.dart';
import 'package:dvij_flutter/elements/places_elements/place_category_picker_page.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/long_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/once_type_date_time_picker_widget.dart';
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
import '../../elements/data_picker.dart';
import '../../elements/events_elements/event_type_tab_element.dart';
import '../../elements/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_Uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';
import '../../methods/date_functions.dart';
import '../../themes/app_colors.dart';

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

  //late DateTime selectedDate;


  late RoleInApp chosenRoleInApp;
  late int accessLevel;

  EventTypeEnum eventTypeEnum = EventTypeEnum.once;

  // ПЕРЕМЕННЫЕ ВРЕМЕНИ РАБОТЫ?
  late DateTime selectedDayInOnceType;
  late String onceDay;
  String onceDayStartTime = '00:00';
  String onceDayFinishTime = '00:00';

  late DateTime selectedStartDayInLongType;
  late DateTime selectedEndDayInLongType;
  late String longStartDay;
  late String longEndDay;
  String longDayStartTime = '00:00';
  String longDayFinishTime = '00:00';

  bool loading = true;
  bool saving = false;
  bool tab1 = true;
  bool tab2 = false;
  bool tab3 = false;
  bool tab4 = false;

  List<City> _cities = [];
  List<EventCategory> _categories = [];
  late EventCategory chosenCategory;




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
    _initializeData();
  }

  Future<void> _initializeData() async {
    loading = true;
    _categories = EventCategory.currentEventCategoryList;

    accessLevel = UserCustom.accessLevel;

    eventTypeEnum = Event.getEventTypeEnum(widget.eventInfo.eventType);

    if (eventTypeEnum == EventTypeEnum.once && widget.eventInfo.onceDay != ''){
      onceDay = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'date');
      selectedDayInOnceType = DateTime.parse(onceDay);
      onceDayStartTime = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'startTime');
      onceDayFinishTime = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'endTime');
    } else {
      selectedDayInOnceType = DateTime(2100);
    }

    if (eventTypeEnum == EventTypeEnum.long && widget.eventInfo.longDays != '') {

     longStartDay = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'startDate');
     longEndDay = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'endDate');
     selectedStartDayInLongType = DateTime.parse(longStartDay);
     selectedEndDayInLongType = DateTime.parse(longEndDay);
     longDayStartTime = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'startTime');
     longDayFinishTime = extractDateOrTimeFromJson(widget.eventInfo.onceDay, 'endTime');

    } else {
      selectedStartDayInLongType = DateTime(2100);
      selectedEndDayInLongType = DateTime(2100);
    }

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

                    const SizedBox(height: 16.0),

                    Text(
                      'Выбери тип мероприятия',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    const SizedBox(height: 5.0),

                    Text(
                      'От типа мероприятия будет зависить выбор даты проведения',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 16.0),

                    DropdownButton<EventTypeEnum>(
                      style: Theme.of(context).textTheme.bodySmall,
                      isExpanded: true,
                      value: eventTypeEnum,
                      onChanged: (EventTypeEnum? newValue) {
                        setState(() {
                          eventTypeEnum = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: EventTypeEnum.once,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Разовое',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.start,
                              ),
                              Text(
                                'Состоится 1 раз в одну определенную дату',
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          )
                        ),
                        DropdownMenuItem(
                            value: EventTypeEnum.long,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Длительное',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Проходит несколько дней подряд',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                        ),
                        DropdownMenuItem(
                            value: EventTypeEnum.regular,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Регулярное',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Проходит каждую неделю в определенные дни',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                        ),
                        DropdownMenuItem(
                            value: EventTypeEnum.irregular,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'В разные даты',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Проходит в разные даты - 1, 5, 13 и тд',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                        ),
                      ],
                    ),

                    const SizedBox(height: 20.0),

                    Text(
                      'Выбери дату и время проведения мероприятия',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
                    ),

                    SizedBox(height: 20,),

                    if (eventTypeEnum == EventTypeEnum.once) OnceTypeDateTimePickerWidget(
                        //title: 'Выбери дату и время проведения мероприятия',
                        dateLabelText: 'Дата проведения мероприятия',
                        startTimeLabelText: "Начало мероприятия",
                        endTimeLabelText: "Конец мероприятия",
                        selectedDate: selectedDayInOnceType,
                        startTime: onceDayStartTime,
                        endTime: onceDayFinishTime,
                        onDateActionPressed: (){
                          DateTime temp = DateTime.now();
                          setState(() {
                            selectedDayInOnceType = temp;
                          });
                          _selectDate(context, selectedDayInOnceType, needClearInitialDate: true);

                        },
                        onDateActionPressedWithChosenDate:  () {
                          _selectDate(context, selectedDayInOnceType);
                          //_selectDate(context);
                        },
                        onStartTimeChanged: (String? time) {
                          setState(() {
                            onceDayStartTime = time!;
                          });
                        },
                        onEndTimeChanged: (String? time) {
                          setState(() {
                            onceDayFinishTime = time!;
                          });
                        }
                    ),



                    if (eventTypeEnum == EventTypeEnum.long) LongTypeDateTimePickerWidget(
                        startDateLabelText: 'Дата начала мероприятия',
                        endDateLabelText: 'Дата завершения мероприятия',
                        startTimeLabelText: "Начало мероприятия",
                        endTimeLabelText: "Конец мероприятия",
                        selectedStartDate: selectedStartDayInLongType,
                        selectedEndDate: selectedEndDayInLongType,
                        startTime: longDayStartTime,
                        endTime: longDayFinishTime,
                        onStartDateActionPressed: (){
                          DateTime temp = DateTime.now();
                          setState(() {
                            selectedStartDayInLongType = temp;
                          });
                          _selectDate(context, selectedStartDayInLongType, needClearInitialDate: true, isOnce: false, isStart: true, endDate: selectedEndDayInLongType);
                          //_isStartBeforeEnd(true);

                        },
                        onStartDateActionPressedWithChosenDate: () {
                          _selectDate(context, selectedStartDayInLongType, isOnce: false, isStart: true, endDate: selectedEndDayInLongType);
                          //_isStartBeforeEnd(true);
                        },
                        onEndDateActionPressed: (){
                          // TODO Сделать проверку, чтобы по умолчанию выставлялись граничные даты в пикере, в зависимости от выбранной даты начала и конца
                          DateTime temp = selectedStartDayInLongType;
                          setState(() {
                            selectedEndDayInLongType = temp;
                          });
                          _selectDate(context, selectedEndDayInLongType, needClearInitialDate: true, isOnce: false, isStart: false, firstDate: selectedStartDayInLongType);
                          //_isStartBeforeEnd(false);
                        },
                        onEndDateActionPressedWithChosenDate: () {
                          _selectDate(context, selectedEndDayInLongType, isOnce: false, isStart: false, firstDate: selectedStartDayInLongType);

                        },
                        onStartTimeChanged: (String? time) {
                          setState(() {
                            longDayStartTime = time!;
                          });
                        },
                        onEndTimeChanged: (String? time) {
                          setState(() {
                            longDayFinishTime = time!;
                          });
                        }
                    ),
                    if (eventTypeEnum == EventTypeEnum.regular) Column(
                      children: [
                        Text('tab3')
                      ],
                    ),
                    if (eventTypeEnum == EventTypeEnum.irregular) Column(
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
                            eventType: Event.getNameEventTypeEnum(eventTypeEnum), // сделать функционал
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
                            onceDay: generateOnceTypeDate(
                                selectedDayInOnceType,
                                onceDayStartTime,
                                onceDayFinishTime
                            ), // сделать функционал
                            longDays: generateLongTypeDate(
                                selectedStartDayInLongType,
                                selectedEndDayInLongType,
                                longDayStartTime,
                                longDayFinishTime
                            ), // сделать функционал
                            regularDays: '', // сделать функционал
                            irregularDays: '', // сделать функционал
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

  Future<void> _selectDate(
      BuildContext context,
      DateTime initial,
      {bool needClearInitialDate = false,
      bool isOnce = true,
      bool isStart = true,
      DateTime? firstDate = null,
      DateTime? endDate = null,
      }
      ) async {
    //DateTime initial = selectedDayInOnceType;
    //DateTime initialInMethod = initial;
    if (needClearInitialDate == true) initial = DateTime.now();

    final DateTime? picked = await showDatePicker(

      locale: const Locale('ru', 'RU'),
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: endDate ?? DateTime(2100),
      helpText: 'Выбери дату',
      cancelText: 'Отмена',
      confirmText: 'Подтвердить',
      keyboardType: TextInputType.datetime,
      currentDate: DateTime.now(),
    );

    if (picked != null){

      if (isOnce && picked != selectedDayInOnceType) {
        setState(() {
          selectedDayInOnceType = picked;
        });
      } else if (!isOnce && isStart){
        if (picked != selectedStartDayInLongType){
          setState(() {
            selectedStartDayInLongType = picked;
          });
          _isStartBeforeEnd(true);
        }
      } else if (!isOnce && !isStart){
        if (picked != selectedEndDayInLongType){
          setState(() {
            selectedEndDayInLongType = picked;
          });
          _isStartBeforeEnd(false);
        }
      }

    }

    /*if (picked != null && picked != selectedDayInOnceType) {
      setState(() {
        selectedDayInOnceType = picked;
      });
    }*/
  }

  void _isStartBeforeEnd (bool startAfterEnd){
    if (startAfterEnd){
      if (selectedStartDayInLongType.isAfter(selectedEndDayInLongType)){
        setState(() {
          selectedStartDayInLongType = selectedEndDayInLongType;
        });
      }
    } else {
      if (selectedEndDayInLongType.isBefore(selectedStartDayInLongType)){
        setState(() {
          selectedEndDayInLongType = selectedStartDayInLongType;
        });
      }
    }
  }


}