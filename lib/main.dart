import 'package:dvij_flutter/events/event_category_class.dart';
import 'package:dvij_flutter/places/place_category_class.dart';
import 'package:dvij_flutter/promos/promo_category_class.dart';
import 'package:dvij_flutter/classes/role_in_app.dart';
import 'package:dvij_flutter/screens/otherPages/privacy_policy_page.dart';
import 'package:dvij_flutter/screens/profile/reset_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'ads/ad_user_class.dart';
import 'app_state/appstate.dart';
import 'cities/cities_screens/cities_list_screen.dart';
import 'cities/city_class.dart';
import 'classes/gender_class.dart';
import 'themes/dark_theme.dart';
import 'navigation/custom_nav_containter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../../classes/user_class.dart' as local_user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeDateFormatting("ru_RU", '');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await City.getCitiesAndSave();
  await Gender.getGenderAndSave();
  await RoleInApp.getRolesInAppAndSave();
  await PlaceCategory.getPlaceCategoryAndSave();
  await EventCategory.getEventCategoryAndSave();
  await PromoCategory.getPromoCategoryAndSave();
  await AdUser.getAllAdsAndSave();

  final FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser != null)
  {
    await local_user.UserCustom.readUserDataAndWriteCurrentUser(uid: auth.currentUser!.uid);
  }


  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
        //CupertinoLocalizations.delegate
      ],
        supportedLocales: const [
          Locale('ru', 'RU'), // русская локаль
          Locale('en', 'US'), // английская локаль (если нужно)
        ],
      home: CustomNavContainer(),
      theme: CustomTheme.darkTheme,
      routes: {
        '/Profile': (context) => CustomNavContainer(initialTabIndex: 0,),
        '/Events': (context) => CustomNavContainer(initialTabIndex: 1),
        '/Places': (context) => CustomNavContainer(initialTabIndex: 2),
        '/Promotions': (context) => CustomNavContainer(initialTabIndex: 3),
        '/privacy_policy': (context) => const PrivacyPolicyPage(),
        '/reset_password_page': (context) => const ResetPasswordPage(),
        '/cities': (context) => const CitiesListScreen(),

        // Другие маршруты вашего приложения
      },
    );
  }

}