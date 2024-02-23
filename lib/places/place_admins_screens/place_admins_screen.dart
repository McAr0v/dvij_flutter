import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/places/place_admins_screens/place_manager_add_screen.dart';
import 'package:dvij_flutter/places/place_class.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../classes/user_class.dart';
import '../../users/place_user_class.dart';
import '../../users/place_users_roles.dart';
import '../places_widgets/place_managers_element_list_item.dart';

class PlaceAdminsScreen extends StatefulWidget {
  final Place place;

  const PlaceAdminsScreen({Key? key, required this.place}) : super(key: key);

  @override
  PlaceAdminsScreenState createState() => PlaceAdminsScreenState();
}

class PlaceAdminsScreenState extends State<PlaceAdminsScreen> {

  // Список админов
  List<PlaceUser> admins = [];
  // Данные создателя
  PlaceUser creator = PlaceUser();

  // Переменная для внесений изменений
  Place currentPlace = Place.emptyPlace;

  bool loading = true;

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
    // Получаем информацию об админах из списка ролей и UID админов в заведении
    admins = await creator.getAdminsInfoFromDb(widget.place.admins!);

    if (UserCustom.currentUser != null){
      // Если пользователь - создатель
      if (widget.place.creatorId == UserCustom.currentUser!.uid){
        PlaceUserRole role = PlaceUserRole();
        // Записываем данные пользователя в формат placeUser из данных обычного пользователя
        // Чтобы не грузить данные из БД
        creator = creator.generatePlaceUserFromUserCustom(UserCustom.currentUser!);
        // Устанавливаем роль создателя, так как функция автоматического заполнения
        // пользователя не заполняет роль
        creator.placeUserRole = role.getPlaceUserRole(PlaceUserRoleEnum.creator);
      }
    } else {
      // Если текущий пользователь не создатель
      // Грузим создателя из БД
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

        title: Text('Менеджеры в ${currentPlace.name}', style: Theme.of(context).textTheme.displayMedium, softWrap: true,),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад

        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            // Возвращаемся на экран заведения с результатом
            // Результат - измененное место
            navigateBackWithResult();
          },
        ),
        actions: [
          // Кнопка добавления нового менеджера
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: IconButton(
              color: AppColors.brandColor,
              icon: const Icon(FontAwesomeIcons.plus, size: 20, color: AppColors.white),
              onPressed: (){
                // --- Уходим на экран редактирования -----
                navigateToAddManager();
              },
            ),
          ),
        ],
      ),

      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (loading) const LoadingScreen(),
          if (!loading) Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (creator.name != '') PlaceManagersElementListItem(
                    user: creator,
                    showButton: false
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
                            // Переходим на экран редактирования
                            navigateToAddManager(user: user);
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
  }

  void navigateToAddManager({PlaceUser? user}) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceManagerAddScreen(place: currentPlace, placeUser: user,))
    );

    if (result != null) {
      setState(() {
        currentPlace.admins = result;

      });
      fetchAndSetData();
    }
  }

}