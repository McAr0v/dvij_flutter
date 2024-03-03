import 'package:flutter/material.dart';

import '../../classes/priceTypeOptions.dart';
import '../../themes/app_colors.dart';

class PriceWidget extends StatelessWidget {
  final PriceTypeOption type; // Передаваемая переменная
  final Function(PriceTypeOption?) onTap;
  final TextEditingController fixedPriceController;
  final TextEditingController startPriceController;
  final TextEditingController endPriceController;

  const PriceWidget({super.key, required this.type, required this.onTap, required this.fixedPriceController, required this.startPriceController, required this.endPriceController}); // required - значит, что обязательно

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
              'Стоимость билетов',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.1),
            ),

            const SizedBox(height: 5.0),

            Text(
              'Ты можешь выбрать из несольких вариантов - бесплатно, фиксированная цена или цена от и до',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 16.0),

            DropdownButton<PriceTypeOption>(
              style: Theme.of(context).textTheme.bodySmall,
              isExpanded: true,
              value: type,
              onChanged: onTap,
              items: [
                DropdownMenuItem(
                    value: PriceTypeOption.free,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Бесплатно',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          'Свободный вход для всех посетителей',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )
                ),
                DropdownMenuItem(
                    value: PriceTypeOption.fixed,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Фиксированная стоимость',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          'Одна стоимость билетов для всех посетителей',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )
                ),
                DropdownMenuItem(
                    value: PriceTypeOption.range,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Цена "От - До"',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          'Крайние стоимости билетов',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )
                ),
              ],
            ),
            if (type != PriceTypeOption.free) const SizedBox(height: 20.0),

            if (type == PriceTypeOption.fixed) TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              keyboardType: TextInputType.number,
              controller: fixedPriceController,
              decoration: const InputDecoration(
                labelText: 'Введи стоимость билетов',
              ),
            ),

            if (type == PriceTypeOption.range) TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              keyboardType: TextInputType.number,
              controller: startPriceController,
              decoration: const InputDecoration(
                labelText: 'Введи стоимость самого дешевого билета',
              ),
            ),

            if (type == PriceTypeOption.range) const SizedBox(height: 15.0),

            if (type == PriceTypeOption.range) TextField(
              style: Theme.of(context).textTheme.bodyMedium,
              keyboardType: TextInputType.number,
              controller: endPriceController,
              decoration: const InputDecoration(
                labelText: 'Введи стоимость самого дорогого билета',
              ),
            ),
          ],
        ),
      ),
    );
  }
}