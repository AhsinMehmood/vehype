// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';

import 'package:vehype/Pages/choose_account_type.dart';
import 'package:vehype/Pages/tabs_page.dart';

import '../const.dart';
import 'select_account_type_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String? userId = sharedPreferences.getString('userId');

      UserController userController =
          Provider.of<UserController>(context, listen: false);

      if (userId == null) {
        Get.offAll(() => ChooseAccountTypePage());
      } else {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        UserModel userModel = UserModel.fromJson(snapshot);
        if (userModel.accountType == '') {
          Get.offAll(() => SelectAccountType(
                userModelAccount: userModel,
              ));
        } else {
          if (userModel.adminStatus == 'blocked') {
            Get.offAll(() => const DisabledWidget());
          } else {
            DocumentSnapshot<Map<String, dynamic>> accountTypeUserSnap =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId + userModel.accountType)
                    .get();
            if (accountTypeUserSnap.exists) {
              print(accountTypeUserSnap.data()!['userId']);
              print(userId);
              print(userModel.userId);

              userController.getUserStream(userId + userModel.accountType);
              await Future.delayed(const Duration(seconds: 2));
              Get.offAll(() => const TabsPage());
            } else {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId + userModel.accountType)
                  .set({
                'accountType': userModel.accountType,
                'name': userModel.name,
                // 'accountType': 'owner',
                'profileUrl': userModel.profileUrl,
                'id': '$userId${userModel.accountType}',
                'email': userModel.email,
                'status': 'active',
              });
              await Future.delayed(const Duration(seconds: 2));

              userController.getUserStream(userId + userModel.accountType);
              await Future.delayed(const Duration(seconds: 2));
              Get.offAll(() => const TabsPage());
            }
          }
        }
        // if(streamSubscription.)
        // Get.offAll(() => TabsPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'VEHYPE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: poppinsBold,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DisabledWidget extends StatelessWidget {
  const DisabledWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // final UserModel userModel = Provider.of<UserModel>(context);
    return Scaffold(
      body: Container(
        color: Colors.white,
        height: Get.height,
        width: Get.width,
        padding: const EdgeInsets.all(15),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 30,
              ),
              // Row(
              //   children: [
              //     IconButton(
              //         onPressed: () {
              //           UserController().addPushToken(userModel.id);

              //           Get.close(1);
              //         },
              //         icon: const Icon(
              //           Icons.arrow_back_ios,
              //         ))
              //   ],
              // ),
              SizedBox(
                // width: Get.width * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your profile was flagged.',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Avenir',
                        fontSize: Get.width * 0.07,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
