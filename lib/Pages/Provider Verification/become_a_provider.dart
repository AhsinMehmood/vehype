import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/Provider%20Verification/import_google_business_page.dart';
import 'package:vehype/const.dart';

class BecomeAProvider extends StatelessWidget {
  const BecomeAProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
        title: Text(
          'Earn with VEHYPE',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              'Unlock a new income stream with VEHYPE',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              'Offer your automotive services to local customers through VEHYPE.\nGet discovered, make offers, and grow your business—your way.',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: SizedBox()),
            Text(
              'Have a Google Business?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () {
                  Get.to(() => ImportGoogleBusinessPage());
                },
                style: ElevatedButton.styleFrom(
                  maximumSize: Size(Get.width * 0.8, 55),
                  minimumSize: Size(Get.width * 0.8, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  backgroundColor:
                      userController.isDark ? Colors.blueGrey : primaryColor,
                ),
                child: Text(
                  'Import My Business',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            Text('OR'),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  maximumSize: Size(Get.width * 0.8, 55),
                  minimumSize: Size(Get.width * 0.8, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  backgroundColor: userController.isDark
                      ? primaryColor.withOpacity(0.1)
                      : null,
                ),
                child: Text(
                  'Register Manually',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                )),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
