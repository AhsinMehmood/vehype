// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/requests_owner_short_widget.dart';
import 'package:vehype/const.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Widgets/loading_dialog.dart';
import '../Widgets/request_provider_short_widget.dart';
import 'choose_account_type.dart';
import 'full_image_view_page.dart';
import 'offers_received_details.dart';

class IgnoredOffers extends StatefulWidget {
  const IgnoredOffers({
    super.key,
    required this.userController,
    required this.userModel,
  });

  final UserController userController;
  final UserModel userModel;

  @override
  State<IgnoredOffers> createState() => _IgnoredOffersState();
}

class _IgnoredOffersState extends State<IgnoredOffers> {
  List selectedServices = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return StreamBuilder<List<OffersModel>>(
        stream: userController.getOffersProvider(userModel),
        builder: (context, AsyncSnapshot<List<OffersModel>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            );
          }

          // Retrieve raw offers from the snapshot or initialize an empty list if null
          List<OffersModel> rawOffers = snapshot.data ?? [];

// Filter offers based on user criteria
          List<OffersModel> filteredOffers = rawOffers
              .where((offer) => offer.ignoredBy.contains(userModel.userId))
              .toList();
          List<OffersModel> offers = filteredOffers;

          if (offers.isEmpty) {
            return Center(
              child: Text(
                'No Ignored Offers Yet!',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
              itemCount: offers.length,
              shrinkWrap: true,
              padding:
                  const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
              itemBuilder: (context, index) {
                OffersModel offersModel = offers[index];

                return RequestsProviderShortWidgetIgnored(
                  offersModel: offersModel,
                );
              });
        });
  }
}

class NewOffers extends StatefulWidget {
  const NewOffers({
    super.key,
    required this.userController,
    required this.userModel,
  });

  final UserController userController;
  final UserModel userModel;

  @override
  State<NewOffers> createState() => _NewOffersState();
}

class _NewOffersState extends State<NewOffers> {
  List selectedServices = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return StreamBuilder<List<OffersModel>>(
        stream: userController.getOffersProvider(userModel),
        builder: (context, AsyncSnapshot<List<OffersModel>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            );
          }

          // Retrieve raw offers from the snapshot or initialize an empty list if null
          List<OffersModel> rawOffers = snapshot.data ?? [];

// Filter offers based on user criteria
          List<OffersModel> filteredOffers = rawOffers
              .where(
                  (offer) => !offer.offersReceived.contains(userModel.userId))
              .where((offer) => !offer.ignoredBy.contains(userModel.userId))
              .where((offer) => !userModel.blockedUsers.contains(offer.ownerId))
              .where((offer) => userModel.services.contains(offer.issue))
              .toList();
          List<OffersModel> offers = userModel.lat == 0.0
              ? filteredOffers
              : userController.filterOffers(
                  filteredOffers, userModel.lat, userModel.long, 50);
          if (userModel.services.isEmpty) {
            UserController().changeNotiOffers(0, false, widget.userModel.userId,
                'widget.offersModel.offerId', widget.userModel.accountType);
            return Scaffold(
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              floatingActionButton: selectedServices.isEmpty
                  ? null
                  : ElevatedButton(
                      onPressed: () async {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(userModel.userId)
                            .update({
                          'services': FieldValue.arrayUnion(selectedServices)
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          maximumSize: Size(Get.width * 0.8, 55),
                          minimumSize: Size(Get.width * 0.8, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          fontSize: 20,
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w800,
                        ),
                      )),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Choose the services you offer:',
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () {
                          final List<Service> services = getServices();
                          List servicesToUpdate = [];
                          for (var element in services) {
                            servicesToUpdate.add(element.name);
                          }
                          if (selectedServices.length == getServices().length) {
                            selectedServices = [];
                          } else {
                            selectedServices = servicesToUpdate;
                          }
                          setState(() {});
                        },
                        child: Text(
                          selectedServices.length == getServices().length
                              ? 'Clear'.toUpperCase()
                              : 'Select All'.toUpperCase(),
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: getServices().length,
                        padding: const EdgeInsets.only(
                          bottom: 70,
                          right: 10,
                          left: 10,
                          top: 0,
                        ),
                        itemBuilder: (context, index) {
                          Service service = getServices()[index];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (selectedServices
                                        .contains(service.name)) {
                                      selectedServices.remove(service.name);
                                    } else {
                                      selectedServices.add(service.name);
                                    }
                                  });
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
                                          value: selectedServices
                                              .contains(service.name),
                                          onChanged: (s) {
                                            // appProvider.selectPrefs(pref);
                                            setState(() {
                                              if (selectedServices
                                                  .contains(service.name)) {
                                                selectedServices
                                                    .remove(service.name);
                                              } else {
                                                selectedServices
                                                    .add(service.name);
                                              }
                                            });
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
                                height: 10,
                              ),
                            ],
                          );
                        }),
                  )
                ],
              ),
            );
          }

          if (offers.isEmpty) {
            UserController().changeNotiOffers(0, false, widget.userModel.userId,
                'widget.offersModel.offerId', widget.userModel.accountType);
            return Center(
              child: Text(
                'No Requests Yet',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
              itemCount: offers.length,
              shrinkWrap: true,
              padding:
                  const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
              itemBuilder: (context, index) {
                OffersModel offersModel = offers[index];
                List<String> vehicleInfo = offersModel.vehicleId.split(',');
                final String vehicleType = vehicleInfo[0].trim();
                final String vehicleMake = vehicleInfo[1].trim();
                final String vehicleYear = vehicleInfo[2].trim();
                final String vehicleModle = vehicleInfo[3].trim();
                // final PageController imagePageController = PageController();

                return NewOfferWidget(
                    userController: userController,
                    offersModel: offersModel,
                    vehicleType: vehicleType,
                    vehicleMake: vehicleMake,
                    vehicleYear: vehicleYear,
                    vehicleModle: vehicleModle,
                    userModel: userModel);
              });
        });
  }
}

