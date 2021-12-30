// ignore_for_file: use_key_in_widget_constructors, avoid_unnecessary_containers, unnecessary_string_escapes, curly_braces_in_flow_control_structures, non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/helper.dart';
import 'package:random_string/random_string.dart';
import 'package:messenger/services/database.dart';

class Chat extends StatefulWidget {
  final String chatWithUsername, name;
  const Chat(this.chatWithUsername, this.name);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late String chatRoomId, messageId = "";
  late String myName, myProfilePic, myUserName, myEmail;
  late Stream messageStream = "" as Stream;
  TextEditingController message = TextEditingController();

  getMyInfoFromSharedPreferences() async {
    myName = (await SharedPreferencesHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferencesHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferencesHelper().getUserName())!;
    myEmail = (await SharedPreferencesHelper().getUserEmail())!;

    // Generate ChatRoom Id..
    chatRoomId = generateChatRoomId(widget.chatWithUsername, myUserName);
  }

  String generateChatRoomId(String user1, String user2) {
    if (user1.length > user2.length)
      return "$user2\_$user1";
    else if (user1.length < user2.length)
      return "$user1\_$user2";
    else {
      int i = 0;
      int j = 0;
      int k = -1;
      while (i < user1.length && j < user2.length) {
        if (user1.substring(i, i + 1) == user2.substring(j, j + 1)) {
          i++;
          j++;
        } else {
          k = i;
          break;
        }
      }
      if (k != -1) {
        if (user1.codeUnitAt(k) > user2.codeUnitAt(k))
          return "$user2\_$user1";
        else
          return "$user1\_$user2";
      } else
        return "DEFAULT_KEY";
    }
  }

  void addMessage(bool sendClicked) {
    if (message.text != "") {
      String Message = message.text;
      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInformation = {
        "message": Message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "profilePicUrl": myProfilePic,
      };

      //messageId
      if (messageId == "") messageId = randomAlphaNumeric(12);

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInformation)
          .then((value) {
        /*
        Map<String, dynamic> lastMessageInformation = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName,
        };*/

        Map<String, dynamic> chatRoomInformation = {
          // "from": myUserName,
          // "to": widget.chatWithUsername,
          "users": [myUserName, widget.chatWithUsername],
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName,
          /*
          "users": [
            myUserName,
            widget.chatWithUsername,
            message,
            lastMessageTs,
            myUserName
          ],*/
        };
        if (sendClicked) {
          // Update Last Message Send
          DatabaseMethods()
              .updateLastMessageSend(chatRoomId, chatRoomInformation);
          // remove the text in the message input field
          message.text = "";
          // make message id blank to get regenerated on next message send
          messageId = "";
        }
      });
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  OnAppLaunch() async {
    await getMyInfoFromSharedPreferences();
    await getAndSetMessages();
  }

  @override
  void initState() {
    OnAppLaunch();
    super.initState();
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(28),
                  bottomRight: sendByMe
                      ? const Radius.circular(0)
                      : const Radius.circular(28),
                  topRight: const Radius.circular(28),
                  bottomLeft: sendByMe
                      ? const Radius.circular(28)
                      : const Radius.circular(0),
                ),
                color: sendByMe
                    ? const Color.fromARGB(255, 105, 228, 250)
                    : const Color.fromARGB(255, 190, 231, 76),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: const EdgeInsets.only(bottom: 70, top: 16),
                itemCount: (snapshot.data as QuerySnapshot).docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      (snapshot.data as QuerySnapshot).docs[index];
                  return chatMessageTile(documentSnapshot["message"],
                      myUserName == documentSnapshot["sendBy"]);
                })
            : const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("दो लफ्ज़"),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: message,
                      onChanged: (value) {
                        addMessage(false);
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "type a message",
                      ),
                    )),
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
