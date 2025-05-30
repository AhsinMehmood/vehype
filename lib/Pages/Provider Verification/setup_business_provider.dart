// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_progress/flutter_animated_progress.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/user_controller.dart';

import 'package:vehype/const.dart';

import '../../Models/user_model.dart';
import '../../google_maps_place_picker.dart';
import '../../providers/firebase_storage_provider.dart';
import '../Auth/verify_otp_page.dart';
import '../crop_image_page.dart';

class SetupBusinessProvider extends StatefulWidget {
  final PlaceDetails? placeDetails;
  const SetupBusinessProvider({super.key, required this.placeDetails});

  @override
  _SetupBusinessProviderState createState() => _SetupBusinessProviderState();
}

class _SetupBusinessProviderState extends State<SetupBusinessProvider> {
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
      final UserController userController =
          Provider.of<UserController>(context, listen: false);

      UserModel userModel = userController.userModel!;
      phoneNumber = TextEditingController(
          text: widget.placeDetails!.internationalPhoneNumber);
      nameController = TextEditingController(text: widget.placeDetails!.name);
      websiteController =
          TextEditingController(text: widget.placeDetails!.website);
      lat = widget.placeDetails!.geometry!.location.lat;
      long = widget.placeDetails!.geometry!.location.lng;
      fileUrl = widget.placeDetails?.icon ?? userModel.profileUrl;
    } else {
      getSelectedCountry();
    }
  }

  getSelectedCountry() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    UserModel userModel = userController.userModel!;
    nameController = TextEditingController(text: userModel.name);
    lat = userModel.lat;
    long = userModel.long;
    fileUrl = widget.placeDetails?.icon ?? userModel.profileUrl;
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

  String fileUrl = '';
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final FirebaseStorageProvider firebaseStorageProvider =
        Provider.of<FirebaseStorageProvider>(context);
    UserModel userModel = userController.userModel!;

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
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      XFile? selectedFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (selectedFile != null) {
                        File file = File(selectedFile.path);
                        Get.to(() => CropImagePage(
                            imageData: file,
                            imageField: '',
                            onCropped: (p0) async {
                              File fromBytes = await file.writeAsBytes(p0);

                              setState(() => isUploading = true);
                              fileUrl = await firebaseStorageProvider
                                      .uploadMedia(fromBytes, true) ??
                                  userModel.profileUrl;
                              // await FirebaseFirestore.instance
                              //     .collection('users')
                              //     .doc(userModel.userId)
                              //     .update({'profileUrl': fileUrl});
                              setState(() {
                                // imageUrl = fileUrl;
                                isUploading = false;
                              });
                              firebaseStorageProvider.resetUploadState();
                            }));
                      }
                    },
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: isUploading
                          ? Center(
                              child: Stack(
                                alignment: Alignment
                                    .center, // Ensures everything inside is centered
                                children: [
                                  SizedBox(
                                    height: 90,
                                    width: 90,
                                    child: AnimatedCircularProgressIndicator(
                                      value: firebaseStorageProvider
                                                  .uploadProgress ==
                                              0.0
                                          ? 0.02
                                          : firebaseStorageProvider
                                              .uploadProgress,
                                      strokeWidth: 6,
                                      backgroundColor:
                                          Colors.green.withOpacity(0.2),
                                      color: const Color.fromARGB(
                                          255, 57, 167, 61),
                                      animationDuration: Duration(
                                        milliseconds: 400,
                                      ),
                                      // label: 'Dart',
                                    ),
                                  ),
                                  Text(
                                    '${(firebaseStorageProvider.uploadProgress * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            )
                          : Stack(
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
                                    imageUrl: fileUrl,
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
                        enabled: widget.placeDetails == null,
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
                        'Business Details',
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

                        maxLines: 3,
                        decoration: InputDecoration(
                            hintText: 'Describe your business',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Colors.blueGrey)
                            // counter: const SizedBox.shrink(),
                            ),

                        // textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          // color: changeColor(color: '7B7B7B'),
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                              controller: phoneNumber,
                              enabled: widget.placeDetails == null,

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
                        'Business Website',
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
                        enabled: widget.placeDetails == null,

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
                          FilteringTextInputFormatter.allow(RegExp(
                              r'[a-zA-Z0-9./:_-]')), // Allows URL characters
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
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: GoogleMap(
                                      onTap: widget.placeDetails != null
                                          ? null
                                          : (l) async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlacePicker(
                                                    apiKey:
                                                        'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                                    selectText:
                                                        'Pick This Place',
                                                    onTapBack: () {
                                                      Get.close(1);
                                                    },
                                                    onPlacePicked:
                                                        (result) async {
                                                      try {
                                                        LatLng latLng = LatLng(
                                                            result.geometry!
                                                                .location.lat,
                                                            result.geometry!
                                                                .location.lng);

                                                        lat = latLng.latitude;
                                                        long = latLng.longitude;

                                                        final GoogleMapController
                                                            controller =
                                                            await _controller
                                                                .future;
                                                        await controller.animateCamera(
                                                            CameraUpdate
                                                                .newCameraPosition(
                                                                    CameraPosition(
                                                          target:
                                                              LatLng(lat, long),
                                                          zoom: 16.0,
                                                        )));
                                                        setState(() {});

                                                        Get.close(1);
                                                      } catch (e) {
                                                        Get.close(1);
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
                                      onMapCreated: (contr) {
                                        _controller.complete(contr);
                                      },
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
                                if (widget.placeDetails == null)
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey:
                                                    'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
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

                                                    setState(() {});

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
                                                    setState(() {});

                                                    Get.close(1);
                                                  } catch (e) {
                                                    Get.close(1);
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
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          minimumSize:
                                              Size(Get.width * 0.9, 50),
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
                              // Get.dialog(LoadingDialog(),
                              //     barrierDismissible: false);
                              SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              String? userId =
                                  sharedPreferences.getString('userId');
                              if (userId != null) {
                                Get.to(() => OtpPage(
                                      isVerified: widget.placeDetails != null,
                                      businessInfo:
                                          businessDescriptionController.text
                                              .trim(),
                                      profilePhotoUrl: fileUrl,
                                      name: nameController.text.trim(),
                                      lat: lat,
                                      long: long,
                                      phoneNumber: widget.placeDetails == null
                                          ? selectedCountry +
                                              phoneNumber.text
                                                  .trim()
                                                  .replaceAll(' ', '')
                                                  .replaceAll('(', '')
                                                  .replaceAll(')', '')
                                          : widget.placeDetails!
                                              .internationalPhoneNumber!
                                              .trim()
                                              .replaceAll(' ', ''),
                                    ));
                              }
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
        ));
  }
}
