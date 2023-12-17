import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../themes/app_colors.dart';

class CityPickerPage extends StatefulWidget {
  final List<City> cities;

  CityPickerPage({required this.cities});

  @override
  _CityPickerPageState createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<CityPickerPage> {
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
    return Scaffold(
      backgroundColor: AppColors.greyBackground.withOpacity(0.5),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.greyBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Выберите город',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск города...',
                  ),
                  onChanged: (value) {
                    updateFilteredCities(value);
                  },
                ),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: Container (
                  padding: EdgeInsets.all(15),
                  //color: AppColors.greyOnBackground,
                  decoration: BoxDecoration(
                    color: AppColors.greyOnBackground,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SingleChildScrollView(
                    //padding: EdgeInsets.all(15),
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
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}