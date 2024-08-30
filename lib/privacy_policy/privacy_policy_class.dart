import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:firebase_database/firebase_database.dart';

import '../database/database_mixin.dart';

class PrivacyPolicyClass {

  DateTime date;
  String startText;
  String dataCollection;
  String dataUsage;
  String transferData;
  String dataSecurity;
  String yourRights;
  String changes;
  String contacts;

  PrivacyPolicyClass({
    required this.date,
    required this.startText,
    required this.dataCollection,
    required this.dataUsage,
    required this.transferData,
    required this.dataSecurity,
    required this.yourRights,
    required this.changes,
    required this.contacts
  });

  factory PrivacyPolicyClass.fromSnapshot(DataSnapshot snapshot){
    return PrivacyPolicyClass(
        date: DateMixin.getDateFromString(snapshot.child('publishDate').value.toString()),
        startText: snapshot.child('startText').value.toString(),
        dataCollection: snapshot.child('dataCollection').value.toString(),
        dataUsage: snapshot.child('dataUsage').value.toString(),
        transferData: snapshot.child('transferData').value.toString(),
        dataSecurity: snapshot.child('dataSecurity').value.toString(),
        yourRights: snapshot.child('yourRights').value.toString(),
        changes: snapshot.child('changes').value.toString(),
        contacts: snapshot.child('contacts').value.toString(),
    );
  }

  factory PrivacyPolicyClass.empty(){
    return PrivacyPolicyClass(
        date: DateTime.now(),
        startText: '',
        dataCollection: '',
        dataUsage: '',
        transferData: '',
        dataSecurity: '',
        yourRights: '',
        changes: '',
        contacts: ''
    );
  }

  Future<List<PrivacyPolicyClass>> getPoliciesFromDb() async {
    String policyPath = 'privacy_policy';
    DataSnapshot? snapshot = await MixinDatabase.getInfoFromDB(policyPath);

    List<PrivacyPolicyClass> tempList = [];

    if (snapshot != null){
      for (var childSnapshot in snapshot.children){
        PrivacyPolicyClass tempPrivacy = PrivacyPolicyClass.fromSnapshot(childSnapshot);
        tempList.add(tempPrivacy);
      }
    }

    return tempList;

  }

  PrivacyPolicyClass? getLatestPrivacyPolicy(List<PrivacyPolicyClass> policies) {
    if (policies.isEmpty) {
      return null;
    }

    // Начнем с первого элемента как самого позднего
    PrivacyPolicyClass latestPolicy = policies[0];

    for (var policy in policies) {
      if (policy.date.isAfter(latestPolicy.date)) {
        latestPolicy = policy;
      }
    }

    return latestPolicy;
  }

}