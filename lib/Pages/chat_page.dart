// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
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
          'Chats',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
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

              List<ChatModel> chats = snap.data ?? [];
              chats.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: chats.length,
                        // physics:const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        itemBuilder: (context, index) {
                          ChatModel chat = chats[index];

                          return ChatWidget(
                            user: userModel,
                            chat: chat,
                          );
                        }),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
