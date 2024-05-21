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

}