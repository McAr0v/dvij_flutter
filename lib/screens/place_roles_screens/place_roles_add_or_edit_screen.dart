import 'package:dvij_flutter/classes/place_category_class.dart';
import 'package:dvij_flutter/classes/place_role_class.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/screens/place_categories_screens/place_categories_list_screen.dart';
import 'package:dvij_flutter/screens/place_roles_screens/place_roles_list_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/city_class.dart';
import '../../elements/custom_snack_bar.dart';

class PlaceRoleAddOrEditScreen extends StatefulWidget {
  final PlaceRole? placeRole;

  const PlaceRoleAddOrEditScreen({Key? key, this.placeRole}) : super(key: key);

  @override
  _PlaceRoleAddOrEditScreenState createState() => _PlaceRoleAddOrEditScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class _PlaceRoleAddOrEditScreenState extends State<PlaceRoleAddOrEditScreen> {
  final TextEditingController _placeRoleNameController = TextEditingController();
  final TextEditingController _placeRoleDescController = TextEditingController();
  final TextEditingController _placeRoleControlLevelController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Влючаем экран загрузки
    loading = false;
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.placeRole != null) {
      _placeRoleNameController.text = widget.placeRole!.name;
      _placeRoleDescController.text = widget.placeRole!.desc;
      _placeRoleControlLevelController.text = widget.placeRole!.controlLevel;
    }
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToPlaceRolesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PlaceRolesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.placeRole != null ? 'Редактирование роли места' : 'Создание роли места'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaceRolesListScreen(),
                ),
              );
            },
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет публикация роли",)
            else SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40.0),

                    // ---- Поле ввода города ---

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.text,
                      controller: _placeRoleNameController,
                      decoration: const InputDecoration(
                        labelText: 'Название категории места',
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.multiline,
                      controller: _placeRoleDescController,
                      decoration: const InputDecoration(
                        labelText: 'Описание роли места',
                        prefixIcon: Icon(Icons.category),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      onEditingComplete: () {
                        // Обработка события, когда пользователь нажимает Enter
                        // Вы можете добавить здесь любой код, который нужно выполнить при нажатии Enter
                      },
                    ),

                    const SizedBox(height: 20.0),

                    TextField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      keyboardType: TextInputType.number,
                      controller: _placeRoleControlLevelController,
                      decoration: const InputDecoration(
                        labelText: 'Уровень контроля места',
                        prefixIcon: Icon(FontAwesomeIcons.sliders),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // ---- Кнопка опубликовать -----

                    // TODO Пока публикуется сделать экран загрузки
                    CustomButton(
                        buttonText: 'Опубликовать',
                        onTapMethod: (){
                          if (_placeRoleNameController.text == ''){
                            showSnackBar(
                                'Название роли должно быть обязательно заполнено!',
                                AppColors.attentionRed,
                                2
                            );
                          } else if (_placeRoleDescController.text == ''){
                            showSnackBar(
                                'Описание роли должно быть обязательно заполнено!',
                                AppColors.attentionRed,
                                2
                            );
                          } else {
                            _publishPlaceRole();
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
                              builder: (context) => const PlaceRolesListScreen(),
                            ),
                          );
                        }
                    )
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }

  void _publishPlaceRole() async {

    loading = true;

    String placeCategoryName = _placeRoleNameController.text;
    String placeCategoryDesc = _placeRoleDescController.text;
    String placeControlLevel = _placeRoleControlLevelController.text;

    String result;

    if (widget.placeRole != null) {
      // Редактирование города
      result = await PlaceRole.addAndEditPlaceRole(placeCategoryName, placeCategoryDesc, placeControlLevel, id: widget.placeRole?.id ?? '');

    } else {
      // Создание нового города
      result = await PlaceRole.addAndEditPlaceRole(placeCategoryName, placeCategoryDesc, placeControlLevel);

    }

    if (result == 'success'){
      loading = false;
      showSnackBar('Роль успешно опубликована', Colors.green, 3);
      // Возвращаемся на экран списка городов
      // TODO - Вывести переход на страницу выше, за пределы виджета
      navigateToPlaceRolesListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация города не удалась
    }


  }
}