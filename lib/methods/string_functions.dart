
List<int> SplitDate(String date, String symbol)
{

  List<String> stringElements = date.split(symbol);
  List<int> intElements = stringElements.map((String element) {
    return int.tryParse(element) ?? 0; // Если не удается преобразовать в int, используйте 0 или другое значение по умолчанию
  }).toList();

  return intElements;
}