import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class PlaceCategoryPickerPage extends StatefulWidget {
  final List<PlaceCategory> categories;

  const PlaceCategoryPickerPage({super.key, required this.categories});

  @override
  PlaceCategoryPickerPageState createState() => PlaceCategoryPickerPageState();
}

class PlaceCategoryPickerPageState extends State<PlaceCategoryPickerPage> {
  TextEditingController searchController = TextEditingController();
  List<PlaceCategory> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = List.from(widget.categories);
  }

  void updateFilteredCategories(String query) {
    setState(() {
      filteredCategories = widget.categories
          .where((category) =>
          category.name.toLowerCase().contains(query.toLowerCase()))
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
                      'Выбери категорию места',
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
                    hintText: 'Поиск категории...',
                  ),
                  onChanged: (value) {
                    updateFilteredCategories(value);
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
                        children: filteredCategories.map((PlaceCategory category) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(category);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(category.name),
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