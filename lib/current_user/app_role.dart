enum AppRoleEnum {
  god,
  admin,
  adManager,
  contentManager,
  simpleUser
}

class AppRole{
  AppRoleEnum role;

  AppRole({this.role = AppRoleEnum.simpleUser});

  void setRoleFromDb(String roleEnum){
    switch (roleEnum){
      case 'god': role = AppRoleEnum.god;
      case 'admin': role = AppRoleEnum.admin;
      case 'adManager': role = AppRoleEnum.adManager;
      case 'contentManager': role = AppRoleEnum.contentManager;
      default : role = AppRoleEnum.simpleUser;
    }
  }

  String getRoleNameInString({ required AppRoleEnum roleEnum, bool needTranslate = false}){
    switch (roleEnum){
      case AppRoleEnum.god: return needTranslate ? 'Создатель' : 'god';
      case AppRoleEnum.admin: return needTranslate ? 'Администратор' : 'admin';
      case AppRoleEnum.adManager: return needTranslate ? 'Менеджер рекламы' : 'adManager';
      case AppRoleEnum.contentManager: return needTranslate ? 'Менеджер контента' : 'contentManager';
      case AppRoleEnum.simpleUser: return needTranslate ? 'Обычный пользователь' : 'simpleUser';
    }
  }

  int getAccessNumber(){
    switch (role){
      case AppRoleEnum.god: return 100;
      case AppRoleEnum.admin: return 90;
      case AppRoleEnum.adManager: return 50;
      case AppRoleEnum.contentManager: return 70;
      case AppRoleEnum.simpleUser: return 0;
    }
  }

}