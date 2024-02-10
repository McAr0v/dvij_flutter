import 'package:dvij_flutter/promos/promo_categories_screen/promo_categories_list_screen.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../elements/snack_bar.dart';

class PromoCategoryAddOrEditScreen extends StatefulWidget {
  final PromoCategory? promoCategory;

  const PromoCategoryAddOrEditScreen({Key? key, this.promoCategory}) : super(key: key);

  @override
  PromoCategoryAddOrEditScreenState createState() => PromoCategoryAddOrEditScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class PromoCategoryAddOrEditScreenState extends State<PromoCategoryAddOrEditScreen> {
  final TextEditingController _categoryNameController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;
  bool saving = false;
  bool deleting = false;

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Влючаем экран загрузки
    loading = false;
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.promoCategory != null) {
      _categoryNameController.text = widget.promoCategory!.name;
    }
  }

  void navigateToPromoCategoriesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PromoCategoriesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.promoCategory != null ? 'Редактирование категории акции' : 'Создание категории акции'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: navigateToPromoCategoriesListScreen,
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет загрузка категорий",)
            else if (saving) const LoadingScreen(loadingText: "Идет публикация категории",)
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
                      labelText: 'Название категории акции',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // ---- Кнопка опубликовать -----


                  CustomButton(
                      buttonText: 'Опубликовать',
                      onTapMethod: (){
                        if (_categoryNameController.text == ''){
                          showSnackBar(
                            context,
                              'Название категории должно быть обязательно заполнено!',
                              AppColors.attentionRed,
                              2
                          );
                        } else {

                          _publishPromoCategory();
                        }

                      }
                  ),

                  SizedBox(height: 20.0),

                  // -- Кнопка отменить ----

                  CustomButton(
                      state: 'secondary',
                      buttonText: "Отменить",
                      onTapMethod: navigateToPromoCategoriesListScreen
                  )
                ],
              ),
            ),
          ],
        )
    );
  }

  void _publishPromoCategory() async {

    setState(() {
      saving = true;
    });

    String categoryName = _categoryNameController.text;

    PromoCategory publishedCategory = PromoCategory(name: categoryName, id: '');

    if (widget.promoCategory != null) {
      publishedCategory.id = widget.promoCategory?.id ?? '';
    }

    String result = await publishedCategory.addOrEditEntityInDb();


    if (result == 'success'){
      setState(() {
        saving = false;
      });
      showSnackBar(context, 'Категория успешно опубликована', Colors.green, 3);
      // Возвращаемся на экран списка городов
      // TODO - Вывести переход на страницу выше, за пределы виджета
      navigateToPromoCategoriesListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация города не удалась
    }
  }
}