import 'package:dvij_flutter/classes/gender_class.dart';
import 'package:dvij_flutter/elements/genders_elements/gender_element_in_genders_screen.dart';
import 'package:dvij_flutter/screens/genders_screens/gender_add_or_edit_screen.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../elements/cities_elements/city_element_in_cities_screen.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';


class GendersListScreen extends StatefulWidget {
  const GendersListScreen({Key? key}) : super(key: key);

  @override
  _GendersListScreenState createState() => _GendersListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class _GendersListScreenState extends State<GendersListScreen> {

  // Список гендеров
  List<Gender> _genders = [];

  // Переменная для отслеживания направления сортировки
  bool _isAscending = true;

  // Переменная, включающая экран загрузки
  bool loading = true;

  // --- Инициализируем состояние экрана ----
  @override
  void initState() {
    super.initState();

    // Влючаем экран загрузки
    loading = true;
    // Получаем список гендеров

    if (Gender.currentGenderList.isNotEmpty)
    {
      _genders = Gender.currentGenderList;
    }

    loading = false;

  }

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Верхняя панель -----
        appBar: AppBar(
          title: const Text('Список гендеров'),

          // ---- Кнопки управления в AppBar ---
          actions: [

            // СОРТИРОВКА

            IconButton(
              icon: Icon(
                Icons.sort,
                color: _isAscending ? AppColors.white : AppColors.brandColor, // Изменение цвета иконки
              ),
              onPressed: () {
                // Инвертируем направление сортировки
                setState(() {
                  _isAscending = !_isAscending;
                });
                // Сортируем список городов
                Gender.sortGendersByName(_genders, _isAscending);
              },
            ),

            // Добавление нового города

            IconButton(
              icon: const Icon(Icons.add),

              // Переход на страницу создания города
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenderEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        // ----- Само тело экрана ------

        body: Stack (
          children: [
            // --- ЕСЛИ ЭКРАН ЗАГРУЗКИ -----
            if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка списка гендеров')
            // --- ЕСЛИ ГОРОДОВ НЕТ -----
            else if (_genders.isEmpty) const Center(child: Text('Список гендеров пуст'))
            // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
            else ListView.builder(
                // Открываем создатель списков
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _genders.length,
                  // Шаблоны для элементов
                  itemBuilder: (context, index) {
                    return GenderElementInGendersScreen(
                        gender: _genders[index],
                        onTapMethod: () async {

                          setState(() {
                            loading = true;
                          });

                          String result = await Gender.deleteGender(_genders[index].id);

                          if (result == 'success') {
                            setState(() {
                              _genders = Gender.currentGenderList;
                            });
                            //_getCitiesFromDatabase();
                            showSnackBar('Гендер успешно удален', Colors.green, 3);
                          } else {
                            showSnackBar('Произошла ошибка удаления гендера(', AppColors.attentionRed, 3);
                          }

                          setState(() {
                            loading = false;
                          });

                        },
                        index: index);
                  }
              )
          ],
        )
    );
  }
}
