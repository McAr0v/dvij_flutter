import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../themes/app_colors.dart';

class PromoCategoryPickerPage extends StatefulWidget {
  final List<PromoCategory> categories;

  PromoCategoryPickerPage({required this.categories});

  @override
  _PromoCategoryPickerPageState createState() => _PromoCategoryPickerPageState();
}

class _PromoCategoryPickerPageState extends State<PromoCategoryPickerPage> {
  TextEditingController searchController = TextEditingController();
  List<PromoCategory> filteredCategories = [];

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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Выбери категорию акции',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
                        softWrap: true,
                      ),
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
                        children: filteredCategories.map((PromoCategory category) {
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