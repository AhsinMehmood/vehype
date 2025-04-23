import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/new_offers_page.dart';
// import 'package:vehype/Widgets/select_services_widget.dart';
import 'package:vehype/const.dart';

class ManagePrefs extends StatelessWidget {
  const ManagePrefs({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
       
          'Manage Prefrences',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SelectYourServices(
        isPage: true,
      ),
    );
  }
}
