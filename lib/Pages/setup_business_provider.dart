import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import 'edit_profile_page.dart';
import 'profile_page.dart';
import 'provider_edit_profile_tab_page.dart';

class SetupBusinessProvider extends StatefulWidget {
  const SetupBusinessProvider({super.key});

  @override
  State<SetupBusinessProvider> createState() => _SetupBusinessProviderState();
}

class _SetupBusinessProviderState extends State<SetupBusinessProvider> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Get.bottomSheet(LogoutConfirmation());
          },
          icon: Icon(Icons.logout),
        ),
        centerTitle: true,
        title: Text(
          'Setup Service Profile',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            Get.dialog(LoadingDialog(), barrierDismissible: false);
            DocumentSnapshot<Map<String, dynamic>> snap =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userModel.userId)
                    .get();
            UserModel newUser = UserModel.fromJson(snap);
            if (newUser.name.isNotEmpty &&
                newUser.contactInfo.isNotEmpty &&
                newUser.businessInfo.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userModel.userId)
                  .update({
                'isBusinessSetup': true,
              });
              Get.offAll(() => TabsPage());
            } else {
              print(newUser.phoneNumber);
              Get.close(1);
              Get.showSnackbar(GetSnackBar(
                message: 'All the fields are required',
                duration: Duration(seconds: 3),
                snackPosition: SnackPosition.TOP,
              ));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                userController.isDark ? Colors.white : primaryColor,
            minimumSize: Size(Get.width * 0.9, 55),
            maximumSize: Size(Get.width * 0.9, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Continue',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: userController.isDark ? primaryColor : Colors.white,
            ),
          )),
      body: ProviderEditProfileTabPage(
        isNew: false,
      ),
    );
  }
}
