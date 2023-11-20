class AppState {
  String? uid;

  static final AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }

  AppState._internal();

  void setUid(String newUid) {
    uid = newUid;
  }

  String? getUid() {
    return uid;
  }
}