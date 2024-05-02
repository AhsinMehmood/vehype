import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class CommentsPage extends StatelessWidget {
  final UserModel data;
  const CommentsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Reviews And Ratings',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
            itemCount: data.ratings.length,
            itemBuilder: (context, inde) {
              return StreamBuilder<UserModel>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(data.ratings[inde]['id'])
                      .snapshots()
                      .map((event) => UserModel.fromJson(event)),
                  builder: (context, AsyncSnapshot<UserModel> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                        ),
                      );
                    }
                    UserModel commenterData = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: ExtendedImage.network(
                          commenterData.profileUrl,
                          // height: 45,
                          shape: BoxShape.circle,
                          // borderRadius: Border,
                          // width: 45,
                        ),
                        title: Text(
                          commenterData.name,
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data.ratings[inde]['comment'] ?? 'No Comment',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
