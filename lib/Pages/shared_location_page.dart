import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/user_controller.dart';

class SharedLocationPage extends StatefulWidget {
  final LatLng latLng;
  const SharedLocationPage({
    super.key,
    required this.latLng,
  });

  @override
  State<SharedLocationPage> createState() => _SharedLocationPageState();
}

class _SharedLocationPageState extends State<SharedLocationPage> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final ChatController chatController = Provider.of<ChatController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'Shared Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          MapsLauncher.launchCoordinates(
              widget.latLng.latitude, widget.latLng.longitude);
        },
        child: Container(
          width: Get.size.width * 0.8,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              'Open in Maps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
              markers: {
                Marker(
                    markerId: MarkerId(userController.userModel!.userId),
                    position: widget.latLng)
              },
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              trafficEnabled: true,
              initialCameraPosition:
                  CameraPosition(zoom: 15, target: widget.latLng)),
        ],
      ),
    );
  }
}
