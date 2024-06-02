// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import '../const.dart';

class CreateRequestPage extends StatefulWidget {
  final OffersModel? offersModel;
  const CreateRequestPage({super.key, required this.offersModel});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((value) {
      final GarageController garageController =
          Provider.of<GarageController>(context, listen: false);
      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      UserModel userModel = userController.userModel!;

      getLocations();
      if (widget.offersModel != null) {
        garageController.selectedVehicle = widget.offersModel!.vehicleId;
        garageController.selectedIssue = widget.offersModel!.issue;
        garageController.imageOneUrl = widget.offersModel!.imageOne;
        garageController.imageTwoUrl = widget.offersModel!.imageTwo;
        garageController.additionalService =
            widget.offersModel!.additionalService;
        _descriptionController.text = widget.offersModel!.description;
        garageController.garageId = widget.offersModel!.garageId;
      }
    });
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  double lat = 0.0;
  double long = 0.0;
  getLocations() async {
    bool serviceEnabled;
    LocationPermission permission;
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

    Position position = await Geolocator.getCurrentPosition();
    lat = position.latitude;
    long = position.longitude;

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
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        centerTitle: true,
        // actions: [
        //   if (widget.offersModel != null)
        //     IconButton(
        //       onPressed: () async {
        //         Get.dialog(LoadingDialog(), barrierDismissible: false);
        //         await FirebaseFirestore.instance
        //             .collection('offers')
        //             .doc(widget.offersModel!.offerId)
        //             .delete();
        //         garageController.disposeController();

        //         Get.close(2);
        //       },
        //       color: userController.isDark ? Colors.white : primaryColor,
        //       icon: Icon(
        //         Icons.delete_outlined,
        //       ),
        //     ),
        // ],
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'Create Request',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // const SizedBox(
              //   height: 40,
              // ),
              // InkWell(
              //   onTap: () {
              //     showModalBottomSheet(
              //         context: context,
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(15),
              //           topRight: Radius.circular(15),
              //         )),
              //         // constraints: BoxConstraints(
              //         //   minHeight: Get.height * 0.7,
              //         //   maxHeight: Get.height * 0.7,
              //         // ),
              //         isScrollControlled: true,
              //         // showDragHandle: true,
              //         builder: (context) {
              //           return SelectVehicle();
              //         }).then((value) {
              //       // editProfileProvider
              //       //     .upadeteUpcomingDestinations(userModel);
              //     });
              //   },
              //   child: SizedBox(
              //     width: Get.width,
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Select Vehicle',
              //           style: TextStyle(
              //             fontFamily: 'Avenir',
              //             fontWeight: FontWeight.w400,
              //             fontSize: 16,
              //             color: userController.isDark
              //                 ? Colors.white
              //                 : primaryColor,
              //           ),
              //         ),
              //         const SizedBox(
              //           height: 10,
              //         ),
              //         Text(
              //           garageController.selectedVehicle == ''
              //               ? 'No Vehicle Selected'
              //               : garageController.selectedVehicle,
              //           style: TextStyle(
              //             fontFamily: 'Avenir',
              //             fontWeight: FontWeight.w400,
              //             // color: changeColor(color: '7B7B7B'),
              //             fontSize: 16,
              //           ),
              //         ),
              //         const SizedBox(
              //           height: 15,
              //         ),
              //         Align(
              //           alignment: Alignment.center,
              //           child: Container(
              //             height: 1,
              //             width: Get.width,
              //             color: changeColor(color: 'D9D9D9'),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 15,
              // ),
              // InkWell(
              //   onTap: () {
              //     showModalBottomSheet(
              //         context: context,
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(15),
              //           topRight: Radius.circular(15),
              //         )),
              //         // constraints: BoxConstraints(
              //         //   minHeight: Get.height * 0.7,
              //         //   maxHeight: Get.height * 0.7,
              //         // ),
              //         isScrollControlled: true,
              //         // showDragHandle: true,
              //         builder: (context) {
              //           return IssuesPicker();
              //         }).then((value) {
              //       // editProfileProvider
              //       //     .upadeteUpcomingDestinations(userModel);
              //     });
              //   },
              //   child: SizedBox(
              //     width: Get.width,
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           'Select Issue',
              //           style: TextStyle(
              //             fontFamily: 'Avenir',
              //             fontWeight: FontWeight.w400,
              //             fontSize: 16,
              //           ),
              //         ),
              //         const SizedBox(
              //           height: 10,
              //         ),
              //         Text(
              //           garageController.selectedIssue == ''
              //               ? 'No Issue Selected'
              //               : garageController.selectedIssue,
              //           style: TextStyle(
              //             fontFamily: 'Avenir',
              //             fontWeight: FontWeight.w400,
              //             // color: changeColor(color: '7B7B7B'),
              //             fontSize: 16,
              //           ),
              //         ),
              //         const SizedBox(
              //           height: 15,
              //         ),
              //         Align(
              //           alignment: Alignment.center,
              //           child: Container(
              //             height: 1,
              //             width: Get.width,
              //             color: changeColor(color: 'D9D9D9'),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                      // constraints: BoxConstraints(
                      //   minHeight: Get.height * 0.7,
                      //   maxHeight: Get.height * 0.7,
                      // ),
                      isScrollControlled: true,
                      // showDragHandle: true,
                      builder: (context) {
                        return AdditionalServicePicker();
                      }).then((value) {
                    // editProfileProvider
                    //     .upadeteUpcomingDestinations(userModel);
                  });
                },
                child: SizedBox(
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Additional Service',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        garageController.additionalService == ''
                            ? 'No Additional Service Selected'
                            : garageController.additionalService,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          // color: changeColor(color: '7B7B7B'),
                          fontSize: 16,
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
              const SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Details',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w400,
                      // color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    controller: _descriptionController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText:
                            'Explain the issue. e.g. Engine is making noise'
                        // counter: const SizedBox.shrink(),
                        ),
                    // initialValue: '',

                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
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
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 1,
                  width: Get.width,
                  color: changeColor(color: 'D9D9D9'),
                ),
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
                        height: 140,
                        width: Get.width,
                        child: lat == 0.0
                            ? CupertinoActivityIndicator()
                            : GoogleMap(
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
                      const SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return GoogleMapLocationPicker(
                                      apiKey:
                                          'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                      currentLatLng: LatLng(lat, long),
                                      onNext: (GeocodingResult? result) async {
                                        if (result != null) {
                                          setState(() {
                                            lat = result.geometry.location.lat;
                                            long = result.geometry.location.lng;
                                          });
                                          final GoogleMapController controller =
                                              await _controller.future;
                                          await controller.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                            target: LatLng(lat, long),
                                            zoom: 16.0,
                                          )));
                                        }
                                      },
                                      onSuggestionSelected:
                                          (Prediction? result) async {
                                        if (result != null) {
                                          // result.matchedSubstrings.first.
                                          // setState(() {

                                          //   lat = result.
                                          //       .geometry!.location.lat;
                                          //   long = result
                                          //       .result.geometry!.location.lng;
                                          // });
                                          final GoogleMapController controller =
                                              await _controller.future;
                                          await controller.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                            target: LatLng(lat, long),
                                            zoom: 16.0,
                                          )));
                                        }
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                                // backgroundColor: userController.isDark
                                //     ? Colors.white
                                //     : primaryColor,
                                // maximumSize: Size(Get.width * 0.8, 60),
                                // minimumSize: Size(Get.width * 0.8, 60),
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(7),
                                // ),
                                ),
                            child: Text(
                              'Pick Location',
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 18,
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w800,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  garageController.selectImage(context, userModel, 1);
                },
                child: Container(
                  width: Get.width * 0.9,
                  height: Get.width * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: garageController.imageTwoUrl == ''
                        ? Colors.grey.shade400.withOpacity(0.7)
                        : null,
                  ),
                  child: garageController.imageTwoLoading
                      ? SizedBox(
                          height: 40,
                          width: 40,
                          child: CupertinoActivityIndicator())
                      : (garageController.imageTwoUrl == ''
                          ? Icon(
                              Icons.add_a_photo_rounded,
                              size: 70,
                              color: Colors.white,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ExtendedImage.network(
                                garageController.imageTwoUrl,
                                handleLoadingProgress: true,
                                fit: BoxFit.cover,
                              ),
                            )),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () {
                      garageController.selectImage(context, userModel, 1);
                    },
                    style: TextButton.styleFrom(
                        // backgroundColor: userController.isDark
                        //     ? Colors.white
                        //     : primaryColor,
                        // maximumSize: Size(Get.width * 0.8, 60),
                        // minimumSize: Size(Get.width * 0.8, 60),
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(7),
                        // ),
                        ),
                    child: Text(
                      'Select Media',
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 18,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w800,
                      ),
                    )),
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: garageController.saveButtonValidation2()
                      ? () async {
                          if (widget.offersModel != null) {
                            garageController.saveRequest(
                                _descriptionController.text,
                                LatLng(lat, long),
                                userModel.userId,
                                widget.offersModel!.offerId,
                                garageController.garageId);
                          } else {
                            garageController.saveRequest(
                                _descriptionController.text,
                                LatLng(lat, long),
                                userModel.userId,
                                null,
                                garageController.garageId);
                            String url =
                                'https://us-central1-vehype-386313.cloudfunctions.net/sendPushNotifications';
                            try {
                              final response = await http.post(
                                Uri.parse(url),
                                headers: {
                                  'Content-Type': 'application/json',
                                },
                                body: json.encode({'name': userModel.name}),
                              );

                              if (response.statusCode == 200) {
                                print('Notification sent successfully');
                              } else {
                                print(
                                    'Failed to send notification: ${response.body}');
                              }
                            } catch (e) {
                              print('Error sending notification: $e');
                            }

                            //  FirebaseFirestore.instance.collection('collectionPath')
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      maximumSize: Size(Get.width * 0.8, 60),
                      minimumSize: Size(Get.width * 0.8, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      )),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      fontSize: 18,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w800,
                    ),
                  )),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectVehicle extends StatelessWidget {
  const SelectVehicle({super.key});

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (GarageModel vehicle in garageController.vehciles)
                InkWell(
                  onTap: () {
                    garageController.selectVehicle(
                        '${vehicle.bodyStyle}, ${vehicle.make}, ${vehicle.year}, ${vehicle.model}',
                        vehicle.imageOne,
                        garageController.garageId);
                    Get.close(1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (vehicle.imageOne != '')
                                SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: ExtendedImage.network(
                                    vehicle.imageOne,
                                    height: 40,
                                    cache: true,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8),
                                    width: 40,
                                  ),
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  '${vehicle.bodyStyle}, ${vehicle.make}, ${vehicle.year}, ${vehicle.model}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w400,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (garageController.selectedVehicle ==
                            '${vehicle.bodyStyle}, ${vehicle.make}, ${vehicle.year}, ${vehicle.model}')
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdditionalServicePicker extends StatelessWidget {
  const AdditionalServicePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      // height: Get.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (String service in [
                'Fix at my place',
                'Pick it up',
              ])
                InkWell(
                  onTap: () {
                    garageController.selectAdditionalService(service);
                    Get.close(1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w400,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (garageController.additionalService == service)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IssuesPicker extends StatelessWidget {
  const IssuesPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (Service vehicle in getServices())
                InkWell(
                  onTap: () {
                    garageController.selectIssue(vehicle.name);
                    Get.close(1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: SvgPicture.asset(
                                  vehicle.image,
                                  height: 40,
                                  // cache: true,
                                  // shape: BoxShape.rectangle,
                                  // borderRadius: BorderRadius.circular(8),
                                  width: 40,
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  vehicle.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w400,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (garageController.selectedIssue == vehicle.name)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(200),
                              color: Colors.green,
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
