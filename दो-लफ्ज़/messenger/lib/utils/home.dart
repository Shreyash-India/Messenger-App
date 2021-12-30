// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, unnecessary_string_escapes, use_key_in_widget_constructors, unnecessary_null_comparison
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/helper/helper.dart';
import 'package:messenger/utils/sign_in.dart';
import 'package:messenger/services/auth.dart';
import 'package:messenger/services/database.dart';
import 'chat.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  late String myName, myProfilePic, myUserName, myEmail;
  TextEditingController searchUsername = TextEditingController();
  late Stream userInfoFromStream;
  late Stream<dynamic> RoomStream;

  getMyInfoFromSharedPreferences() async {
    myName = (await SharedPreferencesHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferencesHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferencesHelper().getUserName())!;
    myEmail = (await SharedPreferencesHelper().getUserEmail())!;
  }

  void onSearchBtnClick() async {
    isSearching = true;
    userInfoFromStream =
        await DatabaseMethods().getUserByUserName(searchUsername.text);
    setState(() {});
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

  Widget Room() {
    return StreamBuilder(
      stream: RoomStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: (snapshot.data as QuerySnapshot).docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      (snapshot.data as QuerySnapshot).docs[index];
                  return RoomTile(documentSnapshot["lastMessage"],
                      documentSnapshot.id, myUserName);
                })
            : Container();
      },
    );
  }

  Widget UserCard({String? userprofile, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = generateChatRoomId(myUserName, username);
        Map<String, dynamic> chatRoomInformation = {
          // "from": myUserName,
          // "to": username,
          "users": [myUserName, username],
          "lastMessage": "",
          "lastMessageSendTs": "",
          "lastMessageSendBy": "",
        };
        // Create ChatRoom if it does not exists..
        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInformation);

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Chat(username, name)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                userprofile!,
                height: 35,
                width: 35,
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 228, 78, 78)),
              ),
              const SizedBox(height: 3),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  Widget searchUsersByUserName() {
    return StreamBuilder(
      stream: userInfoFromStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: (snapshot.data! as QuerySnapshot).docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot =
                  (snapshot.data! as QuerySnapshot).docs[index];
              return UserCard(
                  userprofile: documentSnapshot["userProfile"],
                  name: documentSnapshot["name"],
                  email: documentSnapshot["email"],
                  username: documentSnapshot["userName"]);
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  getRooms() async {
    RoomStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onLoad() async {
    await getMyInfoFromSharedPreferences();
    // getRooms();
  }

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("दो लफ्ज़"),
        actions: [
          InkWell(
            onTap: () {
              Auth().signOut().then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const SignIn()));
              });
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            searchUsername.text = "";
                          });
                        },
                        child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 241, 110, 110),
                            width: 2,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUsername,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Username to Chat"),
                        )),
                        GestureDetector(
                          onTap: () {
                            if (searchUsername.text != "") {
                              onSearchBtnClick();
                            }
                          },
                          child: const Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersByUserName() : Container(),
          ],
        ),
      ),
    );
  }
}

class RoomTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  const RoomTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _RoomTileState createState() => _RoomTileState();
}

class _RoomTileState extends State<RoomTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]["name"]}";
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(username, widget.myUsername)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: profilePicUrl != null
                  ? Image.network(
                      profilePicUrl,
                      height: 40,
                      width: 40,
                    )
                  : Container(),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(widget.lastMessage)
              ],
            )
          ],
        ),
      ),
    );
  }
}
