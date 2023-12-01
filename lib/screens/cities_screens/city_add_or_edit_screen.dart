import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import 'cities_list_screen.dart'; // Импортируем экран списка городов

class CityEditScreen extends StatefulWidget {
  final City? city;

  const CityEditScreen({Key? key, this.city}) : super(key: key);

  @override
  _CityEditScreenState createState() => _CityEditScreenState();
}

class _CityEditScreenState extends State<CityEditScreen> {
  final TextEditingController _cityNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.city != null) {
      _cityNameController.text = widget.city!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city != null ? 'Редактирование города' : 'Создание города'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityNameController,
              decoration: InputDecoration(labelText: 'Название города'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _publishCity();
              },
              child: Text('Опубликовать'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Возвращаемся на предыдущий экран
              },
              child: Text('Отменить'),
            ),
          ],
        ),
      ),
    );
  }

  void _publishCity() async {
    String cityName = _cityNameController.text;

    String result;

    if (widget.city != null) {
      // Редактирование города
      result = await City.addAndEditCity(cityName, id: widget.city?.id ?? '');
    } else {
      // Создание нового города
      result = await City.addAndEditCity(cityName);
    }

    if (result == 'success'){
      // TODO - Сделать всплывающее оповещение
      // Возвращаемся на экран списка городов
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CitiesListScreen()),
      );
    }


  }
}