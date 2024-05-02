// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/chat_widget.dart';

import '../const.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

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
    );
  }
}
