import 'package:dvij_flutter/classes/city_class.dart';
import 'package:dvij_flutter/elements/places_elements/place_widget_in_create_event_screen.dart';
import 'package:flutter/material.dart';

import '../../classes/priceTypeOptions.dart';
import '../../themes/app_colors.dart';
import '../classes/place_class.dart';
import 'buttons/custom_button.dart';
import 'cities_elements/city_element_in_edit_screen.dart';

class ChoosePlaceInEventAndPromoWidget extends StatelessWidget {
  final bool inPlace; // Передаваемая переменная
  final VoidCallback onTapChoosePlace;
  final VoidCallback onDeletePlace;
  final VoidCallback onShowPickerPlace;
  final VoidCallback onTapInputAddress;
  final Place chosenPlace;
  final City chosenCity;
  final VoidCallback onShowChosenCityPicker;
  final TextEditingController streetController;
  final TextEditingController houseController;

  const ChoosePlaceInEventAndPromoWidget({super.key,
    required this.chosenPlace,
    required this.onDeletePlace,
    required this.onShowPickerPlace,
    required this.inPlace,
    required this.chosenCity,
    required this.onShowChosenCityPicker,
    required this.onTapChoosePlace,
    required this.onTapInputAddress,
    required this.streetController,
    required this.houseController,
  }); // required - значит, что обязательно

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      color: AppColors.greyOnBackground,
      child: Padding (
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выбери место проведения мероприятия',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
            ),

            const SizedBox(height: 5.0),

            Text(
              'Ты можешь указать заведение или просто написать адрес',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            SizedBox(height: 10,),

            Row (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onTapChoosePlace,
                  child: Card (
                    color: inPlace? AppColors.brandColor : AppColors.greyForCards,
                    //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Padding (
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Text (
                        'Выбрать место',
                        style: inPlace? Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyOnBackground) : Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onTapInputAddress,
                  child: Card (
                    color: !inPlace? AppColors.brandColor : AppColors.greyForCards,
                    //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Padding (
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Text ('Написать адрес', style: !inPlace? Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.greyOnBackground) : Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20.0),

            if (inPlace) Column(
              children: [
                if (chosenPlace.id == '') CustomButton(
                    buttonText: 'Выбрать заведение',
                    onTapMethod: onShowPickerPlace
                ),
                if (chosenPlace.id != '') PlaceWidgetInCreateEventScreen(
                  place: chosenPlace,
                  onTapMethod: onShowPickerPlace,
                  onDeleteMethod: onDeletePlace,
                )
              ],
            ),

            if (!inPlace) Column(
              children: [
                if (chosenCity.id == '') CityElementInEditScreen(
                  cityName: 'Город не выбран',
                  onActionPressed: onShowChosenCityPicker
                ),

                if (chosenCity.id != "") CityElementInEditScreen(
                  cityName: chosenCity.name,
                  onActionPressed: onShowChosenCityPicker,
                ),

                const SizedBox(height: 16.0),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.text,
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: 'Улица',
                  ),
                ),

                const SizedBox(height: 16.0),
                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.text,
                  controller: houseController,
                  decoration: const InputDecoration(
                    labelText: 'Номер дома',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}