import 'package:flutter/material.dart';
import '../../cities/city_class.dart';

class EventsFeedPage extends StatefulWidget {
  const EventsFeedPage({Key? key}) : super(key: key);

  @override
  _EventsFeedPageState createState() => _EventsFeedPageState();
}

class _EventsFeedPageState extends State<EventsFeedPage> {
  final TextEditingController _editCityNameController = TextEditingController();
  final TextEditingController _editCityIdController = TextEditingController();
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
        title: Text('Мероприятия лента'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _editCityNameController,
              decoration: InputDecoration(labelText: 'Название города'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _editCityIdController,
              decoration: InputDecoration(labelText: 'ID города'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _editCityInDatabase();
              },
              child: Text('Редактировать город'),
            ),
            SizedBox(height: 16.0),
            _buildCitiesList(),
          ],
        ),
      ),
    );
  }

  void _editCityInDatabase() async {
    String editCityName = _editCityNameController.text;
    String editCityId = _editCityIdController.text;

    if (editCityName.isNotEmpty && editCityId.isNotEmpty) {
      String result = await City.addAndEditCity(editCityName, id: editCityId);

      // Вывод сообщения об успешном редактировании или ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
        ),
      );

      // Очистка полей ввода после редактирования
      _editCityNameController.clear();
      _editCityIdController.clear();

      // Обновление списка городов после редактирования
      await _getCitiesFromDatabase();
    } else {
      // Вывод сообщения о необходимости ввести название и ID города
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите название и ID города для редактирования'),
        ),
      );
    }
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
      return Text('Список городов пуст');
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: _cities.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_cities[index].name),
              subtitle: Text(_cities[index].id),
            );
          },
        ),
      );
    }
  }
}