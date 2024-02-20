
import 'package:flutter/material.dart';
import '../../dates/date_type_enum.dart';

class TypeOfDateWidget extends StatelessWidget {
  final DateTypeEnum type; // Передаваемая переменная
  final Function(DateTypeEnum?) onChooseType;

  const TypeOfDateWidget({super.key,
    required this.type,
    required this.onChooseType,
  }); // required - значит, что обязательно

  @override
  Widget build(BuildContext context) {
    return Column (
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          'Дата проведения мероприятия',
          style: Theme.of(context).textTheme.titleMedium,
        ),

        const SizedBox(height: 5.0),

        Text(
          'От типа мероприятия будет зависить выбор даты проведения',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        const SizedBox(height: 16.0),

        DropdownButton<DateTypeEnum>(
          style: Theme.of(context).textTheme.bodySmall,
          isExpanded: true,
          value: type,
          onChanged: onChooseType,
          items: [
            DropdownMenuItem(
                value: DateTypeEnum.once,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Разовое',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Состоится 1 раз в одну определенную дату',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )
            ),
            DropdownMenuItem(
                value: DateTypeEnum.long,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Длительное',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Проходит несколько дней подряд',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )
            ),
            DropdownMenuItem(
                value: DateTypeEnum.regular,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Регулярное',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Проходит каждую неделю в определенные дни',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )
            ),
            DropdownMenuItem(
                value: DateTypeEnum.irregular,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'В разные даты',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      'Проходит в разные даты - 1, 5, 13 и тд',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.start,
                    ),
                  ],
                )
            ),
          ],
        ),
      ],
    );
  }
}