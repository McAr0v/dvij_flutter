import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../elements/choose_dialogs/city_choose_dialog.dart';

class EventsFeedPage extends StatefulWidget {
  const EventsFeedPage({Key? key}) : super(key: key);

  @override
  _EventsFeedPageState createState() => _EventsFeedPageState();
}

class _EventsFeedPageState extends State<EventsFeedPage> {

  List<City> _cities = [];

  City selectedCity = City(id: "", name: "");

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
            Text(
              'Selected city:',
            ),
            Text(
              '${selectedCity.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showCityPickerDialog();
              },
              child: Text('Choose a city'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCityPickerDialog() async {
    final selectedCity = await showDialog<City>(
      context: context,
      builder: (BuildContext context) {
        return CityChooseDialog(cities: _cities);
      },
    );

    if (selectedCity != null) {
      setState(() {
        this.selectedCity = selectedCity;
      });
      print("Selected city: ${selectedCity.name}, ID: ${selectedCity.id}");
    }
  }

  /*Future<void> _showCityPickerDialog(BuildContext context) async {
    final selectedCity = await showDialog<City>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose a city'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _cities.map((City city) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(city);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(city.name),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCity != null) {
      setState(() {
        this.selectedCity = selectedCity;
      });
      print("Selected city: ${selectedCity.name}, ID: ${selectedCity.id}");
    }
  }*/


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


}