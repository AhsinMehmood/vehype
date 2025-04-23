import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';

import 'package:vehype/const.dart';

import 'profile_page.dart';
import 'provider_edit_profile_tab_page.dart';

class SetupBusinessProvider extends StatefulWidget {
  final PlaceDetails? placeDetails;
  const SetupBusinessProvider({super.key, required this.placeDetails});

  @override
  State<SetupBusinessProvider> createState() => _SetupBusinessProviderState();
}

class _SetupBusinessProviderState extends State<SetupBusinessProvider> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
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
        placeDetails: widget.placeDetails,
      ),
    );
  }
}
