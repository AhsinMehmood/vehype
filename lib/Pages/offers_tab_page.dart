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
import 'package:vehype/const.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Widgets/loading_dialog.dart';
import 'choose_account_type.dart';
import 'full_image_view_page.dart';
import 'offers_received_details.dart';

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
  @override
  void initState() {
    super.initState();
    if (widget.userModel.isActiveNew == true) {
      Future.delayed(const Duration(seconds: 2)).then((e) {
        UserController().changeNotiOffers(0, false, widget.userModel.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: StreamBuilder<List<OffersModel>>(
          stream: widget.userController.getOffersProvider(widget.userModel),
          builder: (context, AsyncSnapshot<List<OffersModel>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: widget.userController.isDark
                      ? Colors.white
                      : primaryColor,
                ),
              );
            }

            List<OffersModel> rawOffers = snapshot.data ?? [];

            List<OffersModel> filterOffers = rawOffers
                .where((element) =>
                    !element.offersReceived.contains(widget.userModel.userId))
                .toList();
            List<OffersModel> filterIgnore = filterOffers
                .where((element) =>
                    !element.ignoredBy.contains(widget.userModel.userId))
                .toList();
            List<OffersModel> blockedUsers = filterIgnore
                .where((element) =>
                    !widget.userModel.blockedUsers.contains(element.ownerId))
                .toList();
            List<OffersModel> offers = widget.userController.filterOffers(
                blockedUsers, widget.userModel.lat, widget.userModel.long, 100);

            if (offers.isEmpty) {
              return Center(
                child: Text(
                  'No Offers Yet',
                  style: TextStyle(
                    color: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: offers.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  OffersModel offersModel = offers[index];
                  List<String> vehicleInfo = offersModel.vehicleId.split(',');
                  final String vehicleType = vehicleInfo[0].trim();
                  final String vehicleMake = vehicleInfo[1].trim();
                  final String vehicleYear = vehicleInfo[2].trim();
                  final String vehicleModle = vehicleInfo[3].trim();
                  // final PageController imagePageController = PageController();

                  return NewOfferWidget(
                      userController: widget.userController,
                      offersModel: offersModel,
                      vehicleType: vehicleType,
                      vehicleMake: vehicleMake,
                      vehicleYear: vehicleYear,
                      vehicleModle: vehicleModle,
                      userModel: widget.userModel);
                });
          }),
    );
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
      child: InkWell(
        onTap: () async {},
        child: Card(
          color: widget.userController.isDark
              ? Colors.blueGrey.shade700
              : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: VehicleDetailsRequest(
                    userController: userController,
                    vehicleType: vehicleType,
                    vehicleMake: vehicleMake,
                    vehicleYear: vehicleYear,
                    vehicleModle: vehicleModle,
                    offersModel: widget.offersModel),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (widget.userModel.email == 'No email set') {
                        Get.showSnackbar(GetSnackBar(
                          message: 'Login to continue',
                          duration: const Duration(
                            seconds: 3,
                          ),
                          backgroundColor: widget.userController.isDark
                              ? Colors.white
                              : primaryColor,
                          mainButton: TextButton(
                            onPressed: () {
                              Get.to(() => ChooseAccountTypePage());
                              Get.closeCurrentSnackbar();
                            },
                            child: Text(
                              'Login Page',
                              style: TextStyle(
                                color: widget.userController.isDark
                                    ? primaryColor
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ));
                      } else {
                        await FirebaseFirestore.instance
                            .collection('offers')
                            .doc(widget.offersModel.offerId)
                            .update({
                          'ignoredBy':
                              FieldValue.arrayUnion([widget.userModel.userId]),
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: widget.userController.isDark
                            ? Colors.white70
                            : primaryColor.withOpacity(0.3),
                        elevation: 0.0,
                        fixedSize: Size(Get.width * 0.35, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        )),
                    child: Text(
                      'Ignore',
                      style: TextStyle(
                          color: widget.userController.isDark
                              ? primaryColor
                              : primaryColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.userModel.email == 'No email set') {
                        Get.showSnackbar(GetSnackBar(
                          message: 'Login to continue',
                          duration: const Duration(
                            seconds: 3,
                          ),
                          backgroundColor: widget.userController.isDark
                              ? Colors.white
                              : primaryColor,
                          mainButton: TextButton(
                            onPressed: () {
                              Get.to(() => ChooseAccountTypePage());
                              Get.closeCurrentSnackbar();
                            },
                            child: Text(
                              'Login Page',
                              style: TextStyle(
                                color: widget.userController.isDark
                                    ? primaryColor
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ));
                      } else {
                        Get.to(() => OfferReceivedDetails(
                              offersModel: widget.offersModel,
                            ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        fixedSize: Size(Get.width * 0.35, 40),
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        )),
                    child: Text(
                      'Details',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
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
