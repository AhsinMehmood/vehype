// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/chat_widget.dart';

import '../const.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // bool isShow = false;
  @override
  void initState() {
    super.initState();
    getNotificationSetting();
  }

  getNotificationSetting() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    bool isNotAllowed = await OneSignal.Notifications.canRequest();
    userController.changeIsShow(isNotAllowed);
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Messages',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: StreamBuilder<List<ChatModel>>(
                // initialData: [],
                stream: ChatController().chatsStream(userModel.userId, context),
                builder: (context, AsyncSnapshot<List<ChatModel>> snap) {
                  if (snap.data == null || snap.data!.isEmpty) {
                    return Center(
                      child: Text('Nothing here!'),
                    );
                  }

                  // List<ChatModel> chats =
                  //     snap.data!.where((element) => element.).toList();

                  return ListView.builder(
                      itemCount: snap.data!.length,
                      // physics:const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) {
                        ChatModel chat = snap.data![index];

                        return ChatWidget(
                          user: userModel,
                          chat: chat,
                        );
                      });
                }),
          ),
          if (userController.isShow)
            Container(
              color: Colors.black,
              width: Get.width,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You are missing Important\nnotifications.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          OneSignal.Notifications.requestPermission(true);
                          userController.changeIsShow(false);
                        },
                        child: Text(
                          'Enable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            userController.changeIsShow(false);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ))
                    ],
                  )
                ],
              ),
            )
        ],
      ),
    );
  }
}
