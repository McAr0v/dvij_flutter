import 'package:dvij_flutter/places/place_categories_screens/place_categories_list_screen.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';

class PlaceCategoryEditScreen extends StatefulWidget {
  final PlaceCategory? placeCategory;

  const PlaceCategoryEditScreen({Key? key, this.placeCategory}) : super(key: key);

  @override
  PlaceCategoryEditScreenState createState() => PlaceCategoryEditScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class PlaceCategoryEditScreenState extends State<PlaceCategoryEditScreen> {
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
    if (widget.placeCategory != null) {
      _categoryNameController.text = widget.placeCategory!.name;
    }
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToPlaceCategoriesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PlaceCategoriesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.placeCategory != null ? 'Редактирование категории места' : 'Создание категории места'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaceCategoriesListScreen(),
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
                      labelText: 'Название категории места',
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
                          _publishPlaceCategory();
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
                            builder: (context) => const PlaceCategoriesListScreen(),
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

  void _publishPlaceCategory() async {

    loading = true;

    String categoryName = _categoryNameController.text;

    PlaceCategory publishedCategory = PlaceCategory(name: categoryName, id: '');

    if (widget.placeCategory != null) {
      publishedCategory.id = widget.placeCategory?.id ?? '';
    }

    String result = await publishedCategory.addOrEditEntityInDb();

    if (result == 'success'){
      loading = false;
      showSnackBar('Категория успешно опубликована', Colors.green, 3);
      // Возвращаемся на экран списка городов
      // TODO - Вывести переход на страницу выше, за пределы виджета
      navigateToPlaceCategoriesListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация города не удалась
    }

  }
}