// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';

import 'package:vehype/Pages/choose_account_type.dart';
import 'package:vehype/Pages/setup_business_provider.dart';
import 'package:vehype/Pages/tabs_page.dart';

import '../Controllers/mix_panel_controller.dart';
import '../const.dart';
import 'select_account_type_page.dart';
import 'package:http/http.dart' as http;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> getAddressFromLatLng(UserModel profileModel) async {
    double latitude = profileModel.lat;
    double longitude = profileModel.long;
    if (profileModel.businessAddress.isEmpty) {
      String apiKey =
          'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E'; // Replace with your Google Maps API key
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

      try {
        var response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          if (json['status'] == 'OK' &&
              json['results'] != null &&
              json['results'].isNotEmpty) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(profileModel.userId)
                .update({
              'businessAddress': json['results'][0]['formatted_address'],
            });
          } else {}
        } else {}
      } catch (e) {}
    } else {}
  }

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
      // Get..
      final mixPanelController = Get.find<MixPanelController>();

      if (userId == null) {
        // sharedPreferences.setBool('newUpdate', true);
        mixPanelController.trackEvent(eventName: 'Open Login Page', data: {});
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
          mixPanelController
              .trackEvent(eventName: 'Open Select Account Type Page', data: {});

          Get.offAll(() => SelectAccountType(
                userModelAccount: userModel,
              ));
        } else {
          if (userModel.adminStatus == 'blocked') {
            mixPanelController
                .trackEvent(eventName: 'Open Disabled Page', data: {});

            Get.offAll(() => const DisabledWidget());
          } else {
            DocumentSnapshot<Map<String, dynamic>> accountTypeUserSnap =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId + userModel.accountType)
                    .get();
            mixPanelController.identifyUser(userId + userModel.accountType);
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
              DocumentSnapshot<Map<String, dynamic>> userSnapss =
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
              // log(userSnapss.data()!['lat'].toString());

              if (userSnapss.data()!['lat'] == null ||
                  userSnapss.data()!['lat'] == 0.0) {
                Future.delayed(const Duration(seconds: 0)).then((s) {
                  mixPanelController.trackEvent(
                      eventName: 'Asked For Location Permission', data: {});
                  Get.bottomSheet(
                    LocationPermissionSheet(
                      userController: userController,
                      isProvider: userModel.accountType == 'provider',
                    ),
                    backgroundColor:
                        userController.isDark ? primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    isDismissible: false,
                    // enableDrag: false,
                  );
                });
              } else {
                mixPanelController
                    .trackEvent(eventName: 'Open Tabs Page', data: {});
                getAddressFromLatLng(UserModel.fromJson(accountTypeUserSnap));
                if (UserModel.fromJson(accountTypeUserSnap).accountType ==
                    'provider') {
                  if (UserModel.fromJson(accountTypeUserSnap).isBusinessSetup) {
                    Get.offAll(() => const TabsPage());
                  } else {
                    Get.offAll(() => const SetupBusinessProvider());
                  }
                } else {
                  Get.offAll(() => const TabsPage());
                }
              }
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
              DocumentSnapshot<Map<String, dynamic>> userSnapss =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId + userModel.accountType)
                      .get();
              log(userSnapss.data()!['lat'].toString());
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
              // await Future.delayed(Duration(milliseconds: 600));
              // await OneSignal.Notifications.requestPermission(true);

              if (userSnapss.data()!['lat'] == null ||
                  userSnapss.data()!['lat'] == 0.0) {
                Future.delayed(const Duration(seconds: 0)).then((s) {
                  mixPanelController.trackEvent(
                      eventName: 'Asked For Location Permission', data: {});
                  Get.bottomSheet(
                    LocationPermissionSheet(
                      userController: userController,
                      isProvider: userModel.accountType == 'provider',
                    ),
                    backgroundColor:
                        userController.isDark ? primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    isDismissible: false,
                    // enableDrag: false,
                  );
                });
              } else {
                mixPanelController
                    .trackEvent(eventName: 'Open Tabs Page', data: {});

                Get.offAll(() => const TabsPage());
              }
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
            child: Column(
              children: [
                Text(
                  'VEHYPE',
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 28,
                    fontFamily: poppinsBold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                // Text(
                //   'HYPE YOUR VEHICLE',
                //   style: TextStyle(
                //     color: userController.isDark ? Colors.white : primaryColor,
                //     fontSize: 16,
                //     // fontFamily: poppinsBold,
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),
              ],
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
