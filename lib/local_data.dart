import 'package:shared_preferences/shared_preferences.dart';

class LocalData {
  static String? uid;
  static String? type;
  Future<SharedPreferences> _sharedPreferences =
      SharedPreferences.getInstance();

  Future storeUser(String uid) async {
    SharedPreferences pref = await _sharedPreferences;
    pref.setString("uid", uid);
  }

  Future<String?> getType() async {
    SharedPreferences pref = await _sharedPreferences;
    return pref.getString("type");
  }

  Future setType(String type) async {
    SharedPreferences pref = await _sharedPreferences;
    pref.setString("type", type);
  }

  Future<String?> getUser() async {
    SharedPreferences pref = await _sharedPreferences;
    return pref.getString("uid");
  }

  Future<void> logout() async {
    SharedPreferences pref = await _sharedPreferences;
    await pref.clear();
    LocalData.uid = null;
    LocalData.type = null;
  }
}
