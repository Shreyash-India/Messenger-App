import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEPICKEY";

  //save data
  Future<bool> saveUserName(String? getUserName) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.setString(userNameKey, getUserName!);
  }

  Future<bool> saveUserEmail(String? getUseremail) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.setString(userEmailKey, getUseremail!);
  }

  Future<bool> saveUserId(String? getUserId) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.setString(userIdKey, getUserId!);
  }

  Future<bool> saveDisplayName(String? getDisplayName) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.setString(displayNameKey, getDisplayName!);
  }

  Future<bool> saveUserProfileUrl(String? getUserProfile) async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.setString(userProfilePicKey, getUserProfile!);
  }

  // get data
  Future<String?> getUserName() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.getString(userEmailKey);
  }

  Future<String?> getUserId() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.getString(userIdKey);
  }

  Future<String?> getDisplayName() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.getString(displayNameKey);
  }

  Future<String?> getUserProfileUrl() async {
    SharedPreferences preference = await SharedPreferences.getInstance();
    return preference.getString(userProfilePicKey);
  }
}
