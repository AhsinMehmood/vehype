import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: userController.isDark ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          height: 100,
          width: Get.width * 0.2,
          child: Center(
            child: CircularProgressIndicator(
              color: userController.isDark ? Colors.white : primaryColor,
              strokeCap: StrokeCap.round,
              strokeWidth: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
