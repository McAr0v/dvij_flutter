
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'themes/dark_theme.dart';  // Импортируйте вашу темную тему
import 'screens/events/events_page.dart';
import 'screens/places/places_page.dart';
import 'screens/promotions/promotions_page.dart';
import 'screens/profile/profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(
    MaterialApp(
      home: const BottomNavBarDemo(),
      theme: CustomTheme.darkTheme,
    ),
  );
}

class BottomNavBarDemo extends StatefulWidget {
  const BottomNavBarDemo({super.key});

  @override
  _BottomNavBarDemoState createState() => _BottomNavBarDemoState();
}

class _BottomNavBarDemoState extends State<BottomNavBarDemo> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['Профиль', 'Мероприятия', 'Места', 'Акции'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

// остальной код остается без изменений


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_tabController.index]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProfilePage(),
          EventsPage(),
          PlacesPage(),
          PromotionsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
        items: [

          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
            backgroundColor: AppColors.greyOnBackground
          ),
          BottomNavigationBarItem(
              icon: SvgIcon(
                assetPath: 'assets/icon_celebration.svg',
                width: 24.0,
                height: 24.0,
                color: _tabController.index == 1
                    ? AppColors.brandColor // Цвет для выбранного элемента
                    : AppColors.greyText, // Цвет для не выбранного элемента,
              ),
            label: 'Мероприятия',
            backgroundColor: AppColors.greyOnBackground
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Места',
            backgroundColor: AppColors.greyOnBackground
          ),
          BottomNavigationBarItem(
              icon: SvgIcon(
                assetPath: 'assets/fire_solid.svg',
                width: 24.0,
                height: 24.0,
                color: _tabController.index == 3
                    ? AppColors.brandColor // Цвет для выбранного элемента
                    : AppColors.greyText, // Цвет для не выбранного элемента,
              ),
            label: 'Акции',
            backgroundColor: AppColors.greyOnBackground
          ),
        ],
      ),
    );
  }
}

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color color;

  const SvgIcon({super.key,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      color: color,
    );
  }
}

/* void main() {
  runApp(const MyApp());
} */

/* class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "123",
      theme: CustomTheme.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('123'),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Привет Dvij',
                style: Theme.of(context).textTheme.displayLarge

              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Действие при нажатии кнопки
                },
                child: const Text('Нажми меня'),
              ),
            ],
          ),
        ),
      )
    );
  }
}*/