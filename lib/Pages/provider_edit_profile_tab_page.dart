import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Database/fetchAndUploadVehicleData.dart';
import 'package:vehype/Pages/Auth/verify_otp_page.dart';

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import '../const.dart';
import '../google_maps_place_picker.dart';
import 'service_set_opening_hours.dart';
import 'splash_page.dart';

String apiKey = 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E';

class ProviderEditProfileTabPage extends StatefulWidget {
  final bool isNew;
  final PlaceDetails? placeDetails;
  const ProviderEditProfileTabPage(
      {super.key, required this.isNew, required this.placeDetails});

  @override
  State<ProviderEditProfileTabPage> createState() =>
      _ProviderEditProfileTabPageState();
}

class _ProviderEditProfileTabPageState
    extends State<ProviderEditProfileTabPage> {
  double lat = 0.0;
  double long = 0.0;
  bool loading = false;
  String selectedCountry = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController businessDescriptionController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.placeDetails != null) {
      phoneNumber = TextEditingController(
          text: widget.placeDetails!.internationalPhoneNumber);
      nameController = TextEditingController(text: widget.placeDetails!.name);
      websiteController =
          TextEditingController(text: widget.placeDetails!.website);
      lat = widget.placeDetails!.geometry!.location.lat;
      long = widget.placeDetails!.geometry!.location.lng;
    } else {
      getSelectedCountry();
    }
  }

  getSelectedCountry() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    UserModel userModel = userController.userModel!;
    nameController = TextEditingController(text: userModel.name);
    businessDescriptionController =
        TextEditingController(text: userModel.businessInfo);
    phoneNumber = TextEditingController(text: userModel.contactInfo);
    websiteController = TextEditingController(text: userModel.website);
    String country = await getCountryFromLatLng(userModel.lat, userModel.long);
    getDialCode(country);
  }

  void getDialCode(String countryCode) {
    CountryCode code = CountryCode.fromCountryCode(countryCode);
    selectedCountry = code.dialCode!;
    setState(() {});

    // print("Dial Code: ${code.dialCode}"); // Example: +92 for PK
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

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
                          imageUrl:
                              widget.placeDetails!.icon ?? userModel.profileUrl,
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
                    controller: nameController,
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

                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                    controller: businessDescriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2))),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2))),
                        hintText:
                            'Describe your services, pricing, and availability',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        )
                        // counter: const SizedBox.shrink(),
                        ),

                    // textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                      Text(
                        selectedCountry,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          // color: changeColor(color: '7B7B7B'),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          onTapOutside: (s) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          controller: phoneNumber,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                            focusedBorder: InputBorder.none,
                            hintText: '(555) 123-4567',
                            // counter: const SizedBox.shrink(),
                          ),

                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                          inputFormatters: [
                            PhoneInputFormatter(defaultCountryCode: "US"),
                            LengthLimitingTextInputFormatter(14),
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
                    controller: websiteController,
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
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9./:_-]')), // Allows URL characters
                      LengthLimitingTextInputFormatter(
                          100), // Limits input to 100 characters
                    ],
                    keyboardType: TextInputType.url,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
              if (!widget.isNew)
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
                                        // onTap: (s) {
                                        //   Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) => PlacePicker(
                                        //         apiKey: apiKey,
                                        //         selectText: 'Pick This Place',
                                        //         onTapBack: () {
                                        //           Get.close(1);
                                        //         },
                                        //         onPlacePicked: (result) async {
                                        //           try {
                                        //             LatLng latLng = LatLng(
                                        //                 result.geometry!
                                        //                     .location.lat,
                                        //                 result.geometry!
                                        //                     .location.lng);
                                        //             lat = latLng.latitude;
                                        //             long = latLng.longitude;

                                        //             userController
                                        //                 .changeLocation(latLng);
                                        //             // setState(() {});

                                        //             final GeoFirePoint
                                        //                 geoFirePoint =
                                        //                 GeoFirePoint(GeoPoint(
                                        //                     lat, long));

                                        //             FirebaseFirestore.instance
                                        //                 .collection('users')
                                        //                 .doc(userController
                                        //                     .userModel!.userId)
                                        //                 .update({
                                        //               'lat': lat,
                                        //               'geo': geoFirePoint.data,
                                        //               'long': long,
                                        //             });
                                        //             final GoogleMapController
                                        //                 controller =
                                        //                 await _controller
                                        //                     .future;
                                        //             await controller.animateCamera(
                                        //                 CameraUpdate
                                        //                     .newCameraPosition(
                                        //                         CameraPosition(
                                        //               target: LatLng(lat, long),
                                        //               zoom: 16.0,
                                        //             )));

                                        //             Get.close(1);
                                        //           } catch (e) {
                                        //             // Get.close(1);
                                        //           }
                                        //         },

                                        //         initialPosition:
                                        //             LatLng(lat, long),
                                        //         // useCurrentLocation: true,
                                        //         selectInitialPosition: true,
                                        //         resizeToAvoidBottomInset:
                                        //             false, // only works in page mode, less flickery, remove if wrong offsets
                                        //       ),
                                        //     ),
                                        //   );
                                        // },

                                        markers: {
                                          Marker(
                                            markerId: MarkerId('current'),
                                            position: LatLng(lat, long),
                                          ),
                                        },
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(lat, long),
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
                            // Align(
                            //   alignment: Alignment.center,
                            //   child: OutlinedButton(
                            //       onPressed: () {
                            //         Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //             builder: (context) => PlacePicker(
                            //               apiKey: apiKey,
                            //               selectText: 'Pick This Place',
                            //               onTapBack: () {
                            //                 Get.close(1);
                            //               },
                            //               onPlacePicked: (result) async {
                            //                 // Get.dialog(LoadingDialog(),
                            //                 //     barrierDismissible: false);
                            //                 LatLng latLng = LatLng(
                            //                     result.geometry!.location.lat,
                            //                     result.geometry!.location.lng);
                            //                 lat = latLng.latitude;
                            //                 long = latLng.longitude;
                            //                 userController
                            //                     .changeLocation(latLng);
                            //                 setState(() {});

                            //                 final GeoFirePoint geoFirePoint =
                            //                     GeoFirePoint(
                            //                         GeoPoint(lat, long));

                            //                 FirebaseFirestore.instance
                            //                     .collection('users')
                            //                     .doc(userController
                            //                         .userModel!.userId)
                            //                     .update({
                            //                   'lat': lat,
                            //                   'geo': geoFirePoint.data,
                            //                   'long': long,
                            //                 });
                            //                 final GoogleMapController
                            //                     controller =
                            //                     await _controller.future;
                            //                 await controller.animateCamera(
                            //                     CameraUpdate.newCameraPosition(
                            //                         CameraPosition(
                            //                   target: LatLng(lat, long),
                            //                   zoom: 16.0,
                            //                 )));
                            //                 Get.close(1);
                            //               },
                            //               initialPosition: LatLng(lat, long),
                            //               // useCurrentLocation: true,
                            //               selectInitialPosition: true,
                            //               resizeToAvoidBottomInset:
                            //                   false, // only works in page mode, less flickery, remove if wrong offsets
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         backgroundColor: userController.isDark
                            //             ? primaryColor
                            //             : Colors.white,
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(6),
                            //         ),
                            //         minimumSize: Size(Get.width * 0.9, 50),
                            //       ),
                            //       child: Text(
                            //         'Change Location',
                            //         style: TextStyle(
                            //           // color: userController.isDark
                            //           //     ? primaryColor
                            //           //     : Colors.white,
                            //           fontSize: 16,
                            //           fontWeight: FontWeight.w700,
                            //         ),
                            //       )),
                            // ),

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
                      height: 40,
                    ),
                    if (widget.isNew)
                      ElevatedButton(
                          onPressed: () async {
                            // fetchAndUploadVehicleData();
                            if (nameController.text.isEmpty) {
                              Get.showSnackbar(GetSnackBar(
                                message: 'Business name is required!',
                                duration: Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              ));
                              return;
                            }
                            if (businessDescriptionController.text.isEmpty) {
                              Get.showSnackbar(GetSnackBar(
                                message: 'Business details is required!',
                                duration: Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              ));
                              return;
                            }
                            if (phoneNumber.text.isEmpty) {
                              Get.showSnackbar(GetSnackBar(
                                message: 'Contact phone number is required!',
                                duration: Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              ));
                              return;
                            }
                            Get.dialog(LoadingDialog(),
                                barrierDismissible: false);
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userModel.userId)
                                .update({
                              // 'isBusinessSetup': true,
                              'businessInfo':
                                  businessDescriptionController.text.trim(),
                              'website': websiteController.text.trim(),
                              'name': nameController.text.trim(),
                              // 'isBusinessSetup': true,
                              // 'contactInfo': selectedCountry +
                              //     phoneNumber.text
                              //         .replaceAll(RegExp(r'\D'), '')
                              //         .trim(),
                            });
                            Get.close(1);

                            // Get.offAll(
                            //     () => ServiceSetOpeningHours(shopHours: {}));
                            Get.to(() => OtpPage(
                                  phoneNumber: '+' +
                                      phoneNumber.text
                                          .replaceAll(RegExp(r'\D'), '')
                                          .trim(),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
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
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          )),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
