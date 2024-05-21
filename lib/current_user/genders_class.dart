
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum GenderEnum {
  male,
  female,
  notChosen

}

class Genders {
  GenderEnum genderEnum;

  Genders({this.genderEnum = GenderEnum.notChosen});

  void switchEnumFromString(String gender){
    switch (gender) {
      case "male": genderEnum = GenderEnum.male;
      case "female": genderEnum = GenderEnum.female;
      default: genderEnum = GenderEnum.notChosen;
    }
  }

  String getGenderString({bool needTranslate = false}){
    switch (genderEnum) {
      case GenderEnum.male: return needTranslate == false ? "male": "Мужчина";
      case GenderEnum.female: return needTranslate == false ? "female": "Женщина";
      case GenderEnum.notChosen: return needTranslate == false ? "notChosen": "Не выбрано";
    }
  }

  IconData getGenderIcon(){
    switch (genderEnum) {
      case GenderEnum.male: return FontAwesomeIcons.person;
      case GenderEnum.female: return FontAwesomeIcons.personDress;
      case GenderEnum.notChosen: return FontAwesomeIcons.genderless;
    }
  }
}