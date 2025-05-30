// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import '../Controllers/user_controller.dart';
import '../Pages/repair_page.dart';
import '../const.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    mixPanelController
        .trackEvent(eventName: 'Asked for notification permission', data: {});

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      // height: 300,
      width: Get.width,
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              'Get Important Updates',
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'We will notify you about updates to Requests, new Offers, and Messages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: userController.isDark ? Colors.white : primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                await OneSignal.Notifications.requestPermission(true);
                // await OneSignal.Notifications.
                mixPanelController
                    .trackEvent(eventName: 'Notification Allowed', data: {});

                OneSignal.login(userController.userModel!.userId);
                Get.close(1);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.8, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Yes, notify me',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                mixPanelController
                    .trackEvent(eventName: 'Maybe later', data: {});

                Get.close(1);
              },
              child: Text(
                'Maybe later',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: userController.isDark
                      ? Colors.white.withOpacity(0.7)
                      : primaryColor,
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
