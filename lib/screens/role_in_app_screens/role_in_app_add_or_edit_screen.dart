import 'package:dvij_flutter/classes/role_in_app.dart';
import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/screens/role_in_app_screens/roles_in_app_list_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../elements/custom_snack_bar.dart';

class RoleInAppAddOrEditScreen extends StatefulWidget {
  final RoleInApp? roleInApp;

  const RoleInAppAddOrEditScreen({Key? key, this.roleInApp}) : super(key: key);

  @override
  _RoleInAppAddOrEditScreenState createState() => _RoleInAppAddOrEditScreenState();
}

// ---- Экран редактирования или создания роли в приложении ----

// Принцип простой, если на экран не передается роль, то это создание роли
// Если передается, то название роли уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже рооль с таким названием?. Если да выводить всплывающее меню

class _RoleInAppAddOrEditScreenState extends State<RoleInAppAddOrEditScreen> {
  final TextEditingController _roleInAppNameController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Влючаем экран загрузки
    loading = false;
    // Если передана роль для редактирования, устанавливаем название в поле ввода
    if (widget.roleInApp != null) {
      _roleInAppNameController.text = widget.roleInApp!.name;
    }
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToRoleInAppListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RolesInAppListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.roleInApp != null ? 'Редактирование роли для приложения' : 'Создание роли для приложения'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const RolesInAppListScreen(),
                ),
              );
            },
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет публикация роли",)
            else Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),

                  // ---- Поле ввода города ---

                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: _roleInAppNameController,
                    decoration: const InputDecoration(
                      labelText: 'Название роли',
                      prefixIcon: Icon(Icons.place),
                    ),
                  ),

                  SizedBox(height: 40.0),

                  // ---- Кнопка опубликовать -----

                  // TODO Пока публикуется сделать экран загрузки
                  CustomButton(
                      buttonText: 'Опубликовать',
                      onTapMethod: (){
                        if (_roleInAppNameController.text == ''){
                          showSnackBar(
                              'Название роли должно быть обязательно заполнено!',
                              AppColors.attentionRed,
                              2
                          );
                        } else {
                          _publishRoleInApp();
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
                            builder: (context) => const RolesInAppListScreen(),
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

  void _publishRoleInApp() async {

    loading = true;

    String roleInAppName = _roleInAppNameController.text;

    String result;

    if (widget.roleInApp != null) {
      // Редактирование роли
      result = await RoleInApp.addAndEditRoleInApp(roleInAppName, id: widget.roleInApp?.id ?? '');
    } else {
      // Создание новой роли
      result = await RoleInApp.addAndEditRoleInApp(roleInAppName);
    }

    if (result == 'success'){
      loading = false;
      showSnackBar('Роль успешно опубликована', Colors.green, 3);
      // Возвращаемся на экран списка городов
      // TODO - Вывести переход на страницу выше, за пределы виджета
      navigateToRoleInAppListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация роли не удалась
    }


  }
}