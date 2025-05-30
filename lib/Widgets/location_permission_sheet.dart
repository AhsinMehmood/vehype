import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import '../Controllers/mix_panel_controller.dart';
import '../Controllers/user_controller.dart';
import '../Pages/tabs_page.dart';
import '../const.dart';

import 'loading_dialog.dart';

final mixPanelController = Get.find<MixPanelController>();

class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({
    super.key,
    this.isProvider = false,
  });

  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      // height: 280,
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'Your location allows VEHYPE to provide accurate maps and find services near you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Text(
            //   userController.userModel!.accountType == 'Provider'
            //       ? 'Grant access to connect with nearby customers.'
            //       : 'Grant access to find service providers near you.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: userController.isDark ? Colors.white : primaryColor,
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                bool serviceEnabled;
                LocationPermission permission =
                    await Geolocator.requestPermission();

                serviceEnabled = await Geolocator.isLocationServiceEnabled();
                if (!serviceEnabled) {
                  Get.showSnackbar(GetSnackBar(
                    message: 'Location is disabled. Tap to open Settings.',
                    onTap: (d) {
                      Geolocator.openLocationSettings();
                    },
                    duration: Duration(seconds: 3),
                  ));
                  mixPanelController
                      .trackEvent(eventName: 'Location is disabled', data: {});
                } else {
                  // permission = await Geolocator.checkPermission();
                  // permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied ||
                      permission == LocationPermission.deniedForever ||
                      permission == LocationPermission.unableToDetermine) {
                    Get.showSnackbar(GetSnackBar(
                      message: 'Location is disabled. Tap to open Settings.',
                      onTap: (d) {
                        Geolocator.openAppSettings();
                      },
                      duration: Duration(seconds: 3),
                    ));
                    mixPanelController
                        .trackEvent(eventName: 'Location is denied', data: {});
                  } else {
                    Get.dialog(const LoadingDialog(),
                        barrierDismissible: false);
                    mixPanelController
                        .trackEvent(eventName: 'Asked for location', data: {});
                    Position position = await Geolocator.getCurrentPosition();

                    final GeoFirePoint geoFirePoint = GeoFirePoint(
                        GeoPoint(position.latitude, position.longitude));

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userController.userModel!.userId)
                        .update({
                      'lat': position.latitude,
                      'long': position.longitude,
                      'geo': geoFirePoint.data,
                    });
                    mixPanelController
                        .trackEvent(eventName: 'Location is updated', data: {});
                    // userController.changeLocation(
                    //     LatLng(position.latitude, position.longitude));
                    // userController
                    //     .pushTokenUpdate(userController.userModel!.userId);
                    await Future.delayed(Duration(seconds: 1));
                    Get.close(2);
                    mixPanelController
                        .trackEvent(eventName: 'Opended tabs page', data: {});
                    Get.offAll(() => const TabsPage());
                  }

                  // Get.close(1);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
