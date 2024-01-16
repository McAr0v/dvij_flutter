import 'package:dvij_flutter/classes/event_category_class.dart';
import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/screens/event_categories_screens/event_categories_list_screen.dart';
import 'package:dvij_flutter/screens/place_categories_screens/place_categories_list_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../elements/custom_snack_bar.dart';

class EventCategoryAddOrEditScreen extends StatefulWidget {
  final EventCategory? eventCategory;

  const EventCategoryAddOrEditScreen({Key? key, this.eventCategory}) : super(key: key);

  @override
  _EventCategoryAddOrEditScreenState createState() => _EventCategoryAddOrEditScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class _EventCategoryAddOrEditScreenState extends State<EventCategoryAddOrEditScreen> {
  final TextEditingController _categoryNameController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Влючаем экран загрузки
    loading = false;
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.eventCategory != null) {
      _categoryNameController.text = widget.eventCategory!.name;
    }
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToEventCategoriesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EventCategoriesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.eventCategory != null ? 'Редактирование категории мероприятия' : 'Создание категории мероприятия'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventCategoriesListScreen(),
                ),
              );
            },
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет публикация категории",)
            else Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),

                  // ---- Поле ввода города ---

                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: _categoryNameController,
                    decoration: const InputDecoration(
                      labelText: 'Название категории мероприятия',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // ---- Кнопка опубликовать -----

                  // TODO Пока публикуется сделать экран загрузки
                  CustomButton(
                      buttonText: 'Опубликовать',
                      onTapMethod: (){
                        if (_categoryNameController.text == ''){
                          showSnackBar(
                              'Название категории должно быть обязательно заполнено!',
                              AppColors.attentionRed,
                              2
                          );
                        } else {
                          _publishEventCategory();
                        }

                      }
                  ),

                  SizedBox(height: 20.0),

                  // -- Кнопка отменить ----

                  CustomButton(
                      state: 'secondary',
                      buttonText: "Отменить",
                      onTapMethod: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventCategoriesListScreen(),
                          ),
                        );
                      }
                  )
                ],
              ),
            ),
          ],
        )
    );
  }

  void _publishEventCategory() async {

    loading = true;

    String categoryName = _categoryNameController.text;

    String result;

    if (widget.eventCategory != null) {
      // Редактирование города
      result = await EventCategory.addAndEditEventCategory(categoryName, id: widget.eventCategory?.id ?? '');

    } else {
      // Создание нового города
      result = await EventCategory.addAndEditEventCategory(categoryName);

    }

    if (result == 'success'){
      loading = false;
      showSnackBar('Категория успешно опубликована', Colors.green, 3);
      // Возвращаемся на экран списка городов
      // TODO - Вывести переход на страницу выше, за пределы виджета
      navigateToEventCategoriesListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация города не удалась
    }
  }
}