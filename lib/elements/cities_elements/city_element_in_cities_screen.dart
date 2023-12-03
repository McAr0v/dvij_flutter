import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../screens/cities_screens/city_add_or_edit_screen.dart';

class CityElementInCitiesScreen extends StatelessWidget {
  final List<City> cities;
  final Function(String) onDeleteCity;

  const CityElementInCitiesScreen({Key? key, required this.cities, required this.onDeleteCity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildCitiesList();
  }

  Widget _buildCitiesList() {
    if (cities.isEmpty) {
      return Center(child: Text('Список городов пуст'));
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Row(
                children: [
                  // Порядковый номер строки
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${index + 1}.',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  // Название города и ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cities[index].name,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text('ID: ${cities[index].id}'),
                      ],
                    ),
                  ),
                  // Кнопки редактирования и удаления
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CityEditScreen(city: cities[index]),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          String result = await City.deleteCity(cities[index].id);

                          if (result == 'success') {
                            onDeleteCity(cities[index].id); // Уведомляем родительский виджет об удалении
                            //TODO Сделать всплывающее оповещение что успешно
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0), // Расстояние между элементами
            ],
          );
        },
      );
    }
  }
}