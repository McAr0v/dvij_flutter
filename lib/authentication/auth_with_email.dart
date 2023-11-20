import 'package:firebase_auth/firebase_auth.dart';

class AuthWithEmail {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> createUserWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Если пользователь успешно создан, возвращаем UID
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Предоставленный пароль слишком слаб.');
      } else if (e.code == 'email-already-in-use') {
        print('Учетная запись уже существует для этого адреса электронной почты.');
      }
      // В случае исключения возвращаем null
      return null;
    } catch (e) {
      print(e);
      // В случае исключения возвращаем null
      return null;
    }
  }

  Future<String?> signInWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}