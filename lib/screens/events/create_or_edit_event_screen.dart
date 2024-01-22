import 'dart:io';
import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/event_type_enum.dart';
import 'package:dvij_flutter/classes/place_class.dart';
import 'package:dvij_flutter/classes/priceTypeOptions.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/elements/events_elements/event_category_picker_page.dart';
import 'package:dvij_flutter/elements/places_elements/place_picker_page.dart';
import 'package:dvij_flutter/elements/places_elements/place_widget_in_create_event_screen.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/irregular_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/long_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/once_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/regular_two_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/methods/days_functions.dart';
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

  PriceTypeOption priceType = PriceTypeOption.free;

  late TextEditingController fixedPriceController;
  late TextEditingController startPriceController;
  late TextEditingController endPriceController;

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

  List<String> regularStartTimes = fillTimeListWithDefaultValues('00:00', 7);
  List<String> regularFinishTimes = fillTimeListWithDefaultValues('00:00', 7);

  // Здесь хранятся выбранные даты нерегулярных дней
  List<DateTime> chosenIrregularDays = [];
  // Это список для временного хранения дат в стринге из БД при парсинге
  List<String> tempIrregularDaysString = [];
  // Выбранные даты начала
  List<String> chosenIrregularStartTime = [];
  // Выбранные даты завершения
  List<String> chosenIrregularEndTime = [];


  List<Place> myPlaces = [];

  bool loading = true;
  bool saving = false;

  bool inPlace = true;
  Place chosenPlace = Place.emptyPlace;

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
    //accessLevel = UserCustom.accessLevel;

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

     longStartDay = extractDateOrTimeFromJson(widget.eventInfo.longDays, 'startDate');
     longEndDay = extractDateOrTimeFromJson(widget.eventInfo.longDays, 'endDate');
     selectedStartDayInLongType = DateTime.parse(longStartDay);
     selectedEndDayInLongType = DateTime.parse(longEndDay);
     longDayStartTime = extractDateOrTimeFromJson(widget.eventInfo.longDays, 'startTime');
     longDayFinishTime = extractDateOrTimeFromJson(widget.eventInfo.longDays, 'endTime');

    } else {
      selectedStartDayInLongType = DateTime(2100);
      selectedEndDayInLongType = DateTime(2100);
    }

    if (eventTypeEnum == EventTypeEnum.regular && widget.eventInfo.regularDays != ''){

      _fillRegularList();
    }

    if (eventTypeEnum == EventTypeEnum.irregular && widget.eventInfo.irregularDays != ''){

      // Парсим даты и время в списки
      parseInputString(widget.eventInfo.irregularDays, tempIrregularDaysString, chosenIrregularStartTime, chosenIrregularEndTime);

      for (String date in tempIrregularDaysString){
        // Преобразуем даты из String в DateTime и кидаем в нужный список
        chosenIrregularDays.add(getDateFromString(date));
      }
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

    if (Place.currentMyPlaceList.isNotEmpty){

      myPlaces = Place.currentMyPlaceList;

    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.uid != ''){

      myPlaces = await Place.getMyPlaces(UserCustom.currentUser!.uid);

    }

    priceType = Event.getPriceTypeEnum(widget.eventInfo.priceType);

    if (priceType == PriceTypeOption.free) {
      fixedPriceController = TextEditingController(text: '');
      startPriceController = TextEditingController(text: '');
      endPriceController = TextEditingController(text: '');
    }

    if (priceType == PriceTypeOption.fixed){
      fixedPriceController = TextEditingController(text: widget.eventInfo.price);
      startPriceController = TextEditingController(text: '');
      endPriceController = TextEditingController(text: '');
    }

    if (priceType == PriceTypeOption.range){
      fixedPriceController = TextEditingController(text: widget.eventInfo.price);
      List<String> temp = widget.eventInfo.priceType.split('-');
      startPriceController = TextEditingController(text: temp[0]);
      endPriceController = TextEditingController(text: temp[1]);
    }


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

                    const SizedBox(height: 40.0),

                    Text(
                      'Стоимость билетов',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
                    ),

                    const SizedBox(height: 5.0),

                    Text(
                      'Ты можешь выбрать из несольких вариантов - бесплатно, фиксированная цена или цена от и до',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 16.0),

                    DropdownButton<PriceTypeOption>(
                      style: Theme.of(context).textTheme.bodySmall,
                      isExpanded: true,
                      value: priceType,
                      onChanged: (PriceTypeOption? newValue) {
                        setState(() {
                          priceType = newValue!;

                          if (newValue == PriceTypeOption.free){
                            fixedPriceController.text = '';
                            startPriceController.text = '';
                            endPriceController.text = '';
                          }

                          if (newValue == PriceTypeOption.fixed){
                            startPriceController.text = '';
                            endPriceController.text = '';
                          }

                          if (newValue == PriceTypeOption.range){
                            fixedPriceController.text = '';
                          }

                        });
                      },
                      items: [
                        DropdownMenuItem(
                            value: PriceTypeOption.free,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Бесплатно',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Свободный вход для всех посетителей',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                        ),
                        DropdownMenuItem(
                            value: PriceTypeOption.fixed,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Фиксированная стоимость',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Одна стоимость билетов для всех посетителей',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                        ),
                        DropdownMenuItem(
                            value: PriceTypeOption.range,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Цена "От - до "',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Крайние стоимости билетов',
                                  style: Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            )
                        ),
                      ],
                    ),

                    if (priceType != PriceTypeOption.free) const SizedBox(height: 20.0),

                    if (priceType == PriceTypeOption.fixed) TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      controller: fixedPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Введи стоимость билетов',
                      ),
                    ),

                    if (priceType == PriceTypeOption.range) TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      controller: startPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Введи стоимость самого дешевого билета',
                      ),
                    ),

                    if (priceType == PriceTypeOption.range) const SizedBox(height: 15.0),

                    if (priceType == PriceTypeOption.range) TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      controller: endPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Введи стоимость самого дорогого билета',
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    Text(
                      'Выбери место проведения мероприятия',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
                    ),

                    const SizedBox(height: 5.0),

                    Text(
                      'Ты можешь указать заведение или просто написать адрес',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    SizedBox(height: 10,),

                    Row (
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Card (
                            color: inPlace? AppColors.brandColor : AppColors.greyForCards,
                            //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Padding (
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text (
                                'Выбрать место',
                                style: inPlace? Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyOnBackground) : Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          onTap: (){
                            setState(() {
                              inPlace = true;
                              streetController.text = '';
                              houseController.text = '';
                              chosenCity = City(id: '', name: '');
                            });
                          },
                        ),
                        GestureDetector(
                          child: Card (
                            color: !inPlace? AppColors.brandColor : AppColors.greyForCards,
                            //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Padding (
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text ('Написать адрес', style: !inPlace? Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyOnBackground) : Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                          onTap: (){
                            setState(() {
                              inPlace = false;
                              chosenPlace = Place.empty();
                              chosenCity = City(id: '', name: '');
                            });
                          },
                        )
                      ],
                    ),

                    const SizedBox(height: 20.0),

                    if (inPlace) Column(
                      children: [
                        if (chosenPlace.id == '') CustomButton(
                            buttonText: 'Выбрать заведение',
                            onTapMethod: (){
                              _showPlacePickerDialog();
                            }
                        ),
                        if (chosenPlace.id != '') PlaceWidgetInCreateEventScreen(
                          place: chosenPlace,
                          onTapMethod: (){
                            _showPlacePickerDialog();
                          },
                          onDeleteMethod: (){
                            setState(() {
                              chosenPlace = Place.empty();
                              chosenCity = City(name: '', id: '');
                            });
                          },
                        )
                      ],
                    ),

                    if (!inPlace) Column(
                      children: [
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
                      ],
                    ),

                    const SizedBox(height: 40.0),

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

                    if (eventTypeEnum == EventTypeEnum.regular) Card(
                      surfaceTintColor: Colors.transparent,
                      color: AppColors.greyOnBackground,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        child: Column(
                          children: List.generate(regularStartTimes.length, (index) {
                            return RegularTwoTypeDateTimePickerWidget(
                                startTimeLabelText: "Начало мероприятия",
                                endTimeLabelText: 'Конец мероприятия',
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
                      ),
                    ),

                    if (eventTypeEnum == EventTypeEnum.irregular && chosenIrregularDays.isNotEmpty) Column(
                      children: List.generate(chosenIrregularDays.length, (index) {
                        return IrregularTypeDateTimePickerWidget(
                            dateLabelText: "Дата проведения мероприятия",
                            startTimeLabelText: 'Начало',
                            endTimeLabelText: 'Завершение',
                            selectedDate: chosenIrregularDays[index],
                            startTime: chosenIrregularStartTime[index],
                            endTime: chosenIrregularEndTime[index],
                            onDateActionPressed: (){
                              DateTime temp = DateTime.now();
                              setState(() {
                                chosenIrregularDays[index] = temp;
                              });
                              _selectDate(context, chosenIrregularDays[index], needClearInitialDate: true, isIrregular: true, index: index);

                            },
                            onDateActionPressedWithChosenDate:  () {
                              _selectDate(context, chosenIrregularDays[index], isIrregular: true, index: index);
                              //_selectDate(context);
                            },
                            onStartTimeChanged: (String? time) {
                              setState(() {
                                chosenIrregularStartTime[index] = time!;
                              });
                            },
                            onEndTimeChanged: (String? time) {
                              setState(() {
                                chosenIrregularEndTime[index] = time!;
                              });
                            },
                            onDeletePressed: (){
                              setState(() {
                                chosenIrregularDays.removeAt(index);
                                chosenIrregularStartTime.removeAt(index);
                                chosenIrregularEndTime.removeAt(index);
                              });
                            }
                        );
                      }).toList(),
                    ),

                    if (eventTypeEnum == EventTypeEnum.irregular) SizedBox(height: 20,),
                    if (eventTypeEnum == EventTypeEnum.irregular) CustomButton(
                        buttonText: "Добавить дату",
                        onTapMethod: (){
                          setState(() {
                            chosenIrregularDays.add(DateTime.now());
                            chosenIrregularStartTime.add('00:00');
                            chosenIrregularEndTime.add('00:00');
                          });
                        }
                    ),
                    //EventTypeTabsWidget(eventType: eventTypeEnum),

                    const SizedBox(height: 30.0),



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
                            placeId: chosenPlace.id, // сделать функционал
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
                            regularDays: generateRegularTypeDateTwo(regularStartTimes, regularFinishTimes), // сделать функционал

                            irregularDays: sortDateTimeListAndRelatedData(
                                chosenIrregularDays,
                                chosenIrregularStartTime,
                                chosenIrregularEndTime
                            ),

                            // сделать функционал
                            price: Event.getPriceString(priceType, fixedPriceController.text, startPriceController.text, endPriceController.text), // сделать функционал
                          priceType: Event.getNamePriceTypeEnum(priceType)
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

  void _fillRegularList (){
    //int counter = 1;

    for (int i = 0; i<regularStartTimes.length; i++){

      regularStartTimes[i] = extractDateOrTimeFromJson(widget.eventInfo.regularDays, 'startTime${i+1}');
      regularFinishTimes[i] = extractDateOrTimeFromJson(widget.eventInfo.regularDays, 'endTime${i+1}');


      //regularStartTimes[i+1] = extractDateOrTimeFromJson(widget.eventInfo.regularDays, 'endTime$counter');

      //counter++;

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

  void _showPlacePickerDialog() async {
    final selectedPlace = await Navigator.of(context).push(_createPopupPlace(myPlaces));

    if (selectedPlace != null) {
      setState(() {
        chosenPlace = selectedPlace;
        chosenCity = City.getCityByIdFromList(chosenPlace.city);
      });
      //print("Selected category: ${selectedPlace.name}, ID: ${selectedPlace.id}");
    }
  }

  Route _createPopupPlace(List<Place> places) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return PlacePickerPage(places: places);
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
        // для нерегулярных дат
      bool isIrregular = false,
        // для нерегулярных дат
      int index = 0,
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

      if (isIrregular) {
        setState(() {
          chosenIrregularDays[index] = picked;
        });
      } else if (isOnce && picked != selectedDayInOnceType) {
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

  void parseInputString(
      String inputString, List<String> datesList, List<String> startTimeList, List<String> endTimeList) {
    RegExp dateRegExp = RegExp(r'"date": "([^"]+)"');
    RegExp startTimeRegExp = RegExp(r'"startTime": "([^"]+)"');
    RegExp endTimeRegExp = RegExp(r'"endTime": "([^"]+)"');

    List<Match> matches = dateRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      datesList.add(match.group(1)!);
    }

    matches = startTimeRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      startTimeList.add(match.group(1)!);
    }

    matches = endTimeRegExp.allMatches(inputString).toList();
    for (Match match in matches) {
      endTimeList.add(match.group(1)!);
    }
  }

}