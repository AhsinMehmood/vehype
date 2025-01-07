import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/user_controller.dart';

class ShareLocationPage extends StatefulWidget {
  final ChatModel chatModel;
  final UserModel secondUserModel;
  final OffersModel offersModel;
  const ShareLocationPage({
    super.key,
    required this.chatModel,
    required this.secondUserModel,
    required this.offersModel,
  });

  @override
  State<ShareLocationPage> createState() => _ShareLocationPageState();
}

class _ShareLocationPageState extends State<ShareLocationPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng latLng = LatLng(0.0, 0.0);
  @override
  void initState() {
    super.initState();
    Future.delayed(Durations.medium1).then((d) {
      getLocation();
    });
  }

  bool loading = true;
  getLocation() async {
    LatLng latLnog = await UserController().getLocations();
    setState(() {
      latLng = latLnog;
      loading = false;
    });
  }

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
          'Share Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: loading == false
          ? InkWell(
              onTap: () {
                chatController.sendMessage(
                    userController.userModel!,
                    widget.chatModel,
                    'Location',
                    widget.secondUserModel,
                    '',
                    '',
                    false,
                    widget.offersModel,
                    false,
                    '',
                    isLocation: true,
                    latlng: latLng);
                Get.back();
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
                    'Send Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          !loading
              ? GoogleMap(
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  markers: {
                    Marker(
                        markerId: MarkerId(userController.userModel!.userId),
                        position: latLng)
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  trafficEnabled: true,
                  initialCameraPosition:
                      CameraPosition(zoom: 15, target: latLng))
              : SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () async {
                LatLng latLnog = await UserController().getLocations();
                setState(() {
                  latLng = latLnog;
                });

                final GoogleMapController contr = await _controller.future;
                contr.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: latLnog, zoom: 16)));
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: userController.isDark ? primaryColor : Colors.white),
                child: Center(
                  child: Icon(
                    Icons.my_location,
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
