import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_manager_add_screen.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/user_class.dart';
import '../../users/place_user_class.dart';
import '../../users/place_users_roles.dart';
import '../places_elements/place_managers_element_list_item.dart';

class PlaceAdminsScreen extends StatefulWidget {
  final Place place;

  PlaceAdminsScreen({Key? key, required this.place}) : super(key: key);

  @override
  PlaceAdminsScreenState createState() => PlaceAdminsScreenState();
}

class PlaceAdminsScreenState extends State<PlaceAdminsScreen> {

  List<PlaceUser> admins = [];
  PlaceUser creator = PlaceUser();
  bool loading = true;
  Place currentPlace = Place.emptyPlace;

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }

  Future<void> fetchAndSetData() async {
    setState(() {
      loading = true;
    });
    currentPlace = widget.place;
    admins = await creator.getAdminsInfoFromDb(widget.place.admins!);

    if (UserCustom.currentUser != null){
      if (widget.place.creatorId == UserCustom.currentUser!.uid){
        PlaceUserRole role = PlaceUserRole();
        creator = creator.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
        creator.placeUserRole = role.getPlaceUserRole(PlaceUserRoleEnum.creator);
      }
    } else {
      creator = await creator.getPlaceUserFromDb(widget.place.creatorId, PlaceUserRoleEnum.creator);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text('Менеджеры ${currentPlace.name} ${currentPlace.admins?.length}', style: Theme.of(context).textTheme.displayMedium, softWrap: true,),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            navigateBackWithResult();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              color: AppColors.brandColor,
              icon: const Icon(FontAwesomeIcons.plus, size: 20, color: AppColors.white),
              // --- Уходим на экран редактирования -----
              onPressed: (){
                navigateToAddManager();
              },
            ),
          ),
        ],
      ),

      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (loading) LoadingScreen(),
          if (!loading) Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (creator.name != '') PlaceManagersElementListItem(
                    user: creator,
                    showButton: false,
                    onTapMethod: () async {
                    },
                  ),
                  if(admins.isNotEmpty) Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: admins.map((user) {
                      return Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: PlaceManagersElementListItem(
                          user: user,
                          showButton: true,
                          onTapMethod: () async {
                            //navigateToEditManager(user);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

        ],
      )

    );

  }

  void navigateBackWithResult() {
    Navigator.of(context).pop(currentPlace);
    //Navigator.pop(context, 'Результат с Second Page');
  }

  void navigateToAddManager() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceManagerAddScreen(place: currentPlace))
    );

    // Проверяем результат и вызываем функцию fetchAndSetData
    if (result != null) {
      setState(() {
        currentPlace.admins = result;

      });
      fetchAndSetData();
    }

  }

}