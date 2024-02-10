import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/events/event_extensions.dart';
import 'package:dvij_flutter/interfaces/app_services_interface.dart';
import 'package:firebase_database/firebase_database.dart';

class EventCategory with MixinDatabase implements IAppServices<EventCategory>{
  late String id;
  late String name;

  EventCategory({required this.name, required this.id});

  factory EventCategory.fromSnapshot(DataSnapshot snapshot) {

    return EventCategory(
      id: snapshot.child('id').value.toString(),
      name: snapshot.child('name').value.toString(),
    );
    
  }
  
  static EventCategory emptyEventCategory = EventCategory(name: '', id: '');
  
  static List<EventCategory> currentEventCategoryList = [];

  static Future<void> getEventCategoryAndSave({bool order = true}) async {

    EventCategory tempEventCategory = emptyEventCategory;
    currentEventCategoryList = await tempEventCategory.getEntitiesListFromDb();

  }

  Map<String, dynamic> generateInfoForDb() {
    return <String, dynamic> {
      'id': id,
      'name': name
    };
  }

  @override
  Future<String> addOrEditEntityInDb() async {
    String? key;

    EventCategory eventCategory = EventCategory(name: name, id: id);

    if (id == ''){
      key = generateKey();
      eventCategory.id = key ?? '';
    }

    String path = 'event_categories/${eventCategory.id}';

    Map<String, dynamic> info = eventCategory.generateInfoForDb();

    String result = await eventCategory.publishToDB(path, info);

    await getEventCategoryAndSave();

    return result;

  }

  @override
  Future<String> deleteEntityFromDb() async {
    
    String path = 'event_categories/$id';

    String result = await deleteFromDb(path);

    await getEventCategoryAndSave();

    return result;
  }

  @override
  Future<List<EventCategory>> getEntitiesListFromDb({bool order = true}) async {
    
    List<EventCategory> eventCategories = [];

    DataSnapshot? snapshot = await getInfoFromDB('event_categories');

    if (snapshot != null){
      for (var childSnapshot in snapshot.children) {
        eventCategories.add(EventCategory.fromSnapshot(childSnapshot));
      }
    }

    eventCategories.sortEventCategories(order);

    return eventCategories;
  }

  static EventCategory getEventCategoryFromCategoriesList (String id) {
    EventCategory tempEventCategory = emptyEventCategory;
    return tempEventCategory.getEntityByIdFromList(id);
    
  }

  @override
  EventCategory getEntityByIdFromList(String id) {
    EventCategory result = EventCategory(name: '', id: '');

    for (int i = 0; i<currentEventCategoryList.length; i++){
      if (currentEventCategoryList[i].id == id) {
        return currentEventCategoryList[i];
      }
    }

    return result;

  }
}