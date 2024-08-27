import 'package:dvij_flutter/url_methods/url_path_enum.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenUrlClass {
  static void openUrl(String insertString, UrlPathEnum pathEnum) async {
    String path = '';

    switch (pathEnum) {
      case UrlPathEnum.instagram:
        path = 'https://www.instagram.com/${insertString.toLowerCase()}/';
        break;
      case UrlPathEnum.telegram:
        path = 'https://t.me/${insertString.toLowerCase()}/';
        break;
      case UrlPathEnum.whatsapp:
        path = 'https://wa.me/$insertString/';
        break;
      case UrlPathEnum.phone:
        path = 'tel:$insertString';
        break;
      case UrlPathEnum.web:
        path = insertString;
    }

    launchUrl(Uri.parse(path), mode: LaunchMode.externalApplication);

  }
}