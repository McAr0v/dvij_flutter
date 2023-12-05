import 'package:dvij_flutter/screens/cities_screens/cities_list_screen.dart';
import 'package:dvij_flutter/screens/otherPages/privacy_policy_page.dart';
import 'package:dvij_flutter/screens/profile/reset_password_page.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state/appstate.dart';
import 'database_firebase/user_database.dart';
import 'elements/icons_elements/svg_icon.dart';
import 'themes/dark_theme.dart';
import 'navigation/custom_nav_containter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../../classes/user_class.dart' as local_user;
import 'package:firebase_auth/firebase_auth.dart' as firebase_user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

/*class _MyAppState extends State<MyApp> {
  final UserDatabase userDatabase = UserDatabase();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  late firebase_user.User? _user; // Объявление пользователя
  local_user.User userInfo = local_user.User(
      uid: '',
      role: '1113',
      name: '',
      lastname: '',
      phone: '',
      whatsapp: '',
      telegram: '',
      instagram: '',
      city: '',
      birthDate: '',
      sex: '',
      avatar: ''
  );
  // Колбэк, который будет вызываться при редактировании пользователя
  void onUserProfileUpdated() {
    // Обновите информацию пользователя в вашем состоянии
    getUser();
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((firebase_user.User? user) {
      // Этот колбэк вызывается при каждом изменении статуса аутентификации
      setState(() {
        _user = user;
      });

      // Если пользователь вошел в систему, обновите userInfo
      if (user != null) {
        _updateUserInfo(user);
      }
    });
  }

  Future<void> _updateUserInfo(firebase_user.User user) async {
    userInfo = (await userDatabase.readUserData(user.uid))!;
    setState(() {
      userInfo = userInfo;
    });
  }

  Future<void> getUser() async {
    firebase_user.User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userInfo = (await userDatabase.readUserData(user.uid))!;
    }
  }


}*/
