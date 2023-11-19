import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'custom_bottom_navigation_bar.dart';
import 'package:dvij_flutter/screens/profile/profile_page.dart';
import 'package:dvij_flutter/screens/events/events_page.dart';
import 'package:dvij_flutter/screens/places/places_page.dart';
import 'package:dvij_flutter/screens/promotions/promotions_page.dart';

// ---- ВСЯ НАВИГАЦИЯ ЗДЕСЬ! ----

class CustomNavContainer extends StatefulWidget {
  const CustomNavContainer({super.key});

  @override
  _CustomNavContainerState createState() => _CustomNavContainerState();
}

class _CustomNavContainerState extends State<CustomNavContainer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['Профиль', 'Мероприятия', 'Места', 'Акции'];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _tabTitles.length, vsync: this, initialIndex: 1);
  }


  // --- Все панели - шторка, верхняя панель , нижняя панель ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_tabController.index], style: Theme.of(context).textTheme.displayMedium,),
      ),
      drawer: CustomDrawer(), // Кастомная шторка custom_drawer.dart
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProfilePage(),
          EventsPage(),
          PlacesPage(),
          PromotionsPage(),
        ],
      ),
      // Кастомная нижняя панель custom_bottom_navigation_bar.dart
      bottomNavigationBar: CustomBottomNavigationBar(
        onTabTapped: (index){
            setState(() {
              _tabController.index = index;
            });
        },
        tabController: _tabController,
      ),
    );
  }
}