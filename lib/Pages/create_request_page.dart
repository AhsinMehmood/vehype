// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/repair_page.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/Widgets/choose_gallery_camera.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import '../const.dart';
import 'add_vehicle.dart';
import 'full_image_view_page.dart';

class CreateRequestPage extends StatefulWidget {
  final OffersModel? offersModel;
  final GarageModel? garageModel;
  const CreateRequestPage(
      {super.key, required this.offersModel, this.garageModel});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final TextEditingController _descriptionController = TextEditingController();
  double lat = 0.0;
  double long = 0.0;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((value) {
      final GarageController garageController =
          Provider.of<GarageController>(context, listen: false);
      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      UserModel userModel = userController.userModel!;
      if (widget.garageModel != null) {
        garageController.selectVehicle(
            '${widget.garageModel!.bodyStyle}, ${widget.garageModel!.make}, ${widget.garageModel!.year}, ${widget.garageModel!.model}',
            widget.garageModel!.imageOne,
            widget.garageModel!.garageId);
      }
      if (widget.offersModel != null) {
        garageController.selectedVehicle = widget.offersModel!.vehicleId;
        garageController.selectedIssues = widget.offersModel!.issues;
        garageController.imageOneUrl = widget.offersModel!.imageOne;
        lat = widget.offersModel!.lat;
        long = widget.offersModel!.long;
        List<RequestImageModel> images = [];
        for (var element in widget.offersModel!.images) {
          images.add(RequestImageModel(
              imageUrl: element,
              isLoading: false,
              progress: 1.0,
              imageFile: null));
        }
        garageController.requestImages = images;
        garageController.additionalService =
            widget.offersModel!.additionalService;
        _descriptionController.text = widget.offersModel!.description;
        garageController.garageId = widget.offersModel!.garageId;
        setState(() {});
      } else {
        getLocations();
      }
    });
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

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
          widget.offersModel == null ? 'Create Request' : 'Update Request',
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
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                      constraints: BoxConstraints(
                        minHeight: Get.height * 0.85,
                        maxHeight: Get.height * 0.85,
                      ),
                      isScrollControlled: true,
                      // showDragHandle: true,
                      builder: (context) {
                        return SelectVehicle();
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
                        'Select Vehicle',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        garageController.selectedVehicle == ''
                            ? 'No Vehicle Selected'
                            : garageController.selectedVehicle,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w600,
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
                        return IssuesPicker();
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
                        'Select Services',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (garageController.selectedIssues.isEmpty)
                        Text(
                          'No Service Selected',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w600,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                        )
                      else
                        SizedBox(
                          height: 70,
                          width: Get.width,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var item
                                    in garageController.selectedIssues)
                                  Card(
                                    color: userController.isDark
                                        ? Colors.blueGrey.shade400
                                        : Colors.white70,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: SvgPicture.asset(
                                              getServices()
                                                  .firstWhere(
                                                      (ss) => ss.name == item)
                                                  .image,
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
                                            width: 5,
                                          ),
                                          Text(
                                            item,
                                            style: TextStyle(
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w500,
                                              // color: changeColor(color: '7B7B7B'),
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
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
                      if (garageController.additionalService == '')
                        Text(
                          'No Additional Service Selected',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                        )
                      else
                        Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: SvgPicture.asset(
                                getAdditionalService()
                                    .firstWhere((ss) =>
                                        ss.name ==
                                        garageController.additionalService)
                                    .icon,
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
                              width: 5,
                            ),
                            Text(
                              garageController.additionalService == ''
                                  ? 'No Additional Service Selected'
                                  : garageController.additionalService,
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w600,
                                // color: changeColor(color: '7B7B7B'),
                                fontSize: 16,
                              ),
                            ),
                          ],
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
                onTap: () {
// ...

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        apiKey: 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                        selectText: 'Pick This Place',
                        onPlacePicked: (result) async {
                          Get.dialog(LoadingDialog(),
                              barrierDismissible: false);
                          LatLng latLng =
                              await getPlaceLatLng(result.placeId ?? '');
                          lat = latLng.latitude;
                          long = latLng.longitude;
                          setState(() {});
                          final GoogleMapController controller =
                              await _controller.future;
                          await controller.animateCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                            target: LatLng(lat, long),
                            zoom: 16.0,
                          )));
                          Get.close(2);
                        },
                        initialPosition: LatLng(lat, long),
                        useCurrentLocation: true,
                        selectInitialPosition: true,
                        resizeToAvoidBottomInset:
                            false, // only works in page mode, less flickery, remove if wrong offsets
                      ),
                    ),
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) {
                  //       return GoogleMapLocationPicker(
                  //         apiKey: 'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                  //         currentLatLng: LatLng(lat, long),
                  //         onNext: (GeocodingResult? result) async {
                  //           if (result != null) {
                  //             setState(() {

                  //             });

                  //           }
                  //         },
                  //         onSuggestionSelected: (Prediction? result) async {
                  //           if (result != null) {
                  //             print(result.description);
                  //             print(result.placeId);
                  //             print(result.structuredFormatting.toString());
                  //             print(result.reference);

                  //             // result.matchedSubstrings.first.
                  //             // setState(() {

                  //             // lat = result
                  //             //     .geometry!.location.lat;
                  //             //   long = result
                  //             //       .result.geometry!.location.lng;
                  //             // });
                  //             final GoogleMapController controller =
                  //                 await _controller.future;
                  //             await controller.animateCamera(
                  //                 CameraUpdate.newCameraPosition(CameraPosition(
                  //               target: LatLng(lat, long),
                  //               zoom: 16.0,
                  //             )));
                  //           }
                  //         },
                  //       );
                  //     },
                  //   ),
                  // );
                },
                child: Card(
                  color: userController.isDark ? Colors.white : Colors.black,
                  child: Column(
                    children: [
                      InkWell(
                        child: SizedBox(
                          width: Get.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 140,
                                width: Get.width,
                                child: lat == 0.0
                                    ? CupertinoActivityIndicator(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                      )
                                    : GoogleMap(
                                        onMapCreated: (contr) {
                                          _controller.complete(contr);
                                        },
                                        onTap: (l) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                apiKey:
                                                    'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                                selectText: 'Pick This Place',
                                                onPlacePicked: (result) async {
                                                  Get.dialog(LoadingDialog(),
                                                      barrierDismissible:
                                                          false);
                                                  LatLng latLng =
                                                      await getPlaceLatLng(
                                                          result.placeId ?? '');
                                                  lat = latLng.latitude;
                                                  long = latLng.longitude;
                                                  setState(() {});
                                                  final GoogleMapController
                                                      controller =
                                                      await _controller.future;
                                                  await controller.animateCamera(
                                                      CameraUpdate
                                                          .newCameraPosition(
                                                              CameraPosition(
                                                    target: LatLng(lat, long),
                                                    zoom: 16.0,
                                                  )));
                                                  Get.close(2);
                                                },
                                                initialPosition:
                                                    LatLng(lat, long),
                                                useCurrentLocation: true,
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
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlacePicker(
                                            apiKey:
                                                'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                            selectText: 'Pick This Place',
                                            onPlacePicked: (result) async {
                                              Get.dialog(LoadingDialog(),
                                                  barrierDismissible: false);
                                              LatLng latLng =
                                                  await getPlaceLatLng(
                                                      result.placeId ?? '');
                                              lat = latLng.latitude;
                                              long = latLng.longitude;
                                              setState(() {});
                                              final GoogleMapController
                                                  controller =
                                                  await _controller.future;
                                              await controller.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                          CameraPosition(
                                                target: LatLng(lat, long),
                                                zoom: 16.0,
                                              )));
                                              Get.close(2);
                                            },
                                            initialPosition: LatLng(lat, long),
                                            useCurrentLocation: true,
                                            selectInitialPosition: true,
                                            resizeToAvoidBottomInset:
                                                false, // only works in page mode, less flickery, remove if wrong offsets
                                          ),
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
                                            ? primaryColor
                                            : Colors.white,
                                        fontSize: 16,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                  color: userController.isDark ? Colors.white : Colors.black,
                  // margin: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      InkWell(
                        child: Container(
                            width: Get.width,
                            height: Get.width * 0.45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              // color: Colors.grey.shade400.withOpacity(0.7),
                            ),
                            child: garageController.requestImages.isEmpty
                                ? InkWell(
                                    onTap: () {
                                      Get.bottomSheet(
                                        ChooseGalleryCamera(
                                          onTapCamera: () {
                                            garageController.selectRequestImage(
                                                ImageSource.camera,
                                                userModel.userId);
                                            Get.close(1);
                                          },
                                          onTapGallery: () {
                                            garageController.selectRequestImage(
                                                ImageSource.gallery,
                                                userModel.userId);
                                            Get.close(1);
                                          },
                                        ),
                                        backgroundColor: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      child: Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 70,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                      ),
                                    ),
                                  )
                                : PageView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        garageController.requestImages.length,
                                    controller:
                                        PageController(viewportFraction: 0.90),
                                    itemBuilder: (context, index) {
                                      // return InkWell(
                                      //   onTap: () {},
                                      //   child: Card(
                                      //     color: userController.isDark
                                      //         ? primaryColor
                                      //         : Colors.white,
                                      //     child: Icon(
                                      //       Icons.add_a_photo_rounded,
                                      //       size: 70,
                                      //       color: userController.isDark
                                      //           ? Colors.white
                                      //           : primaryColor,
                                      //     ),
                                      //   ),
                                      // );
                                      RequestImageModel requestImageModel =
                                          garageController.requestImages[index];
                                      return InkWell(
                                        onTap: () {
                                          Get.bottomSheet(
                                            ChooseGalleryCamera(
                                              onTapCamera: () {
                                                garageController
                                                    .selectRequestImageUpdateSingleImage(
                                                        ImageSource.camera,
                                                        userModel.userId,
                                                        index);
                                                Get.close(1);
                                              },
                                              onTapGallery: () {
                                                garageController
                                                    .selectRequestImageUpdateSingleImage(
                                                        ImageSource.gallery,
                                                        userModel.userId,
                                                        index);
                                                Get.close(1);
                                              },
                                            ),
                                            backgroundColor:
                                                userController.isDark
                                                    ? primaryColor
                                                    : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                          );
                                        },
                                        child: CreateRequestImageWidget(
                                          requestImageModel: requestImageModel,
                                          index: index,
                                        ),
                                      );
                                    })),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            onPressed: garageController.requestImages.length ==
                                    3
                                ? null
                                : () {
                                    Get.bottomSheet(
                                      ChooseGalleryCamera(
                                        onTapCamera: () {
                                          garageController.selectRequestImage(
                                              ImageSource.camera,
                                              userModel.userId);
                                          Get.close(1);
                                        },
                                        onTapGallery: () {
                                          garageController.selectRequestImage(
                                              ImageSource.gallery,
                                              userModel.userId);
                                          Get.close(1);
                                        },
                                      ),
                                      backgroundColor: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                    );
                                  },
                            style: TextButton.styleFrom(
                              backgroundColor: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                              maximumSize: Size(Get.width * 0.6, 50),
                              minimumSize: Size(Get.width * 0.6, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: Text(
                              'Select Media ${garageController.requestImages.length}/3',
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 16,
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w800,
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (garageController.selectedVehicle == '') {
                      toastification.show(
                        context: context,
                        // backgroundColor:
                        //     userController.isDark ? Colors.white : primaryColor,
                        title: Text(
                          'Please select a vehicle to create a request.',
                          style: TextStyle(),
                        ),
                        style: ToastificationStyle.flatColored,
                        type: ToastificationType.error,
                        alignment: Alignment.topRight,
                        autoCloseDuration: Duration(seconds: 3),
                      );
                      return;
                    }
                    if (garageController.selectedIssues.isEmpty) {
                      toastification.show(
                        context: context,
                        // backgroundColor:
                        //     userController.isDark ? Colors.white : primaryColor,
                        title: Text(
                          'Please select a service a to create a request.',
                          style: TextStyle(
                              // color: userController.isDark
                              //     ? primaryColor
                              //     : Colors.white,
                              ),
                        ),
                        style: ToastificationStyle.flatColored,
                        type: ToastificationType.error,
                        alignment: Alignment.topRight,
                        autoCloseDuration: Duration(seconds: 3),
                      );
                      return;
                    }
                    if (garageController.requestImages.isNotEmpty &&
                        garageController.requestImages
                            .every((ss) => ss.isLoading)) {
                      toastification.show(
                        context: context,
                        // backgroundColor:
                        //     userController.isDark ? Colors.white : primaryColor,
                        title: Text(
                          'Images are processing please wait...',
                          style: TextStyle(
                              // color: userController.isDark
                              //     ? primaryColor
                              //     : Colors.white,
                              ),
                        ),
                        style: ToastificationStyle.flatColored,
                        type: ToastificationType.info,
                        alignment: Alignment.topRight,
                        autoCloseDuration: Duration(seconds: 3),
                      );
                      return;
                    }

                    Get.dialog(const LoadingDialog(),
                        barrierDismissible: false);
                    if (widget.offersModel != null) {
                      await garageController.saveRequest(
                          _descriptionController.text,
                          LatLng(lat, long),
                          userModel.userId,
                          widget.offersModel!.offerId,
                          garageController.garageId);
                      // Get.back();
                    } else {
                      String requestId = await garageController.saveRequest(
                          _descriptionController.text,
                          LatLng(lat, long),
                          userModel.userId,
                          null,
                          garageController.garageId);
                      await getUserProviders(requestId,
                          garageController.selectedIssues, userModel);
                      // Get.close(4);
                    }
                    Get.close(2);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      maximumSize: Size(Get.width * 0.8, 55),
                      minimumSize: Size(Get.width * 0.8, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33),
                      )),
                  child: Text(
                    widget.offersModel == null
                        ? 'Create Request'
                        : 'Update Request',
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

  Future getUserProviders(
      String requestId, List issues, UserModel userModel) async {
    List<UserModel> providers = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('accountType', isEqualTo: 'provider')
            .where('services', arrayContainsAny: issues)
            // .where('status', isEqualTo: 'active')
            .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      providers.add(UserModel.fromJson(element));
    }

    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    UserModel userModel = userController.userModel!;
    List<UserModel> filterProviders = userController.filterProviders(
        providers, userModel.lat, userModel.long, 100);
    for (var user in filterProviders) {
      UserController()
          .changeNotiOffers(0, true, user.userId, requestId, user.accountType);
      UserController().addToNotifications(userModel, user.userId, 'request',
          requestId, 'New Request', '${userModel.name} created a new request.');
      print('======================NOTIFICATION ADDED');
    }
    for (UserModel provider in filterProviders) {
      sendNotification(
          provider.userId,
          userModel.name,
          'New Request',
          '${userModel.name} created a new request.',
          requestId,
          'request',
          'messageId');
    }
    print(filterProviders.length);
  }
}

class CreateRequestImageWidget extends StatelessWidget {
  final RequestImageModel requestImageModel;
  final int index;

  const CreateRequestImageWidget(
      {super.key, required this.requestImageModel, required this.index});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (requestImageModel.isLoading)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    requestImageModel.imageFile!,
                    fit: BoxFit.cover,
                    width: Get.width,
                    height: Get.width * 0.42,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: requestImageModel.progress,
                              // backgroundColor: Colors.white,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          else
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ExtendedImage.network(
                    requestImageModel.imageUrl,
                    handleLoadingProgress: true,
                    fit: BoxFit.cover,
                    width: Get.width,
                    height: Get.width * 0.42,
                  ),
                ),
                Positioned(
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                            right: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.white,
                          ),
                          child: IconButton(
                              onPressed: () {
                                garageController.removeRequestImage(index);
                              },
                              color: primaryColor,
                              icon: Icon(
                                Icons.delete_outline,
                              )),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                            right: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.white,
                          ),
                          child: IconButton(
                              onPressed: () {
                                Get.bottomSheet(
                                  ChooseGalleryCamera(
                                    onTapCamera: () {
                                      garageController
                                          .selectRequestImageUpdateSingleImage(
                                              ImageSource.camera,
                                              userModel.userId,
                                              index);
                                      Get.close(1);
                                    },
                                    onTapGallery: () {
                                      garageController
                                          .selectRequestImageUpdateSingleImage(
                                              ImageSource.gallery,
                                              userModel.userId,
                                              index);
                                      Get.close(1);
                                    },
                                  ),
                                  backgroundColor: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                );
                              },
                              color: primaryColor,
                              icon: Icon(
                                Icons.edit,
                              )),
                        ),
                      ],
                    ))
              ],
            )
        ],
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

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: userController.isDark ? primaryColor : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => AddVehicle(
                        garageModel: null,
                        addService: true,
                      ));
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Add New',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<GarageModel>>(
                    stream: FirebaseFirestore.instance
                        .collection('garages')
                        .where('ownerId',
                            isEqualTo: userController.userModel!.userId)
                        .orderBy('createdAt', descending: true)
                        .snapshots()
                        .map((ss) => ss.docs
                            .map((toElement) => GarageModel.fromJson(toElement))
                            .toList()),
                    builder:
                        (context, AsyncSnapshot<List<GarageModel>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      List<GarageModel> vehicles = snapshot.data ?? [];
                      if (vehicles.isEmpty) {
                        return Center(
                          child: Text('No Vehicle'),
                        );
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            for (GarageModel vehicle in vehicles)
                              InkWell(
                                onTap: () {
                                  garageController.selectVehicle(
                                      '${vehicle.bodyStyle}, ${vehicle.make}, ${vehicle.year}, ${vehicle.model}',
                                      vehicle.imageOne,
                                      garageController.garageId);
                                  Get.close(1);
                                },
                                child: Card(
                                  color: userController.isDark
                                      ? Colors.blueGrey.shade700
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (vehicle.imageOne != '')
                                        SizedBox(
                                          width: Get.width,
                                          height: Get.width * 0.35,
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(() => FullImagePageView(
                                                    urls: [vehicle.imageOne],
                                                  ));
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: ExtendedImage.network(
                                                vehicle.imageOne,
                                                width: Get.width * 0.9,
                                                height: Get.width * 0.35,
                                                fit: BoxFit.cover,
                                                cache: true,
                                                // border: Border.all(color: Colors.red, width: 1.0),
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                //cancelToken: cancellationToken,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vehicle.bodyStyle,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              vehicle.make,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              vehicle.year,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              vehicle.model,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    garageController.selectVehicle(
                                                        '${vehicle.bodyStyle}, ${vehicle.make}, ${vehicle.year}, ${vehicle.model}',
                                                        vehicle.imageOne,
                                                        garageController
                                                            .garageId);
                                                    Get.close(1);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(
                                                        Get.width * 0.8, 45),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                  child: Text(
                                                    garageController
                                                                .selectedVehicle ==
                                                            '${vehicle.bodyStyle}, ${vehicle.make}, ${vehicle.year}, ${vehicle.model}'
                                                        ? 'Selected'
                                                        : 'Select',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  )),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      );
                    }),
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
      height: Get.height * 0.35,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (AdditionalServiceModel service in getAdditionalService())
                InkWell(
                  onTap: () {
                    garageController.selectAdditionalService(service.name);
                    Get.close(1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                                borderRadius: BorderRadius.circular(4),
                              ),
                              value: garageController.additionalService ==
                                  service.name,
                              onChanged: (s) {
                                // appProvider.selectPrefs(pref);
                                garageController
                                    .selectAdditionalService(service.name);
                                Get.close(1);
                              }),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        SvgPicture.asset(
                            getAdditionalService()
                                .firstWhere(
                                    (element) => element.name == service.name)
                                .icon,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
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
      height: Get.height * 0.8,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Get.close(1);
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      for (Service service in getServices())
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                garageController.selectIssue(service.name);
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
                                        value: garageController.selectedIssues
                                            .contains(service.name),
                                        onChanged: (s) {
                                          // appProvider.selectPrefs(pref);
                                          garageController
                                              .selectIssue(service.name);
                                        }),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  SvgPicture.asset(service.image,
                                      height: 45,
                                      width: 45,
                                      fit: BoxFit.cover,
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
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
