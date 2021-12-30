import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/helper/helper.dart';

class DatabaseMethods {
  Future addUserInfoToDB(String userId, Map<String, dynamic> userInfo) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfo);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userName", isEqualTo: username)
        .snapshots();
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInformation) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInformation);
  }

  Future updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInformation) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInformation);
  }

  Future createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInformation) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      return;
    } else {
      return await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInformation);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = await SharedPreferencesHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .where("users", arrayContains: myUsername)
        .orderBy("lastMessageSendTs", descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("users", isEqualTo: username)
        .get();
  }
}
