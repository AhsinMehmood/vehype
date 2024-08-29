import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/Widgets/service_your_offer_widget.dart';

import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/garage_model.dart';
import '../Widgets/select_date_and_price.dart';
import 'package:http/http.dart' as http;

import '../Widgets/service_cancelled_request_button_widget.dart';
import '../Widgets/service_completed_request_button_widget.dart';
import '../Widgets/service_inprogress_request_button_widget.dart';
import '../Widgets/service_new_request_button_widget.dart';
import '../Widgets/service_pending_request_button_widget.dart';
import '../Widgets/service_request_cancelled_details_button.dart';
import '../Widgets/undo_ignore_provider.dart';

class ServiceRequestDetails extends StatefulWidget {
  final OffersModel offersModel;
  final OffersReceivedModel? offersReceivedModel;
  final String? chatId;
  const ServiceRequestDetails(
      {super.key,
      required this.offersModel,
      this.offersReceivedModel,
      this.chatId});

  @override
  State<ServiceRequestDetails> createState() => _ServiceRequestDetailsState();
}

class _ServiceRequestDetailsState extends State<ServiceRequestDetails> {
  final ScrollController scrollController = ScrollController();
  double opacity = 0.0;

  final PageController pageController = PageController();
  String address = 'Fetching address';
  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        // Calculate the opacity based on the scroll position
        double offset = scrollController.offset;
        opacity = (offset / 100)
            .clamp(0.0, 1.0); // Adjust the 100 value based on your needs
      });
    });
    getAddressFromLatLng();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  int currentIndex = 0;
  Future<void> getAddressFromLatLng() async {
    double latitude = widget.offersModel.lat;
    double longitude = widget.offersModel.long;
    String apiKey =
        'AIzaSyCGAY89N5yfdqLWM_-Y7g_8A0cRdURYf9E'; // Replace with your Google Maps API key
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['status'] == 'OK' &&
            json['results'] != null &&
            json['results'].isNotEmpty) {
          setState(() {
            address = json['results'][1]['formatted_address'];
          });
        } else {
          setState(() {
            address = 'Address not found';
          });
        }
      } else {
        setState(() {
          address = 'Error retrieving address';
        });
      }
    } catch (e) {
      setState(() {
        address = 'Failed to fetch address';
      });
    }
  }

  bool yourOfferExpanded = false;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: InkWell(
        onTap: () {
          setState(() {
            yourOfferExpanded = false;
          });
        },
        child: StreamBuilder<OffersModel>(
            initialData: widget.offersModel,
            stream: FirebaseFirestore.instance
                .collection('offers')
                .doc(widget.offersModel.offerId)
                .snapshots()
                .map((convert) => OffersModel.fromJson(convert)),
            builder: (context, snapshot) {
              OffersModel offersModel = snapshot.data ?? widget.offersModel;
              return StreamBuilder<OffersReceivedModel>(
                  initialData: widget.offersReceivedModel,
                  stream: FirebaseFirestore.instance
                      .collection('offersReceived')
                      .doc(widget.offersReceivedModel == null
                          ? 'null'
                          : widget.offersReceivedModel!.id)
                      .snapshots()
                      .map((convert) => OffersReceivedModel.fromJson(convert)),
                  builder: (context, snapshot) {
                    OffersReceivedModel? offersReceivedModel = snapshot.data;
                    return StreamBuilder<GarageModel>(
                        stream: FirebaseFirestore.instance
                            .collection('garages')
                            .doc(offersModel.garageId)
                            .snapshots()
                            .map((cc) => GarageModel.fromJson(cc)),
                        builder: (context, snapshot) {
                          GarageModel garageModel = snapshot.data ??
                              GarageModel(
                                  ownerId: 'ownerId',
                                  submodel: '',
                                  title: '',
                                  imageUrl: offersModel.imageOne,
                                  bodyStyle: 'Passenger vehicle',
                                  make: '',
                                  year: '',
                                  model: '',
                                  vin: '',
                                  garageId: offersModel.garageId);
                          return StreamBuilder<UserModel>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(offersModel.ownerId)
                                  .snapshots()
                                  .map((ss) => UserModel.fromJson(ss)),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                UserModel secondUser = snapshot.data!;
                                return Scaffold(
                                  backgroundColor: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                  floatingActionButtonLocation:
                                      FloatingActionButtonLocation.centerDocked,
                                  floatingActionButton: Stack(
                                    children: [
                                      if (offersReceivedModel != null)
                                        Positioned(
                                            bottom:
                                                offersReceivedModel.cancelBy !=
                                                            'provider' &&
                                                        offersReceivedModel
                                                                .ratingTwo ==
                                                            0.0
                                                    ? 80
                                                    : 10,
                                            left: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  yourOfferExpanded =
                                                      !yourOfferExpanded;
                                                });
                                              },
                                              child: ServiceYourOfferWidget(
                                                  offersModel: offersModel,
                                                  ownerModel: secondUser,
                                                  offersReceivedModel:
                                                      offersReceivedModel,
                                                  yourOfferExpanded:
                                                      yourOfferExpanded),
                                            )),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (offersReceivedModel == null)
                                            ServiceNewRequestPageButtonWidget(
                                              offersModel: offersModel,
                                              chatId: widget.chatId,
                                              garageModel: garageModel,
                                            )
                                          else
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              // crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                if (offersReceivedModel
                                                        .status ==
                                                    'Pending')
                                                  ServicePendingPageButtonWidget(
                                                      offersModel: offersModel,
                                                      chatId: widget.chatId,
                                                      garageModel: garageModel,
                                                      offersReceivedModel:
                                                          offersReceivedModel)
                                                else if (offersReceivedModel
                                                        .status ==
                                                    'Upcoming')
                                                  ServiceInprogressRequestPageButtonWidget(
                                                      offersModel: offersModel,
                                                      chatId: widget.chatId,
                                                      garageModel: garageModel,
                                                      offersReceivedModel:
                                                          offersReceivedModel)
                                                else if (offersReceivedModel
                                                        .status ==
                                                    'Completed')
                                                  ServiceCompletedRequestPageButtonWidget(
                                                      offersModel: offersModel,
                                                      chatId: widget.chatId,
                                                      offersReceivedModel:
                                                          offersReceivedModel)
                                                else if (offersReceivedModel
                                                        .status ==
                                                    'Cancelled')
                                                  ServiceRequestCancelledDetailsButton(
                                                      offersModel: offersModel,
                                                      chatId: widget.chatId,
                                                      offersReceivedModel:
                                                          offersReceivedModel)
                                              ],
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                  body: SafeArea(
                                    child: Stack(
                                      children: [
                                        SingleChildScrollView(
                                          controller: scrollController,
                                          child: Column(
                                            children: [
                                              Container(
                                                // color: Colors.red,
                                                width: Get.width,
                                                height: 300,
                                                child: Stack(
                                                  children: [
                                                    PageView.builder(
                                                        itemCount: 1 +
                                                            offersModel
                                                                .images.length,
                                                        controller:
                                                            pageController,
                                                        onPageChanged: (index) {
                                                          setState(() {
                                                            currentIndex =
                                                                index;
                                                          });
                                                        },
                                                        itemBuilder:
                                                            (context, index) {
                                                          if (index == 0) {
                                                            return InkWell(
                                                              onTap: () {
                                                                List images =
                                                                    <dynamic>[
                                                                          garageModel
                                                                              .imageUrl
                                                                        ] +
                                                                        offersModel
                                                                            .images;
                                                                Get.to(() =>
                                                                    FullImagePageView(
                                                                      urls:
                                                                          images,
                                                                      currentIndex:
                                                                          0,
                                                                    ));
                                                              },
                                                              child:
                                                                  ExtendedImage
                                                                      .network(
                                                                garageModel
                                                                    .imageUrl,
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 300,
                                                                width:
                                                                    Get.width,
                                                              ),
                                                            );
                                                          } else {
                                                            String url =
                                                                offersModel
                                                                        .images[
                                                                    index - 1];
                                                            return InkWell(
                                                              onTap: () {
                                                                List images =
                                                                    <dynamic>[
                                                                          garageModel
                                                                              .imageUrl
                                                                        ] +
                                                                        offersModel
                                                                            .images;
                                                                Get.to(() =>
                                                                    FullImagePageView(
                                                                      urls:
                                                                          images,
                                                                      currentIndex:
                                                                          index -
                                                                              1,
                                                                    ));
                                                              },
                                                              child:
                                                                  ExtendedImage
                                                                      .network(
                                                                url,
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 300,
                                                                width:
                                                                    Get.width,
                                                              ),
                                                            );
                                                          }
                                                        }),
                                                    Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 4,
                                                              bottom: 4,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .camera_alt_outlined,
                                                                  size: 15,
                                                                  color:
                                                                      primaryColor,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                  '${currentIndex + 1}/${offersModel.images.length + 1}',
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        primaryColor,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        garageModel.title,
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .location_on_outlined,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Flexible(
                                                                  child: Text(
                                                                    address,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                            formatDate(DateTime
                                                                .parse(offersModel
                                                                    .createdAt)),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        height: 0.5,
                                                        width: Get.width,
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.2)
                                                            : primaryColor
                                                                .withOpacity(
                                                                    0.2),
                                                      ),
                                                      const SizedBox(
                                                        height: 30,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    getServices()
                                                                        .firstWhere((test) =>
                                                                            test.name ==
                                                                            offersModel.issue)
                                                                        .image,
                                                                    color: Colors
                                                                        .blueAccent,
                                                                    height: 28,
                                                                    width: 28,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                        'Issue',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w300,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            3,
                                                                      ),
                                                                      Text(
                                                                        offersModel
                                                                            .issue,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                  // Row(
                                                                  //   mainAxisAlignment: MainAxisAlignment.start,
                                                                  //   children: [

                                                                  //   ],
                                                                  // ),
                                                                ],
                                                              ),
                                                              if (offersModel
                                                                      .additionalService !=
                                                                  '')
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      getAdditionalService()
                                                                          .firstWhere((dd) =>
                                                                              dd.name ==
                                                                              offersModel.additionalService)
                                                                          .icon,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      height:
                                                                          28,
                                                                      width: 28,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          'Additional Service',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              3,
                                                                        ),
                                                                        Text(
                                                                          offersModel
                                                                              .additionalService,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                    // Row(
                                                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                                                    //   children: [

                                                                    //   ],
                                                                    // ),
                                                                  ],
                                                                )
                                                              else
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      size: 28,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 5,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          'Year',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              3,
                                                                        ),
                                                                        Text(
                                                                          garageModel
                                                                              .year,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                    // Row(
                                                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                                                    //   children: [

                                                                    //   ],
                                                                    // ),
                                                                  ],
                                                                ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 15,
                                                          ),
                                                          if (offersModel
                                                                  .additionalService !=
                                                              '')
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .calendar_month,
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  size: 28,
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      'Year',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w300,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 3,
                                                                    ),
                                                                    Text(
                                                                      garageModel
                                                                          .year,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            width: Get.width,
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.2)
                                                                : primaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            width: Get.width,
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.2)
                                                                : primaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                          ),
                                                          const SizedBox(
                                                            height: 30,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Submodel',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              garageModel
                                                                  .submodel,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            width: Get.width,
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.2)
                                                                : primaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Description',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              offersModel.description ==
                                                                      ''
                                                                  ? 'Details will be provided on chat'
                                                                  : offersModel
                                                                      .description,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            width: Get.width,
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.2)
                                                                : primaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Posted by',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 30,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Get.to(() =>
                                                                  SecondUserProfile(
                                                                      userId: secondUser
                                                                          .userId));
                                                            },
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              200),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl:
                                                                        secondUser
                                                                            .profileUrl,
                                                                    height: 75,
                                                                    width: 75,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      secondUser
                                                                          .name,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        RatingBarIndicator(
                                                                          rating:
                                                                              secondUser.rating,
                                                                          itemBuilder: (context, _) =>
                                                                              Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                Colors.amber,
                                                                            size:
                                                                                25,
                                                                          ),
                                                                          itemSize:
                                                                              25,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      'See Profile',
                                                                      style:
                                                                          TextStyle(
                                                                        decoration:
                                                                            TextDecoration.underline,
                                                                        // decorationColor: ,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            width: Get.width,
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.2)
                                                                : primaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              'Location',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .location_on_outlined,
                                                                          size:
                                                                              18,
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            address,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
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
                                                            height: 140,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            width: Get.width,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              child: Stack(
                                                                children: [
                                                                  GoogleMap(
                                                                    markers: {
                                                                      Marker(
                                                                        markerId:
                                                                            MarkerId('current'),
                                                                        position: LatLng(
                                                                            offersModel.lat,
                                                                            offersModel.long),
                                                                      ),
                                                                    },
                                                                    zoomControlsEnabled:
                                                                        false,
                                                                    initialCameraPosition:
                                                                        CameraPosition(
                                                                      target: LatLng(
                                                                          offersModel
                                                                              .lat,
                                                                          offersModel
                                                                              .long),
                                                                      zoom:
                                                                          16.0,
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        MapsLauncher.launchCoordinates(
                                                                            offersModel.lat,
                                                                            offersModel.long);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: Get.width *
                                                                            0.6,
                                                                        height:
                                                                            50,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(4),
                                                                            color: userController.isDark ? primaryColor : Colors.white,
                                                                            border: Border.all(
                                                                              color: userController.isDark ? Colors.white : primaryColor,
                                                                            )),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.location_on_outlined,
                                                                              size: 20,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text(
                                                                              'See Location',
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w900,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Container(
                                                            height: 0.5,
                                                            width: Get.width,
                                                            color: userController
                                                                    .isDark
                                                                ? Colors.white
                                                                    .withOpacity(
                                                                        0.2)
                                                                : primaryColor
                                                                    .withOpacity(
                                                                        0.2),
                                                          ),
                                                          const SizedBox(
                                                            height: 120,
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            child: Container(
                                              color: userController.isDark
                                                  ? primaryColor
                                                      .withOpacity(opacity)
                                                  : Colors.white
                                                      .withOpacity(opacity),
                                              width: Get.width,
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .arrow_back_ios_new,
                                                        color: opacity < 0.5
                                                            ? Colors.white
                                                            : userController
                                                                    .isDark
                                                                ? Colors.white
                                                                : primaryColor,
                                                      )),
                                                  Opacity(
                                                    opacity: opacity,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          garageModel.title,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .visible,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SvgPicture.asset(
                                                                getServices()
                                                                    .firstWhere((element) =>
                                                                        element
                                                                            .name ==
                                                                        offersModel
                                                                            .issue)
                                                                    .image,
                                                                color: userController
                                                                        .isDark
                                                                    ? Colors
                                                                        .white
                                                                    : primaryColor,
                                                                height: 25,
                                                                width: 25),
                                                            const SizedBox(
                                                              width: 3,
                                                            ),
                                                            Text(
                                                              ' ',
                                                              style: TextStyle(
                                                                // color: Colors.black,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              offersModel.issue,
                                                              style: TextStyle(
                                                                // color: Colors.black,

                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        });
                  });
            }),
      ),
    );
  }
}
