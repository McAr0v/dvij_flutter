import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../classes/gender_class.dart';
import '../../themes/app_colors.dart';

class GenderPickerPage extends StatefulWidget {
  final List<Gender> genders;

  GenderPickerPage({required this.genders});

  @override
  _GenderPickerPage createState() => _GenderPickerPage();
}

class _GenderPickerPage extends State<GenderPickerPage> {
  TextEditingController searchController = TextEditingController();
  List<Gender> filteredGenders = [];

  @override
  void initState() {
    super.initState();
    filteredGenders = List.from(widget.genders);
  }

  void updateFilteredGenders(String query) {
    setState(() {
      filteredGenders = widget.genders
          .where((gender) =>
          gender.name.toLowerCase().contains(query.toLowerCase()))
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
                      'Выберите пол',
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
                    hintText: 'Поиск гендера...',
                  ),
                  onChanged: (value) {
                    updateFilteredGenders(value);
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
                        children: filteredGenders.map((Gender gender) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(gender);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(gender.name),
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