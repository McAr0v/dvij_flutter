import 'package:flutter/material.dart';
import '../../cities/city_class.dart';

class CityChooseDialog extends StatefulWidget {
  final List<City> cities;

  CityChooseDialog({required this.cities});

  @override
  _CityChooseDialogState createState() => _CityChooseDialogState();
}

class _CityChooseDialogState extends State<CityChooseDialog> {
  TextEditingController searchController = TextEditingController();
  List<City> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCities = List.from(widget.cities);
  }

  void updateFilteredCities(String query) {
    setState(() {
      filteredCities = widget.cities
          .where((city) =>
          city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Выберите город'),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Поиск города...',
            ),
            onChanged: updateFilteredCities,
          ),
          SizedBox(height: 8.0),
          Expanded(
            child: SingleChildScrollView(
              child: ListBody(
                children: filteredCities.map((City city) {
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
          ),
        ],
      ),
    );
  }
}