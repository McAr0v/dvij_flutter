import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dvij_flutter/classes/place_class.dart'; // Убедитесь, что вы импортируете ваш класс Place

class PlaceCardWidget extends StatelessWidget {
  final Place place;
  final bool canEdit; // Флаг для определения доступа к редактированию

  PlaceCardWidget({required this.place, required this.canEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Изображение
          Container(
            height: MediaQuery.of(context).size.width*0.7, // Ширина экрана
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(place.imageUrl), // Используйте ссылку на изображение из вашего Place
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
          ),
          // Фон с информацией
          Container(
            color: AppColors.greyOnBackground, // Полупрозрачный черный цвет
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.0),
                Text(
                  place.desc,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 8.0),
                Text(
                  'Адрес: ${place.city}, ${place.street}, ${place.house}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),

                Text(
                    'В изрбанном: ${place.addedToFavouritesCount}, Мероприятий ${place.eventsCount}, добавил ли в избранное ${place.inFav}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                ),

                // Дополнительные поля, например, мероприятия, избранное и т.д.
                // Их можно заполнить данными из вашей базы данных
                // ...

                // Кнопки редактирования и удаления, если есть доступ к редактированию
                if (canEdit)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Ваш код для редактирования
                        },
                        child: Text('Редактировать'),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          // Ваш код для удаления
                        },
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        child: Text('Удалить'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}