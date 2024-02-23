import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:dvij_flutter/users/place_user_class.dart';
import 'package:flutter/material.dart';
import '../../widgets_global/images/circle_avatar.dart';

class PlaceManagersElementListItem extends StatelessWidget {
  final PlaceUser user;
  final VoidCallback onTapMethod;
  final bool showButton;

  const PlaceManagersElementListItem({
    Key? key,
    required this.user,
    required this.showButton,
    this.onTapMethod = _defaultOnTap,
  })
      : super(key: key);

  // Метод, который будет использоваться по умолчанию, если не передан onTapMethod
  static void _defaultOnTap() {}

  @override
  Widget build(BuildContext context) {

    return Card(
      color: AppColors.greyOnBackground,
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [

                CircleAvatarWidget(imagePath: user.avatar),

                const SizedBox(width: 15.0),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name} ${user.lastname}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),

                      const SizedBox(height: 5.0),

                      Text(
                        user.placeUserRole.title,
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5.0),

                      Text(
                        user.placeUserRole.desc,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),

                if (showButton) const SizedBox(width: 10.0),

                if (showButton) IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onTapMethod,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}