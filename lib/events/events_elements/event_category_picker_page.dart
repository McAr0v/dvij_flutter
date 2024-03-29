import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class EventCategoryPickerPage extends StatefulWidget {
  final List<EventCategory> categories;

  const EventCategoryPickerPage({super.key, required this.categories});

  @override
  EventCategoryPickerPageState createState() => EventCategoryPickerPageState();
}

class EventCategoryPickerPageState extends State<EventCategoryPickerPage> {
  TextEditingController searchController = TextEditingController();
  List<EventCategory> filteredCategories = [];

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
                          'Выбери категорию мероприятия',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
                          softWrap: true,
                        ),
                      ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
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
                  decoration: const InputDecoration(
                    hintText: 'Поиск категории...',
                  ),
                  onChanged: (value) {
                    updateFilteredCategories(value);
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                  child: Container (
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.greyOnBackground,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      child: ListBody(
                        children: filteredCategories.map((EventCategory category) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(category);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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