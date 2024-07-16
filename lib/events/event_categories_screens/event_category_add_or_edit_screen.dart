import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../elements/snack_bar.dart';
import 'event_categories_list_screen.dart';

class EventCategoryAddOrEditScreen extends StatefulWidget {
  final EventCategory? eventCategory;

  const EventCategoryAddOrEditScreen({Key? key, this.eventCategory}) : super(key: key);

  @override
  EventCategoryAddOrEditScreenState createState() => EventCategoryAddOrEditScreenState();
}

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class EventCategoryAddOrEditScreenState extends State<EventCategoryAddOrEditScreen> {

  final TextEditingController _categoryNameController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loading = false;
    if (widget.eventCategory != null) {
      _categoryNameController.text = widget.eventCategory!.name;
    }
  }

  void navigateToEventCategoriesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EventCategoriesListScreen()),
    );
  }

  void _showSnackBar(String message, Color color, int showTime) {
    showSnackBar(context, message, color, showTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.eventCategory != null ? 'Редактирование категории мероприятия' : 'Создание категории мероприятия'),

          // --- КНОПКА НАЗАД -----

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком

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

        // --- САМА СТРАНИЦА ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет публикация категории",)
            else Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),

                  // ---- ПОЛЕ ВВОДА ---

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

                  // ---- КНОПКА ОПУБЛИИКОВАТЬ -----

                  // TODO Пока публикуется сделать экран загрузки
                  CustomButton(
                      buttonText: 'Опубликовать',
                      onTapMethod: (){
                        if (_categoryNameController.text == ''){
                          _showSnackBar(
                              'Название категории должно быть обязательно заполнено!',
                              AppColors.attentionRed,
                              2
                          );
                        } else {
                          _publishEventCategory();
                        }

                      }
                  ),

                  const SizedBox(height: 20.0),

                  // -- Кнопка отменить ----

                  CustomButton(
                      state: CustomButtonState.secondary,
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

    setState(() {
      loading = true;
    });


    String categoryName = _categoryNameController.text;

    EventCategory publishedEventCategory = EventCategory(name: categoryName, id: '');

    if (widget.eventCategory != null) {
      publishedEventCategory.id = widget.eventCategory?.id ?? '';
    }

    String result = await publishedEventCategory.addOrEditEntityInDb();

    if (result == 'success'){
      setState(() {
        loading = false;
      });
      _showSnackBar('Категория успешно опубликована', Colors.green, 3);
      navigateToEventCategoriesListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация не удалась
    }
  }
}