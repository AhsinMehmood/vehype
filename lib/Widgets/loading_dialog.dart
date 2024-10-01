import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  bool showWait = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 6)).then((s) {
      showWait = true;
      setState(() {});
    });
  }

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
            borderRadius: BorderRadius.circular(6),
          ),
          height: 120,
          width: Get.width * 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 4.0,
                ),
              ),
              if (showWait)
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'It is taking longer then expected please wait...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
