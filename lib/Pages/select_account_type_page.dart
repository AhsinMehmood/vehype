import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/const.dart';

import '../Controllers/offers_provider.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import 'location_permission.dart';

class SelectAccountType extends StatelessWidget {
  final UserModel userModelAccount;
  // final String userId;
  const SelectAccountType({super.key, required this.userModelAccount});

  @override
  Widget build(BuildContext context) {
    // final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            const Text(
              'Select Your Account Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Get.dialog(const LoadingDialog(),
                          barrierDismissible: false);
                      print(userModelAccount.userId);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userModelAccount.userId)
                          .update({
                        'accountType': 'provider',
                      });
                      LatLng latLng = await UserController().getLocations();

                      final GeoFirePoint geoFirePoint = GeoFirePoint(
                          GeoPoint(latLng.latitude, latLng.longitude));
                      DocumentSnapshot<Map<String, dynamic>> userSNap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc('${userModelAccount.userId}provider')
                              .get();
                      if (userSNap.exists) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userSNap.id)
                            .update({
                          'isDelete': false,
                          'accountType': 'provider',
                          'name': userModelAccount.name,
                        });
                      } else {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc('${userModelAccount.userId}provider')
                            .set({
                          'accountType': 'provider',
                          'name': userModelAccount.name,
                          // 'accountType': 'owner',
                          'profileUrl': userModelAccount.profileUrl,
                          'id': '${userModelAccount.userId}provider',
                          'email': userModelAccount.email,
                          'status': 'active',
                          'lat': latLng.latitude,
                          'long': latLng.longitude,
                          'geo': geoFirePoint.data,
                        });
                      }

                      OneSignal.login('${userModelAccount.userId}provider');

                      userController.getUserStream(
                        '${userModelAccount.userId}provider',
                        onDataReceived: (userModel) {
                          OffersProvider offersProvider =
                              Provider.of<OffersProvider>(context,
                                  listen: false);
                          offersProvider.startListening(userModel);
                          offersProvider.startListeningOffers(userModel.userId);

                          // await OneSignal.Notifications.requestPermission(true);

                          Get.close(1);

                          Get.offAll(() => const TabsPage());
                        },
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        width: Get.width * 0.7,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'I\'m Service Owner',
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Get.dialog(const LoadingDialog(),
                          barrierDismissible: false);

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userModelAccount.userId)
                          .update({
                        'accountType': 'seeker',
                      });
                      OneSignal.login('${userModelAccount.userId}seeker');
                      LatLng latLng = await UserController().getLocations();

                      final GeoFirePoint geoFirePoint = GeoFirePoint(
                          GeoPoint(latLng.latitude, latLng.longitude));
                      DocumentSnapshot<Map<String, dynamic>> userSNap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc('${userModelAccount.userId}seeker')
                              .get();
                      if (userSNap.exists) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userSNap.id)
                            .update({
                          'isDelete': false,
                          'accountType': 'seeker',
                          'name': userModelAccount.name,
                        });
                      } else {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc('${userModelAccount.userId}seeker')
                            .set({
                          'accountType': 'seeker',
                          'name': userModelAccount.name,
                          // 'accountType': 'owner',
                          'profileUrl': userModelAccount.profileUrl,
                          'id': '${userModelAccount.userId}seeker',
                          'email': userModelAccount.email,
                          'status': 'active',
                          'lat': latLng.latitude,
                          'long': latLng.longitude,
                          'geo': geoFirePoint.data,
                        });
                      }

                      userController.getUserStream(
                        '${userModelAccount.userId}seeker',
                        onDataReceived: (userModel) {
                          OffersProvider offersProvider =
                              Provider.of<OffersProvider>(context,
                                  listen: false);
                          offersProvider
                              .startListeningOwnerOffers(userModel.userId);

                          // await OneSignal.Notifications.requestPermission(true);

                          Get.close(1);

                          Get.offAll(() => const TabsPage());
                        },
                      );
                      // await OneSignal.Notifications.requestPermission(true);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        width: Get.width * 0.7,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: const Color.fromARGB(255, 3, 0, 10),
                            border: Border.all(
                              color: const Color.fromARGB(255, 3, 0, 10),
                            )),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'I\'m Vehicle Owner',
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
