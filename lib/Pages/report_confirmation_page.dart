import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class ReportConfirmation extends StatefulWidget {
  const ReportConfirmation({super.key});

  @override
  State<ReportConfirmation> createState() => _ReportConfirmationState();
}

class _ReportConfirmationState extends State<ReportConfirmation> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: Container(
        color: userController.isDark ? primaryColor : Colors.white,
        height: Get.height,
        width: Get.width,
        padding: const EdgeInsets.all(15),
        child: SafeArea(
          child: Column(
   
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [],
              ),
              SizedBox(
                width: Get.width * 0.65,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thanks for keeping our community safe.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'We’ll investigate this profile.',
                      style: TextStyle(
                        // color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
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
                  ElevatedButton(
                      onPressed: () {
                        // UserController().addPushToken(userModel.id);
                        Get.close(2);
                        // Get.to(() => AddProfileImagesPage());
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          maximumSize: Size(Get.width * 0.8, 50),
                          minimumSize: Size(Get.width * 0.8, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          )),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      )),
                  SizedBox(
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
