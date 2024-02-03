import 'package:dvij_flutter/classes/pair.dart';

class AdCustom {

  static List<Pair> generateIndexedList(List<int> adIndexes, int feedElementsListCount)
  {
    int sumOfIndexes = adIndexes.length + feedElementsListCount;
    List<Pair> tempList = [];
    int feedElementIndex = 0;
    int adListIndex = 0;

    for (int i = 0; i < sumOfIndexes; i++){
      // -- Если рекламный список содержит очередной индекс

      if (adIndexes.contains(i)){
        // --- Это реклама ---
        tempList.add(Pair('ad', adListIndex));
        adListIndex++;
      } else {
        if (feedElementIndex < feedElementsListCount){
          tempList.add(Pair('feedElement', feedElementIndex));
          feedElementIndex++;
        }
      }
    }

    if (adIndexes.contains(sumOfIndexes)){
      tempList.add(Pair('ad', adListIndex));
      adListIndex++;
    }

    if (adIndexes.length - adListIndex != 0){
      for (int i = adListIndex; i<adIndexes.length; i++){
        tempList.add(Pair('ad', i));
      }
    }

    return tempList;

  }

  static List<int> getAdIndexesList (List<String> adList, int step, int firstAdIndex){

    List<int> indexesList = [];

    if (adList.isNotEmpty) {
      for (int i = 0; i < adList.length; i++){
        indexesList.add( firstAdIndex + ((step+1) * i) );
      }
    }

    return indexesList;

  }

}