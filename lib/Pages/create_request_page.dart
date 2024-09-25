import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/choose_gallery_camera.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import '../const.dart';
import '../google_maps_place_picker.dart';
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

      if (widget.offersModel != null) {
        garageController.selectedVehicle = widget.offersModel!.vehicleId;
        garageController.selectedIssue = widget.offersModel!.issue;
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
        if (widget.garageModel != null) {
          garageController.selectVehicle(widget.garageModel!.title,
              widget.garageModel!.imageUrl, widget.garageModel!.garageId);
          garageController.garageId = widget.garageModel!.garageId;
        } else {
          garageController.selectedVehicle = '';
          garageController.imageOneUrl = '';
          garageController.garageId = '';
        }
        garageController.requestImages = [];
        garageController.additionalService = '';

        garageController.selectedIssue = '';

        setState(() {});

        getLocations();
      }
    });
  }

  final Completer<GoogleMapController> mapController =
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // physics: ScrollPhysics(),
        physics: const ClampingScrollPhysics(),
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
                      showDragHandle: true,
                      builder: (context) {
                        return SelectVehicle();
                      });
                },
                child: SizedBox(
                  width: Get.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          'Select Vehicle*',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      garageController.selectedVehicle == ''
                          ? Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                'Tap to select Vehicle',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  // color: changeColor(color: '7B7B7B'),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ExtendedImage.network(
                                      garageController.imageOneUrl,
                                      height: Get.width * 0.45,
                                      width: Get.width,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: Get.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                          ),
                                          color: Colors.black.withOpacity(0.3)),
                                      padding: const EdgeInsets.only(
                                        left: 5,
                                        right: 10,
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              garageController.selectedVehicle,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                // color: changeColor(color: '7B7B7B'),
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
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
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Select Service*',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (garageController.selectedIssue.isEmpty)
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  width: 1.5,
                                )),
                            child: Center(
                              child: Icon(
                                Icons.question_mark_sharp,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 55,
                            width: 55,
                            child: SvgPicture.asset(
                              getServices()
                                  .firstWhere((ss) =>
                                      ss.name == garageController.selectedIssue)
                                  .image,
                              height: 55,
                              // cache: true,
                              // shape: BoxShape.rectangle,
                              // borderRadius: BorderRadius.circular(8),
                              width: 55,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Additional Service',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (garageController.additionalService.isEmpty)
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  width: 1.5,
                                )),
                            child: Center(
                              child: Icon(
                                Icons.question_mark_sharp,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 55,
                            width: 55,
                            child: SvgPicture.asset(
                              getAdditionalService()
                                  .firstWhere((ss) =>
                                      ss.name ==
                                      garageController.additionalService)
                                  .icon,
                              height: 55,
                              // cache: true,
                              // shape: BoxShape.rectangle,
                              // borderRadius: BorderRadius.circular(8),
                              width: 55,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    cursorColor:
                        userController.isDark ? Colors.white : primaryColor,
                    controller: _descriptionController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            )),
                        hintText: 'Explain the issue...',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        )

                        // counter: const SizedBox.shrink(),
                        ),
                    // initialValue: '',
                    maxLength: 356,

                    textCapitalization: TextCapitalization.sentences,

                    maxLines: 4,
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
                height: 15,
              ),
              CreateRequestImageAddWidget(
                  garageController: garageController,
                  userModel: userModel,
                  userController: userController),
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
                              await mapController.future;
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
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  color: userController.isDark ? Colors.white : Colors.black,
                  child: Column(
                    children: [
                      InkWell(
                        child: SizedBox(
                          width: Get.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 140,
                                width: Get.width,
                                child: lat == 0.0
                                    ? CupertinoActivityIndicator(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: MapForRequestCreate(
                                            mapController: mapController,
                                            onMpCreated: (c) {
                                              mapController.complete(c);
                                            },
                                            function: (l) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlacePicker(
                                                    apiKey:
                                                        'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E',
                                                    selectText:
                                                        'Pick This Place',
                                                    onPlacePicked:
                                                        (result) async {
                                                      Get.dialog(
                                                          LoadingDialog(),
                                                          barrierDismissible:
                                                              false);
                                                      LatLng latLng =
                                                          await getPlaceLatLng(
                                                              result.placeId ??
                                                                  '');
                                                      lat = latLng.latitude;
                                                      long = latLng.longitude;
                                                      setState(() {});
                                                      final GoogleMapController
                                                          controller =
                                                          await mapController
                                                              .future;
                                                      await controller.animateCamera(
                                                          CameraUpdate
                                                              .newCameraPosition(
                                                                  CameraPosition(
                                                        target:
                                                            LatLng(lat, long),
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
                                            lat: lat,
                                            long: long),
                                      ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                    onTap: () {
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
                                                  await mapController.future;
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
                                    child: Text(
                                      'Pick a Location',
                                      style: TextStyle(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
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
                    if (garageController.selectedIssue.isEmpty) {
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
                    if (garageController.requestImages
                        .any((ss) => ss.isLoading)) {
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
                      await sendNotificationOnRequestUpdate(
                          widget.offersModel!.offerId,
                          garageController.selectedIssue,
                          userModel);
                      Get.back();
                      Get.back();
                    } else {
                      QuerySnapshot<Map<String, dynamic>> snapshot =
                          await FirebaseFirestore.instance
                              .collection('offers')
                              .where('garageId',
                                  isEqualTo: garageController.garageId)
                              .where('status',
                                  whereIn: ['active', 'inProgress'])

                              // .where('issue',
                              //     isEqualTo: garageController.selectedIssue)
                              .get();
                      List<OffersModel> offers = [];
                      for (QueryDocumentSnapshot<
                          Map<String, dynamic>> documentsnap in snapshot.docs) {
                        offers.add(OffersModel.fromJson(documentsnap));
                      }

                      List<OffersModel> filterByVehicle = offers
                          .where((offer) =>
                              offer.garageId == garageController.garageId)
                          .toList();
                      List<OffersModel> filterByService = filterByVehicle
                          .where((offer) =>
                              offer.issue == garageController.selectedIssue)
                          .toList();
                      bool anyDiffirence =
                          filterByService.any((offer) => areLocationsDifferent(
                                lat,
                                long,
                                offer.lat,
                                offer.long,
                                1,
                              ));

                      if (anyDiffirence) {
                        Get.close(1);

                        toastification.show(
                          context: context,
                          title: Text('Duplicate Request Found!'),
                          style: ToastificationStyle.minimal,
                          showProgressBar: false,
                          type: ToastificationType.error,
                          alignment: Alignment.topCenter,
                          autoCloseDuration: Duration(seconds: 3),
                        );
                      } else {
                        String requestId = await garageController.saveRequest(
                            _descriptionController.text,
                            LatLng(lat, long),
                            userModel.userId,
                            null,
                            garageController.garageId);
                        await getUserProviders(requestId,
                            garageController.selectedIssue, userModel);
                        Get.back();
                        Get.back();
                      }

                      // Get.close(4);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      elevation: 0.0,
                      maximumSize: Size(Get.width * 0.9, 50),
                      minimumSize: Size(Get.width * 0.9, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      )),
                  child: Text(
                    widget.offersModel == null ? 'Create' : 'Update',
                    style: TextStyle(
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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

  Future sendNotificationOnRequestUpdate(
      String requestId, String issue, UserModel userModel) async {
    List<UserModel> providers = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('accountType', isEqualTo: 'provider')
            .where('services', arrayContains: issue)
            // .where('status', isEqualTo: 'active')
            .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      providers.add(UserModel.fromJson(element));
    }

    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    UserModel userModel = userController.userModel!;
    List<UserModel> blockedUsers = providers
        .where((element) => !userModel.blockedUsers.contains(element.userId))
        .toList();
    List<UserModel> filterIgnore = blockedUsers
        .where((user) => !widget.offersModel!.ignoredBy.contains(user.userId))
        .toList();
    List<UserModel> filterProviders = userController.filterProviders(
        filterIgnore, userModel.lat, userModel.long, 100);
    List addNotifications = [];
    List<String> userIds = [];
    for (var element in filterProviders) {
      userIds.add(element.userId);
    }
    NotificationController().sendNotification(
        userIds: userIds,
        offerId: requestId,
        requestId: '',
        title: 'Request Changes Notification',
        subtitle:
            '${userModel.name} has updated his request. Click to see the latest changes.');
    for (UserModel provider in filterProviders) {
      addNotifications.add({
        'checkById': provider.userId,
        'isRead': false,
        'title': '${userModel.name} has updated his request.',
        'subtitle':
            '${userModel.name} has updated his request. Click to see the latest changes.',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'senderId': userModel.userId,
      });
    }
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(requestId)
        .update({
      'checkByList': addNotifications,
    });
  }

  Future getUserProviders(
      String requestId, String issue, UserModel userModel) async {
    List<UserModel> providers = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('accountType', isEqualTo: 'provider')
            .where('services', arrayContains: issue)
            // .where('status', isEqualTo: 'active')
            .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> element in snapshot.docs) {
      providers.add(UserModel.fromJson(element));
    }

    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    UserModel userModel = userController.userModel!;
    List<UserModel> blockedUsers = providers
        .where((element) => !userModel.blockedUsers.contains(element.userId))
        .toList();
    List<UserModel> filterProviders = userController.filterProviders(
        blockedUsers, userModel.lat, userModel.long, 100);
    List<String> userIds = [];
    for (var element in filterProviders) {
      userIds.add(element.userId);
    }
    List addNotifications = [];
    NotificationController().sendNotification(
        offerId: requestId,
        userIds: userIds,
        requestId: '',
        title: 'Opportunity Alert: New Request',
        subtitle:
            'A nearby vehicle owner has submitted a new request. Click here to see more and respond quickly.');
    for (UserModel provider in filterProviders) {
      addNotifications.add({
        'checkById': provider.userId,
        'isRead': false,
        'title': 'Opportunity Alert: New Request',
        'subtitle':
            'Opportunity Alert: New Request. Tap to see more and respond quickly.',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'senderId': userModel.userId,
      });
    }
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(requestId)
        .update({
      'checkByList': addNotifications,
    });
  }
}

class MapForRequestCreate extends StatelessWidget {
  const MapForRequestCreate({
    super.key,
    required this.lat,
    required this.long,
    required this.function,
    required this.mapController,
    required this.onMpCreated,
  });

  final double lat;
  final Completer<GoogleMapController> mapController;
  final double long;
  final void Function(GoogleMapController) onMpCreated;
  final void Function(LatLng) function;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMpCreated,
      onTap: function,
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
    );
  }
}

class CreateRequestImageAddWidget extends StatelessWidget {
  const CreateRequestImageAddWidget({
    super.key,
    required this.garageController,
    required this.userModel,
    required this.userController,
  });

  final GarageController garageController;
  final UserModel userModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Add Photos',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  ChooseGalleryCamera(
                    onTapCamera: () {
                      garageController.selectRequestImageUpdateSingleImage(
                          ImageSource.camera, userModel.userId, 0);
                      Get.close(1);
                    },
                    onTapGallery: () {
                      garageController.selectRequestImageUpdateSingleImage(
                          ImageSource.gallery, userModel.userId, 0);
                      Get.close(1);
                    },
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: garageController.requestImages.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: Get.width * 0.15,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: garageController.requestImages[0].imageFile ==
                                null
                            ? ExtendedImage.network(
                                garageController.requestImages[0].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : ExtendedImage.file(
                                garageController.requestImages[0].imageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  ChooseGalleryCamera(
                    onTapCamera: () {
                      garageController.selectRequestImageUpdateSingleImage(
                          ImageSource.camera, userModel.userId, 1);
                      Get.close(1);
                    },
                    onTapGallery: () {
                      garageController.selectRequestImageUpdateSingleImage(
                          ImageSource.gallery, userModel.userId, 1);
                      Get.close(1);
                    },
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: garageController.requestImages.elementAtOrNull(1) == null
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: Get.width * 0.15,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: garageController.requestImages[1].imageFile ==
                                null
                            ? ExtendedImage.network(
                                garageController.requestImages[1].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : ExtendedImage.file(
                                garageController.requestImages[1].imageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  ChooseGalleryCamera(
                    onTapCamera: () {
                      garageController.selectRequestImageUpdateSingleImage(
                          ImageSource.camera, userModel.userId, 2);
                      Get.close(1);
                    },
                    onTapGallery: () {
                      garageController.selectRequestImageUpdateSingleImage(
                          ImageSource.gallery, userModel.userId, 2);
                      Get.close(1);
                    },
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: garageController.requestImages.elementAtOrNull(2) == null
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: Get.width * 0.15,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: garageController.requestImages[2].imageFile ==
                                null
                            ? ExtendedImage.network(
                                garageController.requestImages[2].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : ExtendedImage.file(
                                garageController.requestImages[2].imageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        // InkWell(
        //   child: Container(
        //       width: Get.width,
        //       height: Get.width * 0.45,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(4),
        //         // color: Colors.grey.shade400.withOpacity(0.7),
        //       ),
        //       child: garageController.requestImages.isEmpty
        //           ? InkWell(
        //               onTap: () {
        //                 Get.bottomSheet(
        //                   ChooseGalleryCamera(
        //                     onTapCamera: () {
        //                       garageController.selectRequestImage(
        //                           ImageSource.camera, userModel.userId);
        //                       Get.close(1);
        //                     },
        //                     onTapGallery: () {
        //                       garageController.selectRequestImage(
        //                           ImageSource.gallery, userModel.userId);
        //                       Get.close(1);
        //                     },
        //                   ),
        //                   backgroundColor: userController.isDark
        //                       ? primaryColor
        //                       : Colors.white,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.only(
        //                       topLeft: Radius.circular(20),
        //                       topRight: Radius.circular(20),
        //                     ),
        //                   ),
        //                 );
        //               },
        //               child: Card(
        //                 color:
        //                     userController.isDark ? primaryColor : Colors.white,
        //                 child: Icon(
        //                   Icons.add_a_photo_rounded,
        //                   size: 70,
        //                   color: userController.isDark
        //                       ? Colors.white
        //                       : primaryColor,
        //                 ),
        //               ),
        //             )
        //           : PageView.builder(
        //               scrollDirection: Axis.horizontal,
        //               itemCount: garageController.requestImages.length,
        //               controller: PageController(viewportFraction: 0.50),
        //               itemBuilder: (context, index) {
        //                 RequestImageModel requestImageModel =
        //                     garageController.requestImages[index];
        //                 return InkWell(
        //                   onTap: () {
        //                     Get.bottomSheet(
        //                       ChooseGalleryCamera(
        //                         onTapCamera: () {
        //                           garageController
        //                               .selectRequestImageUpdateSingleImage(
        //                                   ImageSource.camera,
        //                                   userModel.userId,
        //                                   index);
        //                           Get.close(1);
        //                         },
        //                         onTapGallery: () {
        //                           garageController
        //                               .selectRequestImageUpdateSingleImage(
        //                                   ImageSource.gallery,
        //                                   userModel.userId,
        //                                   index);
        //                           Get.close(1);
        //                         },
        //                       ),
        //                       backgroundColor: userController.isDark
        //                           ? primaryColor
        //                           : Colors.white,
        //                       shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.only(
        //                           topLeft: Radius.circular(20),
        //                           topRight: Radius.circular(20),
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                   child: CreateRequestImageWidget(
        //                     requestImageModel: requestImageModel,
        //                     index: index,
        //                   ),
        //                 );
        //               })),
        // ),

        // const SizedBox(
        //   height: 10,
        // ),
        // Align(
        //   alignment: Alignment.center,
        //   child: ElevatedButton(
        //       onPressed: garageController.requestImages.length == 3
        //           ? null
        //           : () {
        //               Get.bottomSheet(
        //                 ChooseGalleryCamera(
        //                   onTapCamera: () {
        //                     garageController.selectRequestImage(
        //                         ImageSource.camera, userModel.userId);
        //                     Get.close(1);
        //                   },
        //                   onTapGallery: () {
        //                     garageController.selectRequestImage(
        //                         ImageSource.gallery, userModel.userId);
        //                     Get.close(1);
        //                   },
        //                 ),
        //                 backgroundColor:
        //                     userController.isDark ? primaryColor : Colors.white,
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.only(
        //                     topLeft: Radius.circular(20),
        //                     topRight: Radius.circular(20),
        //                   ),
        //                 ),
        //               );
        //             },
        //       style: TextButton.styleFrom(
        //         backgroundColor:
        //             userController.isDark ? primaryColor : Colors.white,
        //         maximumSize: Size(Get.width * 0.6, 50),
        //         minimumSize: Size(Get.width * 0.6, 50),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(7),
        //         ),
        //       ),
        //       child: Text(
        //         'Select Media ${garageController.requestImages.length}/3',
        //         style: TextStyle(
        //           color: userController.isDark ? Colors.white : primaryColor,
        //           fontSize: 16,
        //           fontFamily: 'Avenir',
        //           fontWeight: FontWeight.w800,
        //         ),
        //       )),
        // ),
        // const SizedBox(
        //   height: 10,
        // ),
      ],
    );
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
                    width: Get.width * 0.30,
                    height: Get.width * 0.30,
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
                    width: Get.width * 0.30,
                    height: Get.width * 0.30,
                  ),
                ),
                Positioned(
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: InkWell(
                                onTap: () {
                                  garageController.removeRequestImage(index);
                                },
                                child: Icon(
                                  Icons.delete_outline,
                                  color: primaryColor,
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.white,
                          ),
                          child: InkWell(
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
                              child: Icon(
                                Icons.edit,
                                color: primaryColor,
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

    return Container(
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
                                garageController.selectVehicle(vehicle.title,
                                    vehicle.imageUrl, vehicle.garageId);

                                Get.close(1);
                              },
                              child: Card(
                                color: userController.isDark
                                    ? Colors.blueGrey.shade700
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: Get.width,
                                      height: Get.width * 0.35,
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(() => FullImagePageView(
                                                urls: [vehicle.imageUrl],
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: ExtendedImage.network(
                                            vehicle.imageUrl,
                                            width: Get.width * 0.9,
                                            height: Get.width * 0.35,
                                            fit: BoxFit.cover,
                                            cache: true,
                                            // border: Border.all(color: Colors.red, width: 1.0),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6.0)),
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
                                                  garageController
                                                      .selectVehicle(
                                                          vehicle.title,
                                                          vehicle.imageUrl,
                                                          vehicle.garageId);
                                                  Get.close(1);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize:
                                                      Size(Get.width * 0.9, 50),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  backgroundColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                ),
                                                child: Text(
                                                  garageController
                                                              .selectedVehicle ==
                                                          vehicle.title
                                                      ? 'Selected'
                                                      : 'Select',
                                                  style: TextStyle(
                                                    color: userController.isDark
                                                        ? primaryColor
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
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
                                Get.close(1);
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
                                        value: garageController.selectedIssue ==
                                            service.name,
                                        onChanged: (s) {
                                          // appProvider.selectPrefs(pref);
                                          garageController
                                              .selectIssue(service.name);
                                          Get.close(1);
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
