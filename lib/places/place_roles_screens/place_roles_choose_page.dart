import 'package:dvij_flutter/users/place_users_roles.dart';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

class PlaceRolesChoosePage extends StatefulWidget {
  const PlaceRolesChoosePage({super.key});

  @override
  PlaceRolesChoosePageState createState() => PlaceRolesChoosePageState();
}

class PlaceRolesChoosePageState extends State<PlaceRolesChoosePage> {
  TextEditingController searchController = TextEditingController();
  PlaceUserRole placeRole = PlaceUserRole();
  List<PlaceUserRole> filteredRoles = [];

  @override
  void initState() {
    super.initState();
    filteredRoles = placeRole.getPlaceUserRoleList();
  }

  void updateFilteredRoles(String query) {
    setState(() {
      filteredRoles = filteredRoles
          .where((role) =>
          role.title.toLowerCase().contains(query.toLowerCase()))
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
                    hintText: 'Поиск роли...',
                  ),
                  onChanged: (value) {
                    updateFilteredRoles(value);
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
                        children: filteredRoles.map((PlaceUserRole role) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(role);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(role.title, style: Theme.of(context).textTheme.bodyMedium,),
                                  Text(role.desc, style: Theme.of(context).textTheme.labelMedium),
                                  Text(role.controlLevel.toString(), style: Theme.of(context).textTheme.labelMedium)
                                ],
                              ),
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