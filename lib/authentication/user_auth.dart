import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../events/events_list_class.dart';
import '../events/events_list_manager.dart';
import '../places/place_list_class.dart';
import '../places/place_list_manager.dart';
import '../promos/promos_list_class.dart';
import '../promos/promos_list_manager.dart';

mixin UserAuthMixin{

  // ---- Функция выхода из аккаунта ---
  Future<String> signOutInMixin() async {
    try {
      await FirebaseAuth.instance.signOut();

      UserCustom.currentUser = null; // Обнуляем текущего пользователя при выходе

      PlaceListManager.currentFeedPlacesList = PlaceList();

      EventListsManager.currentFeedEventsList = EventsList();

      PromoListsManager.currentFeedPromosList = PromoList();


      return 'ok';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> createUserWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Пользователь успешно создан
      User? user = credential.user;

      // Отправляем письмо с подтверждением
      await user?.sendEmailVerification();

      // Возвращаем UID
      return user?.uid;

    } on FirebaseAuthException catch (e) {

      return e.code;

    } catch (e) {
      // В случае исключения возвращаем null
      return e.toString();
    }
  }

  Future<String?> signInWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      UserCustom tempUser = UserCustom.empty();

      // Если пользователь успешно вошел, обновляем текущего пользователя
      await tempUser.readUserDataFromDb(uid: credential.user!.uid);

      PlaceListManager.currentFeedPlacesList = PlaceList();

      EventListsManager.currentFeedEventsList = EventsList();

      PromoListsManager.currentFeedPromosList = PromoList();

      // и возвращаем uid
      return credential.user?.uid;

    } on FirebaseAuthException catch (e) {

      return e.code;

    } catch (e) {
      return null;
    }
  }

  Future<String?> resetPasswordInMixin(String emailAddress) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailAddress,
      );

      // Если успешно отправлено письмо, возвращаем success
      return 'ok';

    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return null;
    }
  }

}