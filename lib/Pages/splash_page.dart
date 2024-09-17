// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/offers_provider.dart';
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
    Future.delayed(const Duration(seconds: 0)).then((value) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      String? userId = sharedPreferences.getString('userId');

      UserController userController =
          Provider.of<UserController>(context, listen: false);
      OffersProvider offersProvider =
          Provider.of<OffersProvider>(context, listen: false);
      userController.getCustomMarkers();
      if (userId == null) {
        // sharedPreferences.setBool('newUpdate', true);
        Get.offAll(() => ChooseAccountTypePage());
      } else {
        // sharedPreferences.setBool('newUpdate', true);

        // OneSignal.Notifications.requestPermission(true);

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
              OneSignal.login(userId + userModel.accountType);

              // await FirebaseFirestore.instance
              //     .collection('users')
              //     .doc(userId + userModel.accountType)
              //     .update({
              //   'lat': position.latitude,
              //   'geo': geoFirePoint.data,
              //   'long': position.longitude,
              // });

              userController.getUserStream(
                userId + userModel.accountType,
                onDataReceived: (userModel) {},
              );
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId + userModel.accountType)
                  .get();
              if (userModel.accountType == 'provider') {
                offersProvider
                    .startListening(UserModel.fromJson(accountTypeUserSnap));
                offersProvider.startListeningOffers(
                    UserModel.fromJson(accountTypeUserSnap).userId);
              } else {
                offersProvider.startListeningOwnerOffers(
                    UserModel.fromJson(accountTypeUserSnap).userId);
              }
              // await OneSignal.Notifications.requestPermission(true);

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
              // await Future.delayed(const Duration(seconds: 1));
              // OneSignal.login(userId + userModel.accountType);
              OneSignal.login(userId + userModel.accountType);

              // Position position = await Geolocator.getCurrentPosition();

              // final GeoFirePoint geoFirePoint =
              //     GeoFirePoint(GeoPoint(position.latitude, position.longitude));

              // await FirebaseFirestore.instance
              //     .collection('users')
              //     .doc(userId + userModel.accountType)
              //     .update({
              //   'lat': position.latitude,
              //   'geo': geoFirePoint.data,
              //   'long': position.longitude,
              // });
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId + userModel.accountType)
                  .get();
              userController.getUserStream(
                userId + userModel.accountType,
                onDataReceived: (userModel) {},
              );
              if (userModel.accountType == 'provider') {
                offersProvider.startListening(userModel);
                offersProvider.startListeningOffers(userModel.userId);
              } else {
                offersProvider.startListeningOwnerOffers(userModel.userId);
              }
              // await OneSignal.Notifications.requestPermission(true);

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
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'VEHYPE',
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 28,
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
