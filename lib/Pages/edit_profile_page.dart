// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/login_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  double lat = 0.0;
  double long = 0.0;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getLocations();
  }

  getLocations() async {
    bool serviceEnabled;
    LocationPermission permission;
    print('info go here');

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    Position position = await Geolocator.getCurrentPosition();
    lat = position.latitude;
    long = position.longitude;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userController.userModel!.userId)
        .update({
      'lat': position.latitude,
      'long': position.longitude,
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    UserController().selectAndUploadImage(
                        context, userController.userModel!, 0);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: ExtendedImage.network(
                      userController.userModel!.profileUrl,
                      width: 125,
                      height: 125,
                      fit: BoxFit.fill,
                      cache: true,
                      // border: Border.all(color: Colors.red, width: 1.0),
                      shape: BoxShape.circle,
                      borderRadius: BorderRadius.all(Radius.circular(200.0)),
                      //cancelToken: cancellationToken,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      // controller: _vinController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'John Doe',
                        // counter: const SizedBox.shrink(),
                      ),
                      initialValue: userController.userModel!.name,
                      onChanged: (String value) => userController.updateTexts(
                          userController.userModel!, 'name', value),
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) => editProfileProvider
                      //     .updateTexts(userModel, 'name', value),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: 1,
                  width: Get.width,
                  color: changeColor(color: 'D9D9D9'),
                ),
                const SizedBox(
                  height: 50,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Account Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(200),
                        onTap: () async {
                          // Get.dialog(const LoadingDialog(),
                          //     barrierDismissible: false);
                          userController.changeTabIndex(0);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userController.userModel!.userId)
                              .update({
                            'accountType': 'provider',
                          });
                          // LoginController.signInWithGoogle('provider', context);
                          // LoginController.signInWithGoogle(
                          //     userProvider: userProvider, context: context);
                          // Get.to(() => const CompleteProfile());
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: 8,
                              right: 8,
                            ),
                            width: Get.width * 0.7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    // color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'I\'m Service Owner',
                                  style: TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                ),
                                Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color:
                                        userController.userModel!.accountType ==
                                                'provider'
                                            ? Colors.green
                                            : Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.done,
                                    color:
                                        userController.userModel!.accountType ==
                                                'provider'
                                            ? Colors.white
                                            : Colors.transparent,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(200),
                        onTap: () async {
                          userController.changeTabIndex(0);

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userController.userModel!.userId)
                              .update({
                            'accountType': 'seeker',
                          });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: 8,
                              right: 8,
                            ),
                            width: Get.width * 0.7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: Color.fromARGB(255, 3, 0, 10),
                                border: Border.all(
                                  color: Color.fromARGB(255, 3, 0, 10),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    // color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'I\'m Vehicle Owner',
                                  style: TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color:
                                        userController.userModel!.accountType ==
                                                'seeker'
                                            ? Colors.green
                                            : Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.done,
                                    color:
                                        userController.userModel!.accountType ==
                                                'seeker'
                                            ? Colors.white
                                            : Colors.transparent,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        child: SizedBox(
                          width: Get.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                height: 200,
                                width: Get.width,
                                child: userController.userModel!.lat == 0.0
                                    ? CupertinoActivityIndicator()
                                    : GoogleMap(
                                        markers: {
                                          Marker(
                                            markerId: MarkerId('current'),
                                            position: LatLng(
                                                userController.userModel!.lat,
                                                userController.userModel!.long),
                                          ),
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                              userController.userModel!.lat,
                                              userController.userModel!.long),
                                          zoom: 16.0,
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 1,
                                  width: Get.width,
                                  color: changeColor(color: 'D9D9D9'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (userController.userModel!.accountType == 'provider')
                        const SizedBox(
                          height: 30,
                        ),
                      if (userController.userModel!.accountType == 'provider')
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'My Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      for (Service service in getServices())
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                // userController.selectServices(service.name);
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userController.userModel!.userId)
                                    .update({
                                  'services':
                                      FieldValue.arrayUnion([service.name])
                                });
                                // appProvider.selectPrefs(pref);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1.5,
                                    child: Checkbox(
                                        activeColor: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        checkColor: userController.isDark
                                            ? Colors.green
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        value: userController
                                            .userModel!.services
                                            .contains(service.name),
                                        onChanged: (s) {
                                          // appProvider.selectPrefs(pref);
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(userController
                                                  .userModel!.userId)
                                              .update({
                                            'services': FieldValue.arrayUnion(
                                                [service.name])
                                          });
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  SvgPicture.asset(service.image,
                                      height: 40,
                                      width: 40,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    service.name,
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
