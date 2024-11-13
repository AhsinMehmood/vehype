import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Pages/message_page.dart';
import '../Pages/report_confirmation_page.dart';

class ReportConfirmationSheet extends StatelessWidget {
  const ReportConfirmationSheet({
    super.key,
    required this.userController,
    required this.widget,
    required this.reason,
  });

  final UserController userController;
  final String reason;
  final MessagePage widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: Get.height * 0.25,
      width: Get.width,
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              'Are you sure? You won\'t be able to contact each other anymore',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                // Get.close(1);
                try {
                  Get.dialog(LoadingDialog(), barrierDismissible: false);

                  await userController.blockAndReport(
                      widget.chatModel.id,
                      userController.userModel!.userId,
                      widget.secondUser.userId,
                      widget.secondUser,
                      reason);
                  Get.close(2);

                  Get.to(() => ReportConfirmation());
                } catch (e) {
                  print(e);
                  Get.close(1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    userController.isDark ? Colors.white : primaryColor,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                maximumSize: Size(Get.width * 0.6, 50),
                minimumSize: Size(Get.width * 0.6, 50),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 18,
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
