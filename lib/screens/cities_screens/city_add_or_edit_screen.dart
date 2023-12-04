import 'package:dvij_flutter/elements/custom_button.dart';
import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import 'cities_list_screen.dart'; // Импортируем экран списка городов

class CityEditScreen extends StatefulWidget {
  final City? city;

  const CityEditScreen({Key? key, this.city}) : super(key: key);

  @override
  _CityEditScreenState createState() => _CityEditScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class _CityEditScreenState extends State<CityEditScreen> {
  final TextEditingController _cityNameController = TextEditingController();

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.city != null) {
      _cityNameController.text = widget.city!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city != null ? 'Редактирование города' : 'Создание города'),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком городов

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
                MaterialPageRoute(
                  builder: (context) => CitiesListScreen(),
                ),
            );
          },
        ),
      ),

      // --- Само тело страницы ----

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 40.0),

            // ---- Поле ввода города ---

            TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              keyboardType: TextInputType.text,
              controller: _cityNameController,
              decoration: const InputDecoration(
                  labelText: 'Название города',
                  prefixIcon: Icon(Icons.place),
              ),
            ),

            SizedBox(height: 40.0),

            // ---- Кнопка опубликовать -----

            // TODO Пока публикуется сделать экран загрузки
            CustomButton(
                buttonText: 'Опубликовать',
                onTapMethod: (){
                  _publishCity();
                }
            ),

            SizedBox(height: 20.0),

            // -- Кнопка отменить ----

            CustomButton(
                state: 'secondary',
                buttonText: "Отменить",
                onTapMethod: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CitiesListScreen(),
                    ),
                  );
                }
            )
          ],
        ),
      ),
    );
  }

  void _publishCity() async {
    String cityName = _cityNameController.text;

    String result;

    if (widget.city != null) {
      // Редактирование города
      result = await City.addAndEditCity(cityName, id: widget.city?.id ?? '');
    } else {
      // Создание нового города
      result = await City.addAndEditCity(cityName);
    }

    if (result == 'success'){
      // TODO - Сделать всплывающее оповещение
      // Возвращаемся на экран списка городов
      // TODO - Вывести переход на страницу выше, за пределы виджета
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CitiesListScreen()),
      );
    }


  }
}