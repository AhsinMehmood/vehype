import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/offers_provider.dart';

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import '../const.dart';
import '../google_maps_place_picker.dart';
import 'splash_page.dart';

String apiKey = 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E';

class ProviderEditProfileTabPage extends StatefulWidget {
  final bool isNew;
  const ProviderEditProfileTabPage({super.key, required this.isNew});

  @override
  State<ProviderEditProfileTabPage> createState() =>
      _ProviderEditProfileTabPageState();
}

class _ProviderEditProfileTabPageState
    extends State<ProviderEditProfileTabPage> {
  double lat = 0.0;
  double long = 0.0;
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    lat = userController.userModel!.lat;
    long = userController.userModel!.long;
    UserModel userModel = userController.userModel!;
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
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
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: CachedNetworkImage(
                          placeholder: (context, url) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                          imageUrl: userController.userModel!.profileUrl,
                          width: 125,
                          height: 125,
                          fit: BoxFit.fill,

                          //cancelToken: cancellationToken,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                          padding: const EdgeInsets.all(2),
                          height: 24,
                          width: 24,
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    'Business Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                        hintText: 'Smith’s Towing & Roadside Assistance',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        )
                        // counter: const SizedBox.shrink(),
                        ),
                    initialValue: userController.userModel!.name,
                    onChanged: (String value) => userController.updateTexts(
                        userController.userModel!, 'name', value),
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
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
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Description',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                        hintText:
                            'Describe your services, pricing, and availability',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        )
                        // counter: const SizedBox.shrink(),
                        ),
                    initialValue: userController.userModel!.businessInfo,
                    onChanged: (String value) => userController.updateTexts(
                        userController.userModel!, 'businessInfo', value),
                    // textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
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
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Phone Number',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      // color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      CountryCodePicker(
                        onChanged: print,
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'US',
                        backgroundColor:
                            userController.isDark ? primaryColor : Colors.white,
                        dialogBackgroundColor:
                            userController.isDark ? primaryColor : Colors.white,
                        favorite: ['+1', 'PK'],
                        // optional. Shows only country name and flag
                        showCountryOnly: false,
                        // optional. Shows only country name and flag when popup is closed.
                        showOnlyCountryWhenClosed: false,
                        showFlag: true,
                        // optional. aligns the flag and the Text left
                        alignLeft: false,
                      ),
                      Expanded(
                        child: TextFormField(
                          onTapOutside: (s) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          // controller: _vinController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                            focusedBorder: InputBorder.none,
                            hintText: ' (555) 123-4567',
                            // counter: const SizedBox.shrink(),
                          ),
                          initialValue: userController.userModel!.contactInfo,
                          onChanged: (String value) =>
                              userController.updateTexts(
                                  userController.userModel!,
                                  'contactInfo',
                                  value),
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                          inputFormatters: [
                            PhoneInputFormatter(defaultCountryCode: "US")
                          ],
                          // maxLength: 25,
                          // onChanged: (String value) => editProfileProvider
                          //     .updateTexts(userModel, 'name', value),
                        ),
                      ),
                    ],
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
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Website (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                      hintText: 'www.smithstowing.com',
                      hintStyle: TextStyle(
                        // color: userController.isDark? Colors.white
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                      // counter: const SizedBox.shrink(),
                    ),
                    initialValue: userController.userModel!.website,
                    onChanged: (String value) => userController.updateTexts(
                        userController.userModel!, 'website', value),
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
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
                height: 20,
              ),
              if (widget.isNew)
                Align(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Account Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(200),
                        onTap: () async {
                          try {
                            Get.dialog(const LoadingDialog(),
                                barrierDismissible: false);
                            // User user = FirebaseAuth.instance.currentUser;
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            String realUserId =
                                sharedPreferences.getString('userId') ?? '';
                            UserModel userModel = userController.userModel!;
                            OneSignal.logout();
                            OffersProvider offersProvider =
                                Provider.of<OffersProvider>(context,
                                    listen: false);
                            offersProvider.stopListening();
                            // offersProvider.stopListening();
                            // offersProvider.stopListening();

                            userController.changeTabIndex(0);
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(realUserId)
                                .update({
                              'accountType': 'seeker',
                            });
                            userController.closeStream();
                            // userController.getUserStream(userId)/
                            Get.close(1);
                            Get.offAll(() => SplashPage());
                          } catch (e) {
                            Get.close(1);
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: 0,
                              right: 0,
                            ),
                            width: Get.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Color.fromARGB(255, 3, 0, 10),
                                border: Border.all(
                                  color: Color.fromARGB(255, 3, 0, 10),
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    // fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
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
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 200,
                              width: Get.width,
                              child: userController.userModel!.lat == 0.0
                                  ? CupertinoActivityIndicator()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: GoogleMap(
                                        onMapCreated: (contr) {
                                          _controller.complete(contr);
                                        },
                                        onTap: (s) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey: apiKey,
                                                selectText: 'Pick This Place',
                                                onTapBack: () {
                                                  Get.close(1);
                                                },
                                                onPlacePicked: (result) async {
                                                  try {
                                                    LatLng latLng = LatLng(
                                                        result.geometry!
                                                            .location.lat,
                                                        result.geometry!
                                                            .location.lng);
                                                    lat = latLng.latitude;
                                                    long = latLng.longitude;
                                                    print('dddsd');
                                                    userController
                                                        .changeLocation(latLng);
                                                    // setState(() {});

                                                    final GeoFirePoint
                                                        geoFirePoint =
                                                        GeoFirePoint(GeoPoint(
                                                            lat, long));

                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(userController
                                                            .userModel!.userId)
                                                        .update({
                                                      'lat': lat,
                                                      'geo': geoFirePoint.data,
                                                      'long': long,
                                                    });
                                                    final GoogleMapController
                                                        controller =
                                                        await _controller
                                                            .future;
                                                    await controller.animateCamera(
                                                        CameraUpdate
                                                            .newCameraPosition(
                                                                CameraPosition(
                                                      target: LatLng(lat, long),
                                                      zoom: 16.0,
                                                    )));

                                                    Get.close(1);
                                                  } catch (e) {
                                                    // Get.close(1);
                                                  }
                                                },

                                                initialPosition:
                                                    LatLng(lat, long),
                                                // useCurrentLocation: true,
                                                selectInitialPosition: true,
                                                resizeToAvoidBottomInset:
                                                    false, // only works in page mode, less flickery, remove if wrong offsets
                                              ),
                                            ),
                                          );
                                        },
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
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            // if (userController.userModel!.accountType ==
                            //     'provider')
                            Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlacePicker(
                                          apiKey: apiKey,
                                          selectText: 'Pick This Place',
                                          onTapBack: () {
                                            Get.close(1);
                                          },
                                          onPlacePicked: (result) async {
                                            // Get.dialog(LoadingDialog(),
                                            //     barrierDismissible: false);
                                            LatLng latLng = LatLng(
                                                result.geometry!.location.lat,
                                                result.geometry!.location.lng);
                                            lat = latLng.latitude;
                                            long = latLng.longitude;
                                            userController
                                                .changeLocation(latLng);
                                            setState(() {});

                                            final GeoFirePoint geoFirePoint =
                                                GeoFirePoint(
                                                    GeoPoint(lat, long));

                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userController
                                                    .userModel!.userId)
                                                .update({
                                              'lat': lat,
                                              'geo': geoFirePoint.data,
                                              'long': long,
                                            });
                                            final GoogleMapController
                                                controller =
                                                await _controller.future;
                                            await controller.animateCamera(
                                                CameraUpdate.newCameraPosition(
                                                    CameraPosition(
                                              target: LatLng(lat, long),
                                              zoom: 16.0,
                                            )));
                                            Get.close(1);
                                          },
                                          initialPosition: LatLng(lat, long),
                                          // useCurrentLocation: true,
                                          selectInitialPosition: true,
                                          resizeToAvoidBottomInset:
                                              false, // only works in page mode, less flickery, remove if wrong offsets
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: Size(Get.width * 0.9, 50),
                                  ),
                                  child: Text(
                                    'Change Location',
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                            ),
                            // if (userController.userModel!.accountType ==
                            //     'provider')
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
                    const SizedBox(
                      height: 90,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
