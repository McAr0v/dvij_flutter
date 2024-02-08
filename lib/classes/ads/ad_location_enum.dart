import 'enums_interface.dart';

enum AdLocationEnum {
  places,
  events,
  promos
}

class AdLocationEnumClass implements CustomEnums<AdLocationEnum>{

  @override
  AdLocationEnum getEnumFromString(String enumString) {

    switch (enumString){
      case 'places': return AdLocationEnum.places;
      case 'promos': return AdLocationEnum.promos;
      case 'events': return AdLocationEnum.events;
      default: return AdLocationEnum.events;
    }

  }

  @override
  String getNameEnum(AdLocationEnum enumItem, {bool translate = false}) {
    switch (enumItem) {
      case AdLocationEnum.places:
        return !translate ? 'places' : 'В заведениях';
      case AdLocationEnum.promos:
        return !translate ? 'promos' : 'В акциях';
      case AdLocationEnum.events:
        return !translate ? 'events' : 'В мероприятиях';
    }
  }

}