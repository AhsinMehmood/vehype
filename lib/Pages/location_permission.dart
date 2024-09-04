// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Widgets/loading_dialog.dart';
import 'tabs_page.dart';

class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // final UserModel userModel = Provider.of<UserModel>(context);
    UserModel userModel = Provider.of<UserController>(context).userModel!;

    return WillPopScope(
      onWillPop: () async {
        // UserController().addPushToken(userModel.id, false);

        return false;
      },
      child: Scaffold(
        body: Container(
          color: Colors.white,
          height: Get.height,
          width: Get.width,
          padding: const EdgeInsets.all(15),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: Get.height * 0.1,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                    // width: Get.width * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Permission.',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Avenir',
                            fontSize: Get.width * 0.07,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Please allow location permission in order to use the app.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Avenir',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        // Text(
                        //   '93% of active users have notifications.',
                        //   style: TextStyle(
                        //     color: Colors.black,
                        //     fontFamily: 'Avenir',
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                onPressed: () async {
                  Get.dialog(const LoadingDialog(), barrierDismissible: false);
                  LatLng latLng = await UserController().getLocations();
                  final GeoFirePoint geoFirePoint =
                      GeoFirePoint(GeoPoint(latLng.latitude, latLng.longitude));

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userModel.userId)
                      .update({
                    'geo': geoFirePoint.data,
                    'lat': latLng.latitude,
                    'long': latLng.longitude,
                  });

                  Get.close(1);
                  Get.offAll(() => const TabsPage());
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    maximumSize: Size(Get.width * 0.8, 60),
                    minimumSize: Size(Get.width * 0.8, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    )),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    // height: Get.height * 0.1,
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w800,
                  ),
                )),
            SizedBox(
              height: Get.height * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}
