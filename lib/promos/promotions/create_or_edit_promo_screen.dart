import 'dart:io';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/dates/irregular_date_class.dart';
import 'package:dvij_flutter/dates/long_date_class.dart';
import 'package:dvij_flutter/dates/once_date_class.dart';
import 'package:dvij_flutter/dates/regular_date_class.dart';
import 'package:dvij_flutter/dates/time_mixin.dart';
import 'package:dvij_flutter/dates/date_type_enum.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/elements/category_element_in_edit_screen.dart';
import 'package:dvij_flutter/places/choose_place_in_event_and_promo.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/irregular_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/long_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/once_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/regular_two_type_date_time_picker_widget.dart';
import 'package:dvij_flutter/elements/types_of_date_time_pickers/type_of_date_widget.dart';
import 'package:dvij_flutter/places/place_list_class.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/promos/promo_class.dart';
import 'package:dvij_flutter/promos/promos_elements/promo_category_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import '../../cities/city_class.dart';
import '../../dates/date_mixin.dart';
import '../../elements/snack_bar.dart';
import '../../places/place_list_manager.dart';
import '../../places/places_elements/place_picker_page.dart';
import '../../current_user/user_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets_global/images/image_in_edit_screen.dart';
import '../../elements/loading_screen.dart';
import '../../image_uploader/image_uploader.dart';
import '../../image_uploader/image_picker.dart';
import '../../themes/app_colors.dart';

class CreateOrEditPromoScreen extends StatefulWidget {
  final PromoCustom promoInfo;

  const CreateOrEditPromoScreen({Key? key, required this.promoInfo}) : super(key: key);

  @override
  CreateOrEditPromoScreenState createState() => CreateOrEditPromoScreenState();

}

// ----- ЭКРАН РЕДАКТИРОВАНИЯ ПРОФИЛЯ -------

class CreateOrEditPromoScreenState extends State<CreateOrEditPromoScreen> {

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

  late String promoId;
  late String creatorId;
  late DateTime createdTime;

  File? _imageFile;

  DateTypeEnum dateTypeEnum = DateTypeEnum.once;

  // ПЕРЕМЕННЫЕ ВРЕМЕНИ РАБОТЫ?
  late DateTime selectedDayInOnceType;
  String onceDayStartTime = 'Не выбрано';
  String onceDayFinishTime = 'Не выбрано';

  late DateTime selectedStartDayInLongType;
  late DateTime selectedEndDayInLongType;
  late String longStartDay;
  late String longEndDay;
  String longDayStartTime = 'Не выбрано';
  String longDayFinishTime = 'Не выбрано';

  List<String> regularStartTimes = TimeMixin.fillTimeListWithDefaultValues('Не выбрано', 7);
  List<String> regularFinishTimes = TimeMixin.fillTimeListWithDefaultValues('Не выбрано', 7);

  // Здесь хранятся выбранные даты нерегулярных дней
  List<DateTime> chosenIrregularDays = [];
  // Выбранные даты начала
  List<String> chosenIrregularStartTime = [];
  // Выбранные даты завершения
  List<String> chosenIrregularEndTime = [];


  PlaceList myPlaces = PlaceList();

  bool loading = true;
  bool saving = false;

  bool inPlace = true;
  Place chosenPlace = Place.empty();

  List<City> _cities = [];
  List<PromoCategory> _categories = [];
  PromoCategory chosenCategory = PromoCategory.empty;

  // --- Функция перехода на страницу профиля ----

