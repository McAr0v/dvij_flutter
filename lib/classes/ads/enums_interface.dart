
abstract class CustomEnums<T> {
  String getNameEnum (T enumItem, {bool translate = false});
  T getEnumFromString (String enumString);
}