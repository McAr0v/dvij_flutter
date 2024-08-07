import 'package:dvij_flutter/cities/city_list_extention.dart';
import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/exit_dialog/exit_dialog.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import '../cities_elements/city_element_in_cities_screen.dart';
import 'city_add_or_edit_screen.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  State<CitiesListScreen> createState() => _CitiesListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class _CitiesListScreenState extends State<CitiesListScreen> {

  // Список городов
  List<City> _cities = [];

  // Переменная для отслеживания направления сортировки
  bool _isAscending = true;

  // Переменная, включающая экран загрузки
  bool loading = true;
  bool deleting = false;

  // --- Инициализируем состояние экрана ----
  @override
  void initState() {
    super.initState();

    // Влючаем экран загрузки
    loading = true;

    if (City.currentCityList.isNotEmpty)
      {
        _cities = City.currentCityList;
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
        title: const Text('Список городов'),

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
              _cities.sortCities(_isAscending);
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
                  builder: (context) => const CityEditScreen(),
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
          if (loading) const LoadingScreen(loadingText: 'Подожди, идет загрузка городов')
          else if (deleting) const LoadingScreen(loadingText: 'Подожди, идет удаление города')
          // --- ЕСЛИ ГОРОДОВ НЕТ -----
          else if (_cities.isEmpty) const Center(child: Text('Список городов пуст'))
          // --- ЕСЛИ ГОРОДА ЗАГРУЗИЛИСЬ
          else ListView.builder(
              // Открываем создатель списков
                padding: const EdgeInsets.all(20.0),
                itemCount: _cities.length,
                // Шаблоны для элементов
                itemBuilder: (context, index) {
                  return CityElementInCitiesScreen(
                      city: _cities[index],
                      onTapMethod: () async {

                        bool? confirmed = await exitDialog(context, "Ты правда хочешь удалить город?" , 'Да', 'Нет', 'Удаление города');

                        if (confirmed != null && confirmed){
                          setState(() {
                            deleting = true;
                          });

                          String result = await _cities[index].deleteEntityFromDb();

                          if (result == 'success') {
                            setState(() {
                              _cities = City.currentCityList;
                            });
                            showSnackBar('Город успешно удален', Colors.green, 3);
                          } else {
                            showSnackBar('Произошла ошибка удаления города(', AppColors.attentionRed, 3);
                          }

                          setState(() {
                            deleting = false;
                          });
                        }
                      },
                      index: index
                  );
                }
            )
        ],
      )
    );
  }
}
