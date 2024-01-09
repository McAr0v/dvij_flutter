import 'package:dvij_flutter/classes/place_role_class.dart';
import 'package:flutter/material.dart';
import '../../classes/city_class.dart';
import '../../themes/app_colors.dart';

class PlaceRolesChoosePage extends StatefulWidget {
  final List<PlaceRole> roles;

  PlaceRolesChoosePage({required this.roles});

  @override
  _PlaceRolesChoosePageState createState() => _PlaceRolesChoosePageState();
}

class _PlaceRolesChoosePageState extends State<PlaceRolesChoosePage> {
  TextEditingController searchController = TextEditingController();
  List<PlaceRole> filteredRoles = [];

  @override
  void initState() {
    super.initState();
    filteredRoles = List.from(widget.roles);
  }

  void updateFilteredRoles(String query) {
    setState(() {
      filteredRoles = widget.roles
          .where((role) =>
          role.name.toLowerCase().contains(query.toLowerCase()))
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
                      'Выбери роль',
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
                    hintText: 'Поиск роли...',
                  ),
                  onChanged: (value) {
                    updateFilteredRoles(value);
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
                        children: filteredRoles.map((PlaceRole role) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(role);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(role.name),
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