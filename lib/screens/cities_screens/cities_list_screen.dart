import 'dart:html';

import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../elements/cities_elements/city_element_in_cities_screen.dart';
import '../../elements/custom_snack_bar.dart';
import '../../elements/loading_screen.dart';
import '../../themes/app_colors.dart';
import 'city_add_or_edit_screen.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  _CitiesListScreenState createState() => _CitiesListScreenState();
}

// ---- Страница списка городов (Должна быть доступна только для админа)------

class _CitiesListScreenState extends State<CitiesListScreen> {

  // Список городов
  List<City> _cities = [];

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
    // Получаем список городов
    _getCitiesFromDatabase();

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
        title: Text('Список городов'),

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
              City.sortCitiesByName(_cities, _isAscending);
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
          // --- ЕСЛИ ГОРОДОВ НЕТ -----
          else if (_cities.isEmpty) Center(child: Text('Список городов пуст'))
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

                        loading = true;

                        String result = await City.deleteCity(_cities[index].id);

                        loading = false;

                        if (result == 'success') {
                          showSnackBar('Город успешно удален', Colors.green, 3);
                        } else {
                          showSnackBar('Произошла ошибка удаления города(', AppColors.attentionRed, 3);
                        }

                      },
                      index: index);
                }
            )
        ],
      )
    );
  }

  // ---- Функция получения городов из БД -----

  Future<void> _getCitiesFromDatabase() async {
    try {
      // --- Получаем список городов -----
      List<City> cities = await City.getCities(order: _isAscending);

      // ---- Убираем экран загрузки -----
      // ---- Подгружаем в переменную загруженные города -----
      setState(() {
        loading = false;
        _cities = cities;
      });
    } catch (error) {
      // TODO Сделать вывод всплывающего меню, если произошла ошибка
      print('Ошибка при получении городов: $error');
    }
  }

  // ---- Функция удаления элемента из отображаемого списка ----
  // ---- По факту, основной процесс происходит в виджете CityElementInCitiesScreen
  // ---- Здесь он лишь убирается из видимого списка

  void _onDeleteCity(String cityId) {
    setState(() {
      loading = true;
      _cities.removeWhere((city) => city.id == cityId);
      loading = false;
      showSnackBar('Город успешно удален', Colors.green, 3);
    });
  }
}