  void navigateToPromos() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Promotions',
          (route) => false,
    );
  }

  void navigateToPreviousScreen(){
    List<dynamic> result = [true];
    Navigator.of(context).pop(result);
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

    _categories = PromoCategory.currentPromoCategoryList;

    dateTypeEnum = widget.promoInfo.dateType;

    if (dateTypeEnum == DateTypeEnum.once && widget.promoInfo.onceDay.dateIsNotEmpty()){
      selectedDayInOnceType = widget.promoInfo.onceDay.startDate;

      // Если в выбранной дате из БД день раньше, чем сегодня, то меняем выбранный день на сегодня
      if (selectedDayInOnceType.isBefore(DateTime.now())){
        selectedDayInOnceType = DateTime.now();
      }

      onceDayStartTime = TimeMixin.getTimeFromDateTime(widget.promoInfo.onceDay.startDate);
      onceDayFinishTime = TimeMixin.getTimeFromDateTime(widget.promoInfo.onceDay.endDate);

    } else {
      selectedDayInOnceType = DateTime(2100);
    }

    if (dateTypeEnum == DateTypeEnum.long && widget.promoInfo.longDays.dateIsNotEmpty()) {

      selectedStartDayInLongType = widget.promoInfo.longDays.startStartDate;
      selectedEndDayInLongType = widget.promoInfo.longDays.endStartDate;
      longDayStartTime = TimeMixin.getTimeFromDateTime(widget.promoInfo.longDays.startStartDate);
      longDayFinishTime = TimeMixin.getTimeFromDateTime(widget.promoInfo.longDays.endEndDate);

    } else {
      selectedStartDayInLongType = DateTime(2100);
      selectedEndDayInLongType = DateTime(2100);
    }

    if (dateTypeEnum == DateTypeEnum.regular){

      _fillRegularList();
    }

    if (dateTypeEnum == DateTypeEnum.irregular && widget.promoInfo.irregularDays.dateIsNotEmpty()){

      for (int i = 0; i<widget.promoInfo.irregularDays.dates.length; i++){
        OnceDate date = widget.promoInfo.irregularDays.dates[i];

        chosenIrregularDays.add(date.startDate);
        chosenIrregularStartTime.add(TimeMixin.getTimeFromDateTime(date.startDate));
        chosenIrregularEndTime.add(TimeMixin.getTimeFromDateTime(date.endDate));

      }
    }

    if (widget.promoInfo.id == '') {
      // ---- Получаем уникальный ключ ----
      promoId = MixinDatabase.generateKey()!;

    } else {
      promoId = widget.promoInfo.id;
    }

    if (widget.promoInfo.placeId != '') {
      if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){
        chosenPlace = chosenPlace.getEntityFromFeedList(widget.promoInfo.placeId);
      } else {
        chosenPlace = await chosenPlace.getEntityByIdFromDb(widget.promoInfo.placeId);
      }

      inPlace = true;
    } else {
      inPlace = false;
    }

    if (widget.promoInfo.creatorId == '') {

      creatorId = UserCustom.currentUser!.uid;

    } else {

      creatorId = widget.promoInfo.creatorId;

    }

    if (widget.promoInfo.createDate == DateTime(2100)){
      createdTime = DateTime.now();
    }
    else {
      createdTime = widget.promoInfo.createDate;
    }

    if (UserCustom.currentUser != null && UserCustom.currentUser!.myPlaces.isNotEmpty){
      myPlaces = await myPlaces.getMyListFromDb(UserCustom.currentUser!.uid);
    }

    headlineController = TextEditingController(text: widget.promoInfo.headline);
    descController = TextEditingController(text: widget.promoInfo.desc);

    if (widget.promoInfo.phone != '') {
      phoneController = TextEditingController(text: widget.promoInfo.phone);
    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.phone != '') {
      phoneController = TextEditingController(text: UserCustom.currentUser!.phone);
    } else {
      phoneController = TextEditingController(text: '');
    }

    if (widget.promoInfo.whatsapp != '') {
      whatsappController = TextEditingController(text: widget.promoInfo.whatsapp);
    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.whatsapp != '') {
      whatsappController = TextEditingController(text: UserCustom.currentUser!.whatsapp);
    } else {
      whatsappController = TextEditingController(text: '');
    }

    if (widget.promoInfo.telegram != '') {
      telegramController = TextEditingController(text: widget.promoInfo.telegram);
    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.telegram != '') {
      telegramController = TextEditingController(text: UserCustom.currentUser!.telegram);
    } else {
      telegramController = TextEditingController(text: '');
    }

    if (widget.promoInfo.instagram != '') {
      instagramController = TextEditingController(text: widget.promoInfo.instagram);
    } else if (UserCustom.currentUser != null && UserCustom.currentUser!.instagram != '') {
      instagramController = TextEditingController(text: UserCustom.currentUser!.instagram);
    } else {
      instagramController = TextEditingController(text: '');
    }

    cityController = TextEditingController(text: widget.promoInfo.city.name);
    streetController = TextEditingController(text: widget.promoInfo.street);
    houseController = TextEditingController(text: widget.promoInfo.house);

    imageController = TextEditingController(text: widget.promoInfo.imageUrl);

    _cities = City.currentCityList;
    _categories = PromoCategory.currentPromoCategoryList;

    chosenCategory = widget.promoInfo.category;

    chosenCity = widget.promoInfo.city;

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.promoInfo.id != '' ? 'Редактирование акции' : 'Создание акции'),
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

                      ImageInEditScreen(
                        onEditPressed: () => _pickImage(),
                        backgroundImageFile: _imageFile,
                        backgroundImageUrl: widget.promoInfo.imageUrl.isNotEmpty ? widget.promoInfo.imageUrl : null,
                      ),

                      const SizedBox(height: 16.0),

                      TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.text,
                        controller: headlineController,
                        decoration: const InputDecoration(
                          labelText: 'Название акции',
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

                      const SizedBox(height: 20.0),

                      CategoryElementInEditScreen(
                        categoryName: chosenCategory.id.isNotEmpty ? chosenCategory.name : 'Категория не выбрана',
                        onActionPressed: () {
                          _showCategoryPickerDialog();
                        },
                      ),

                      const SizedBox(height: 20.0),

                      Card(
                        surfaceTintColor: Colors.transparent,
                        color: AppColors.greyOnBackground,
                        child: Padding (
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column (
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              TypeOfDateWidget(
                                type: dateTypeEnum,
                                onChooseType: (DateTypeEnum? newValue) {
                                  setState(() {
                                    dateTypeEnum = newValue!;
                                  });
                                },
                              ),

                              const SizedBox(height: 20.0),

                              if (dateTypeEnum == DateTypeEnum.once) OnceTypeDateTimePickerWidget(
                                //title: 'Выбери дату и время проведения мероприятия',
                                  dateLabelText: 'Дата проведения акции',
                                  startTimeLabelText: "Начало",
                                  endTimeLabelText: "Завершение",
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



                              if (dateTypeEnum == DateTypeEnum.long) LongTypeDateTimePickerWidget(
                                  startDateLabelText: 'Дата начала акции',
                                  endDateLabelText: 'Дата завершения акции',
                                  startTimeLabelText: "Начало",
                                  endTimeLabelText: "Завершение",
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

                              if (dateTypeEnum == DateTypeEnum.regular) Column(
                                children: List.generate(regularStartTimes.length, (index) {
                                  return RegularTwoTypeDateTimePickerWidget(
                                    startTimeLabelText: "Начало",
                                    endTimeLabelText: 'Завершение',
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

                              if (dateTypeEnum == DateTypeEnum.irregular && chosenIrregularDays.isNotEmpty) Column(
                                children: List.generate(chosenIrregularDays.length, (index) {
                                  return IrregularTypeDateTimePickerWidget(
                                      dateLabelText: "Дата проведения акции",
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

                              if (dateTypeEnum == DateTypeEnum.irregular) const SizedBox(height: 20,),
                              if (dateTypeEnum == DateTypeEnum.irregular) CustomButton(
                                  buttonText: "Добавить дату",
                                  onTapMethod: (){
                                    setState(() {
                                      chosenIrregularDays.add(DateTime.now());
                                      chosenIrregularStartTime.add('Не выбрано');
                                      chosenIrregularEndTime.add('Не выбрано');
                                    });
                                  }
                              ),

                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15.0),

                      ChoosePlaceInEventAndPromoWidget(
                          chosenPlace: chosenPlace,
                          onDeletePlace: (){
                            setState(() {
                              chosenPlace = Place.empty();
                              chosenCity = City.empty();
                            });
                          },
                          onShowPickerPlace: _showPlacePickerDialog,
                          inPlace: inPlace,
                          chosenCity: chosenCity,
                          onShowChosenCityPicker: _showCityPickerDialog,
                          onTapChoosePlace: (){
                            setState(() {
                              inPlace = true;
                              streetController.text = '';
                              houseController.text = '';
                              chosenCity = City.empty();
                            });
                          },
                          onTapInputAddress: (){
                            setState(() {
                              inPlace = false;
                              chosenPlace = Place.empty();
                              chosenCity = City.empty();
                            });
                          },
                          streetController: streetController,
                          houseController: houseController
                      ),

                      const SizedBox(height: 20.0),

                      TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Телефон для справок',
                        ),
                      ),

                      const SizedBox(height: 16.0),
                      TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.phone,
                        controller: whatsappController,
                        decoration: const InputDecoration(
                          labelText: 'Whatsapp для справок',
                        ),
                      ),

                      const SizedBox(height: 16.0),
                      TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.text,
                        controller: telegramController,
                        decoration: const InputDecoration(
                          labelText: 'Telegram для справок',
                        ),
                      ),

                      const SizedBox(height: 16.0),
                      TextField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        keyboardType: TextInputType.text,
                        controller: instagramController,
                        decoration: const InputDecoration(
                          labelText: 'Instagram для справок',
                        ),
                      ),

                      const SizedBox(height: 40.0),

                      // --- КНОПКА Сохранить изменения -------

                      CustomButton(
                        buttonText: 'Сохранить изменения',
                        onTapMethod: () async {

                          String checkDates = DateMixin.checkTimeAndDate(
                              dateTypeEnum,
                              selectedDayInOnceType,
                              onceDayStartTime,
                              onceDayFinishTime,
                              selectedStartDayInLongType,
                              selectedEndDayInLongType,
                              longDayStartTime,
                              longDayFinishTime,
                              regularStartTimes,
                              regularFinishTimes,
                              chosenIrregularDays,
                              chosenIrregularStartTime,
                              chosenIrregularEndTime
                          );

                          if (checkDates != 'success'){
                            setState(() {
                              saving = false;
                            });
                            showSnackBar(context, checkDates, AppColors.attentionRed, 2);
                          } else {
                            // Выгружаем пользователя в БД

                            // Включаем экран загрузки
                            setState(() {
                              saving = true;
                            });

                            // Создаем переменную для нового аватара
                            String? imageUrl;

                            // ---- ЕСЛИ ВЫБРАНА НОВАЯ КАРТИНКА -------
                            if (_imageFile != null) {

                              // Сжимаем изображение
                              final compressedImage = await imagePickerService.compressImage(_imageFile!);



                              // Выгружаем изображение в БД и получаем URL картинки
                              imageUrl = await imageUploader.uploadImage(promoId, compressedImage, ImageFolderEnum.promos);

                              // Если URL аватарки есть
                              if (imageUrl != null) {
                                _showSnackBar(
                                  "Изображение загружено",
                                  Colors.green,
                                  1,
                                );
                              } else {
                                _showSnackBar(
                                  "Изображение загружено",
                                  Colors.green,
                                  1,
                                );
                              }
                            }

                            if (chosenPlace.id != ''){
                              setState(() {
                                streetController.text = chosenPlace.street;
                                houseController.text = chosenPlace.house;
                              });

                            }



                            PromoCustom promo = PromoCustom(
                                id: promoId,
                                dateType: dateTypeEnum, // сделать функционал
                                headline: headlineController.text,
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
                                imageUrl: imageUrl ?? widget.promoInfo.imageUrl,
                                placeId: chosenPlace.id, // сделать функционал
                                onceDay: widget.promoInfo.onceDay.generateDateForEntity(
                                    OnceDate.generateOnceMapForEntity(
                                        selectedDayInOnceType,
                                        onceDayStartTime,
                                        onceDayFinishTime
                                    )
                                ), // сделать функционал
                                longDays: widget.promoInfo.longDays.generateDateForEntity(
                                    LongDate.generateLongMapForEntity(
                                        selectedStartDayInLongType,
                                        selectedEndDayInLongType,
                                        longDayStartTime,
                                        longDayFinishTime
                                    )
                                ), // сделать функционал
                                regularDays: widget.promoInfo.regularDays.generateDateForEntity(
                                    RegularDate.generateOnceMapForEntity(regularStartTimes, regularFinishTimes)
                                ),

                                irregularDays: widget.promoInfo.irregularDays.generateDateForEntity(
                                    IrregularDate.generateIrregularMapForEntity(
                                        chosenIrregularDays,
                                        chosenIrregularStartTime,
                                        chosenIrregularEndTime
                                    )
                                ),
                              favUsersIds: widget.promoInfo.favUsersIds,
                              inFav: false,
                              today: false,
                            );

                            String? editInDatabase = await promo.publishToDb();

                            // Если выгрузка успешна
                            if (editInDatabase == 'success') {

                              PromoCustom newPromo = PromoCustom.emptyPromo;

                              newPromo = await newPromo.getEntityByIdFromDb(promoId);

                              if (widget.promoInfo.placeId != '' && widget.promoInfo.placeId != chosenPlace.id) {

                                await widget.promoInfo.deleteEntityIdFromPlace(widget.promoInfo.placeId);

                              }

                              if (PlaceListManager.currentFeedPlacesList.placeList.isNotEmpty){

                                // При смене места удаляем акцию из подгруженного старого места

                                for(Place tempPlace in PlaceListManager.currentFeedPlacesList.placeList){
                                  if (tempPlace.id == widget.promoInfo.placeId){
                                    tempPlace.promosList.removeWhere((element) => element == promoId);
                                    break;
                                  }
                                }

                                // И добавляем акию в новое выбранное место

                                for(Place tempPlace in PlaceListManager.currentFeedPlacesList.placeList){
                                  if (tempPlace.id == chosenPlace.id){
                                    if (!tempPlace.promosList.contains(promoId)){
                                      tempPlace.promosList.add(promoId);
                                      break;
                                    }
                                  }
                                }

                              }

                              // Если в передаваемом месте нет имени, т.е это создание
                              if (widget.promoInfo.headline == ''){
                                // То добавляем в списки новое созданное место
                                newPromo.addEntityToCurrentEntitiesLists();
                              } else {
                                // Если редактирование, удаляем старое объявление
                                promo.deleteEntityFromCurrentEntityLists();

                                // Добавляем отредактированное
                                newPromo.addEntityToCurrentEntitiesLists();
                              }

                              // Выключаем экран загрузки
                              setState(() {
                                saving = false;
                              });
                              // Показываем всплывающее сообщение
                              _showSnackBar(
                                "Прекрасно! Данные опубликованы!",
                                Colors.green,
                                1,
                              );

                              if (widget.promoInfo.id.isNotEmpty){
                                navigateToPreviousScreen();
                              } else {
                                // Уходим на страницу мероприятий
                                navigateToPromos();
                              }

                            }

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
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
            ]
        )
    );
  }

  void _showSnackBar(String text, Color color, int time){
    showSnackBar(context, text, color, time);
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

  void _fillRegularList (){

    for (int i = 0; i<regularStartTimes.length; i++){


      regularStartTimes[i] = widget.promoInfo.regularDays.getDayFromIndex(i).startTime.toString();
      regularFinishTimes[i] = widget.promoInfo.regularDays.getDayFromIndex(i).endTime.toString();

    }
  }

  Route _createPopupCategory(List<PromoCategory> categories) {
    return PageRouteBuilder(

      pageBuilder: (context, animation, secondaryAnimation) {

        return PromoCategoryPickerPage(categories: categories);
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

  void _showPlacePickerDialog() async {
    final selectedPlace = await Navigator.of(context).push(_createPopupPlace(myPlaces));

    if (selectedPlace != null) {
      setState(() {
        chosenPlace = selectedPlace;
        chosenCity = chosenPlace.city;
      });
    }
  }

  Route _createPopupPlace(PlaceList places) {
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
      transitionDuration: const Duration(milliseconds: 100),

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
        DateTime? firstDate,
        DateTime? endDate,
      }
      ) async {

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