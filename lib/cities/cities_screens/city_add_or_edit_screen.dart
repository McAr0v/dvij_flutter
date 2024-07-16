import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../cities/city_class.dart';
import '../../elements/custom_snack_bar.dart';
import 'cities_list_screen.dart'; // Импортируем экран списка городов

class CityEditScreen extends StatefulWidget {
  final City? city;

  const CityEditScreen({Key? key, this.city}) : super(key: key);

  @override
  State<CityEditScreen> createState() => _CityEditScreenState();
}

// ---- Экран редактирования или создания города ----

// Принцип простой, если на экран не передается город, то это создание города
// Если передается, то название города уже вбито, его можно редактировать

// TODO При создании города Сделать проверку, существует ли уже город с таким названием?. Если да выводить всплывающее меню

class _CityEditScreenState extends State<CityEditScreen> {
  final TextEditingController _cityNameController = TextEditingController();

  // Переменная, включающая экран загрузки
  bool loading = false;

  // --- Инициализируем состояние ----

  @override
  void initState() {
    super.initState();
    // Влючаем экран загрузки
    loading = false;
    // Если передан город для редактирования, устанавливаем его название в поле ввода
    if (widget.city != null) {
      _cityNameController.text = widget.city!.name;
    }
  }

  // ---- Функция отображения всплывающего окна

  void showSnackBar(String message, Color color, int showTime) {
    final snackBar = customSnackBar(message: message, backgroundColor: color, showTime: showTime);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToCitiesListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CitiesListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city != null ? 'Редактирование города' : 'Создание города'),

        // Задаем особый выход на кнопку назад
        // Чтобы не плодились экраны назад с разным списком городов

        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.pushReplacement(
              context,
                MaterialPageRoute(
                  builder: (context) => const CitiesListScreen(),
                ),
            );
          },
        ),
      ),

      // --- Само тело страницы ----

      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: "Идет публикация города",)
          else Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40.0),

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

                const SizedBox(height: 40.0),

                // ---- Кнопка опубликовать -----

                CustomButton(
                    buttonText: 'Опубликовать',
                    onTapMethod: (){
                      if (_cityNameController.text == ''){
                        showSnackBar(
                            'Название города должно быть обязательно заполнено!',
                            AppColors.attentionRed,
                            2
                        );
                      } else {
                        _publishCity();
                      }

                    }
                ),

                const SizedBox(height: 20.0),

                // -- Кнопка отменить ----

                CustomButton(
                    state: CustomButtonState.secondary,
                    buttonText: "Отменить",
                    onTapMethod: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CitiesListScreen(),
                        ),
                      );
                    }
                )
              ],
            ),
          ),
        ],
      )
    );
  }

  bool _checkCityNameInList(City publishedCity){
    List<City> cities = City.currentCityList;

    if (cities.any((element) => element.name.toLowerCase() == publishedCity.name.toLowerCase())) {
      return false;
    } else {
      return true;
    }
  }

  void _publishCity() async {

    setState(() {
      loading = true;
    });

    String cityName = _cityNameController.text;

    String result;

    City publishedCity = City(name: cityName, id: '');

    if (widget.city != null) {
      publishedCity.id = widget.city?.id ?? '';

    }

    // Если города с таким названием еще нет в списке

    if (_checkCityNameInList(publishedCity)){

      // Публикуем город
      result = await publishedCity.addOrEditEntityInDb();

      if (result == 'success'){

        setState(() {
          loading = false;
        });

        showSnackBar('Город успешно опубликован', Colors.green, 3);
        // Возвращаемся на экран списка городов
        navigateToCitiesListScreen();
      } else {
        // TODO Сделать обработчик ошибок, если публикация города не удалась
      }
    } else {

      // Если город существует с введенным именем
      // Выводим оповещение

      setState(() {
        loading = false;
      });
      showSnackBar('Город с таким именем уже существует', AppColors.attentionRed, 1);
    }
  }
}