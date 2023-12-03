import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../elements/cities_elements/city_element_in_cities_screen.dart';
import '../../themes/app_colors.dart';
import 'city_add_or_edit_screen.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  _CitiesListScreenState createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends State<CitiesListScreen> {
  List<City> _cities = [];
  bool _isAscending = true; // Переменная для отслеживания направления сортировки

  @override
  void initState() {
    super.initState();
    _getCitiesFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список городов'),
        actions: [
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
              // Обновляем список городов с новым направлением сортировки
              _getCitiesFromDatabase();
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CityEditScreen()),
              );
            },
          ),
        ],
      ),
      body: CityElementInCitiesScreen(
        cities: _cities,
        onDeleteCity: _onDeleteCity,
      ),
    );
  }

  Future<void> _getCitiesFromDatabase() async {
    try {
      List<City> cities = await City.getCities(order: _isAscending);
      setState(() {
        _cities = cities;
      });
    } catch (error) {
      print('Ошибка при получении городов: $error');
    }
  }

  void _onDeleteCity(String cityId) {
    setState(() {
      _cities.removeWhere((city) => city.id == cityId);
    });
  }
}
