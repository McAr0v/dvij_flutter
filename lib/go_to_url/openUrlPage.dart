import 'package:url_launcher/url_launcher.dart';

void openSocialProfile(String username, String social) async {
  String path = '';

  switch (social) {
    case 'instagram':
      path = 'https://www.instagram.com/${username.toLowerCase()}/';
      break;
    case 'telegram':
      path = 'https://t.me/${username.toLowerCase()}/';
      break;
    case 'whatsapp':
      path = 'https://wa.me/$username/';
      break;
    default:
      path = 'tel:$username';
      break;
  }

  launchUrl(Uri.parse(path), mode: LaunchMode.externalApplication);

}