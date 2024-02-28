import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/app_colors.dart';

class FilterWidget<T> extends StatelessWidget {
  final Function() onFilterTap;
  final int filterCount;
  final List<DropdownMenuItem<T>> sortingItems;
  final T? sortingValue;
  final ValueChanged<T?>? onSortingValueChanged;

  const FilterWidget({
    required this.onFilterTap,
    required this.filterCount,
    required this.sortingItems,
    required this.sortingValue,
    required this.onSortingValueChanged,

    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        color: AppColors.greyOnBackground,
        child: Row (
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ---- Фильтр -----

            GestureDetector(
              onTap: onFilterTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Фильтр ${filterCount > 0 ? '($filterCount)' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: filterCount > 0 ? AppColors.brandColor : AppColors.white),
                  ),

                  const SizedBox(width: 20,),

                  Icon(
                    FontAwesomeIcons.filter,
                    size: 20,
                    color: filterCount > 0 ? AppColors.brandColor : AppColors.white ,
                  )
                ],
              ),
            ),

            // ------ Сортировка ------

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: DropdownButton<T>(
                style: Theme.of(context).textTheme.bodySmall,
                isExpanded: true,
                value: sortingValue,
                onChanged: onSortingValueChanged,
                items: sortingItems,
              ),
            )
          ],
        )
    );
  }

}