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
      body: ProviderEditProfileTabPage(
        isNew: true,
      ),
    );
  }
}
