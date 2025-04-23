import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

class BlockedUsers extends StatelessWidget {
  const BlockedUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        title: Text(
          'Blocked Users',
          style: TextStyle(
     
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.close(1);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: userController.isDark ? Colors.white : primaryColor,
          ),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('blockedBy', arrayContains: userModel.userId)
              // .where('name', isNotEqualTo: 'Private User')
              .snapshots()
              .map((convert) => convert.docs
                  .map((toElement) => UserModel.fromJson(toElement))
                  .toList()),
          builder: (context, AsyncSnapshot<List<UserModel>> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final List<UserModel> blockedUsers = snap.data ?? [];

            if (blockedUsers.isEmpty) {
              return Center(child: Text('Nothing here!'));
            }

            return ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final UserModel blockedUserModel = blockedUsers[index];

                return Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: SizedBox(
                            height: 65,
                            width: 65,
                            child: CachedNetworkImage(
                              imageUrl: blockedUserModel.profileUrl,
                              fit: BoxFit.cover,
                            )),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          blockedUserModel.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          UserController().unblockUser(
                              userModel.userId, blockedUserModel.userId);
                        },
                        child: Container(
                          height: 45,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              'Unblock',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
