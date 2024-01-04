import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/screens/genders_screens/genders_list_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../classes/gender_class.dart';
import '../../elements/custom_snack_bar.dart';

class GenderEditScreen extends StatefulWidget {
  final Gender? gender;

  const GenderEditScreen({Key? key, this.gender}) : super(key: key);

  @override
  _GenderEditScreenState createState() => _GenderEditScreenState();
}

// ---- Экран редактирования или создания гендера ----

// Принцип простой, если на экран не передается гендер, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже гендер с таким названием?. Если да выводить всплывающее меню

class _GenderEditScreenState extends State<GenderEditScreen> {
  final TextEditingController _genderNameController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Влючаем экран загрузки
    loading = false;
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.gender != null) {
      _genderNameController.text = widget.gender!.name;
    }
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToGendersListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GendersListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.gender != null ? 'Редактирование гендера' : 'Создание гендера'),

          // Задаем особый выход на кнопку назад
          // Чтобы не плодились экраны назад с разным списком городов

          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GendersListScreen(),
                ),
              );
            },
          ),
        ),

        // --- Само тело страницы ----

        body: Stack(
          children: [
            if (loading) const LoadingScreen(loadingText: "Идет публикация гендера",)
            else Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),

                  // ---- Поле ввода города ---

                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: TextInputType.text,
                    controller: _genderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Название гендера',
                      prefixIcon: Icon(Icons.place),
                    ),
                  ),

                  const SizedBox(height: 40.0),

                  // ---- Кнопка опубликовать -----

                  // TODO Пока публикуется сделать экран загрузки
                  CustomButton(
                      buttonText: 'Опубликовать',
                      onTapMethod: (){
                        if (_genderNameController.text == ''){
                          showSnackBar(
                              'Название гендера должно быть обязательно заполнено!',
                              AppColors.attentionRed,
                              2
                          );
                        } else {
                          _publishGender();
                        }

                      }
                  ),

                  const SizedBox(height: 20.0),

                  // -- Кнопка отменить ----

                  CustomButton(
                      state: 'secondary',
                      buttonText: "Отменить",
                      onTapMethod: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GendersListScreen(),
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

  void _publishGender() async {

    loading = true;

    String genderName = _genderNameController.text;

    String result;

    if (widget.gender != null) {
      // Редактирование гендера
      result = await Gender.addAndEditGender(genderName, id: widget.gender?.id ?? '');
    } else {
      // Создание нового гендера
      result = await Gender.addAndEditGender(genderName);
    }

    if (result == 'success'){
      loading = false;
      showSnackBar('Гендер успешно опубликован', Colors.green, 3);
      // Возвращаемся на экран списка гендеров
      // TODO - Вывести переход на страницу выше, за пределы виджета
      navigateToGendersListScreen();
    } else {
      // TODO Сделать обработчик ошибок, если публикация города не удалась
    }


  }
}