import 'package:dvij_flutter/classes/role_in_app.dart';
import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../classes/gender_class.dart';
import '../../themes/app_colors.dart';

class RoleInAppPickerPage extends StatefulWidget {
  final List<RoleInApp> rolesInApp;

  const RoleInAppPickerPage({super.key, required this.rolesInApp});

  @override
  _GenderPickerPage createState() => _GenderPickerPage();
}

class _GenderPickerPage extends State<RoleInAppPickerPage> {
  TextEditingController searchController = TextEditingController();
  List<RoleInApp> filteredRolesInApp = [];

  @override
  void initState() {
    super.initState();
    filteredRolesInApp = List.from(widget.rolesInApp);
  }

  void updateFilteredRolesInApp(String query) {
    setState(() {
      filteredRolesInApp = widget.rolesInApp
          .where((roleInApp) =>
          roleInApp.name.toLowerCase().contains(query.toLowerCase()))
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
                      'Выберите роль в приложении',
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
                  decoration: const InputDecoration(
                    hintText: 'Поиск роли для приложения...',
                  ),
                  onChanged: (value) {
                    updateFilteredRolesInApp(value);
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
                        children: filteredRolesInApp.map((RoleInApp roleInApp) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(roleInApp);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(roleInApp.name),
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