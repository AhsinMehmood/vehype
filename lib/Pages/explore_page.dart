// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Widgets/widget_to_icon.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
import 'second_user_profile.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    getLocations();
    _loadMapStyles();
  }

  String _darkMapStyle = '';

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/dark_mode_map.json');
    setState(() {});
  }

  double lat = 0.0;
  double long = 0.0;
  List<UserModel> nearbyProviders = [];
  Set<Marker> markers = {};
  getLocations() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;

    // Position position = await Geolocator.getCurrentPosition();
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('accountType', isEqualTo: 'provider')
        .where('status', isEqualTo: 'active')
        .get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      nearbyProviders.add(UserModel.fromJson(element));
    }
    markers.add(
      Marker(
        markerId: const MarkerId('current'),
        position: LatLng(userModel.lat, userModel.long),
      ),
    );

    for (UserModel element in nearbyProviders) {
      print(element.userId);
      if (element.userId != userController.userModel!.userId) {
        markers.add(
          Marker(
              markerId: MarkerId(element.userId),
              position: LatLng(element.lat, element.long),
              icon: await getCustomIcon(element),
              onTap: () {
                Get.bottomSheet(
                  BottomSheet(
                      onClosing: () {},
                      enableDrag: true,
                      constraints: BoxConstraints(
                        maxHeight: Get.height * 0.9,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )),
                      backgroundColor:
                          userController.isDark ? primaryColor : Colors.white,
                      builder: (conte) {
                        return SecondUserProfile(userId: element.userId);
                      }),
                  isDismissible: true,
                  isScrollControlled: true,
                );
              }),
        );
      }
    }

    lat = userModel.lat;
    long = userModel.long;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      // appBar: AppBar(
      //   elevation: 0.0,
      //   backgroundColor: userController.isDark ? primaryColor : Colors.white,
      //   centerTitle: true,
      //   leading: IconButton(
      //       onPressed: () {
      //         Get.back();
      //       },
      //       icon: Icon(
      //         Icons.arrow_back_ios_new,
      //         color: userController.isDark ? Colors.white : primaryColor,
      //       )),
      //   title: Text(
      //     'Explore Nearby',
      //     style: TextStyle(
      //       color: userController.isDark ? Colors.white : primaryColor,
      //       fontSize: 18,
      //       fontWeight: FontWeight.w800,
      //     ),
      //   ),
      // ),
      body: lat == 0.0
          ? Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            )
          : GoogleMap(
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, long),
                zoom: 16.0,
              ),
              onMapCreated: (controller) {
                if (userController.isDark) {
                  controller.setMapStyle(_darkMapStyle);
                }
              },
            ),
    );
  }

  Future<BitmapDescriptor> getCustomIcon(UserModel userData) async {
    return Container(
      height: 55,
      width: 55,
      child: Stack(
        children: [
          Icon(
            Icons.location_on,
            color: primaryColor,
            size: 55,
          ),
          Align(
            // left: 0,
            // right: 0,
            // top: 4,
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                top: 4,
              ),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: ExtendedImage.network(
                  userData.profileUrl,
                  fit: BoxFit.cover,
                  height: 20,
                  cache: true,
                  width: 20,
                  shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),
          ),
        ],
      ),
    ).toBitmapDescriptor();
  }
}