class NewOfferWidget extends StatefulWidget {
  const NewOfferWidget({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.vehicleType,
    required this.vehicleMake,
    required this.vehicleYear,
    required this.vehicleModle,
    required this.userModel,
  });

  final UserController userController;
  final OffersModel offersModel;
  final String vehicleType;
  final String vehicleMake;
  final String vehicleYear;
  final String vehicleModle;
  final UserModel userModel;

  @override
  State<NewOfferWidget> createState() => _NewOfferWidgetState();
}

class _NewOfferWidgetState extends State<NewOfferWidget> {
  PageController pageController = PageController();
  int currentInde = 0;
  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(widget.offersModel.createdAt);
    final UserController userController = Provider.of<UserController>(context);

    List<String> vehicleInfo = widget.offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0];
    final String vehicleMake = vehicleInfo[1];
    final String vehicleYear = vehicleInfo[2];
    final String vehicleModle = vehicleInfo[3];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RequestsProviderShortWidgetActive(
            title: '',
            offersModel: widget.offersModel,
            isActive: true,
          ),
        ],
      ),
    );
  }
}

class SelectYourServices extends StatelessWidget {
  const SelectYourServices({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    // height: Get.height * 0.06,
                    ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 40,
                    right: 10,
                  ),
                  child: Text(
                    'Welcome to VEHYPE',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: userController.isDark
                            ? Colors.white
                            : primaryColor),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                    top: 20,
                    bottom: 20,
                    right: 10,
                  ),
                  child: Text(
                    'Select your services to start receiving offers.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                        color: userController.isDark
                            ? Colors.white
                            : primaryColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 10, right: 12, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (Service service in getServices())
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    userController.selectServices(service.name);
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
                                                .selectedServices
                                                .contains(service.name),
                                            onChanged: (s) {
                                              // appProvider.selectPrefs(pref);
                                              userController
                                                  .selectServices(service.name);
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
                    SizedBox(
                      height: Get.height * 0.1,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: userController.selectedServices.isEmpty
          ? null
          : ElevatedButton(
              onPressed: userController.selectedServices.isEmpty
                  ? null
                  : () async {
                      Get.dialog(const LoadingDialog(),
                          barrierDismissible: false);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userModel.userId)
                          .update({
                        'services': FieldValue.arrayUnion(
                            userController.selectedServices),
                      });

                      Get.close(1);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  maximumSize: Size(Get.width * 0.8, 60),
                  minimumSize: Size(Get.width * 0.8, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  )),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: userController.isDark ? primaryColor : Colors.white,
                  fontSize: 20,
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w800,
                ),
              )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
