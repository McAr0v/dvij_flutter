import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import 'city_add_or_edit_screen.dart';

class CitiesListScreen extends StatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  _CitiesListScreenState createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends State<CitiesListScreen> {
  List<City> _cities = [];

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
      body: _buildCitiesList(),
    );
  }

  Future<void> _getCitiesFromDatabase() async {
    try {
      List<City> cities = await City.getCities();
      setState(() {
        _cities = cities;
      });
    } catch (error) {
      print('Ошибка при получении городов: $error');
    }
  }

  Widget _buildCitiesList() {
    if (_cities.isEmpty) {
      return Center(child: Text('Список городов пуст'));
    } else {
      return ListView.builder(
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_cities[index].name),
            subtitle: Text('ID: ${_cities[index].id}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityEditScreen(city: _cities[index]),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {

                    String result = await City.deleteCity(_cities[index].id);

                    if (result == 'success') {
                      _getCitiesFromDatabase();
                      //TODO Сделать всплывающее оповещение что успешно
                    }

                    // Добавить функционал удаления города
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}