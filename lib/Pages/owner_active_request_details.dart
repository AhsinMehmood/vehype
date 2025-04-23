import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/create_request_page.dart';

import 'package:vehype/Pages/full_image_view_page.dart';

import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import '../Models/garage_model.dart';
import '../Widgets/select_date_and_price.dart';

class OwnerActiveRequestDetails extends StatefulWidget {
  final OffersModel offersModel;

  final String? chatId;
  const OwnerActiveRequestDetails(
      {super.key, required this.offersModel, this.chatId});

  @override
  State<OwnerActiveRequestDetails> createState() =>
      _OwnerActiveRequestDetailsState();
}

class _OwnerActiveRequestDetailsState extends State<OwnerActiveRequestDetails> {
  final ScrollController scrollController = ScrollController();
  double opacity = 0.0;

  final PageController pageController = PageController();

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
    if (widget.offersModel.address == '' ||
        widget.offersModel.address == 'Failed to fetch address') {
      getAddress();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  getAddress() async {
    String address = await getAddressFromLatLng(
        widget.offersModel.lat, widget.offersModel.long);
    FirebaseFirestore.instance
        .collection('offers')
        .doc(widget.offersModel.offerId)
        .update({'address': address});
  }

  int currentIndex = 0;

  bool yourOfferExpanded = false;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);
    final OffersModel offersModel = offersProvider.ownerOffers
        .firstWhere((offer) => offer.offerId == widget.offersModel.offerId);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: StreamBuilder<GarageModel>(
          stream: FirebaseFirestore.instance
              .collection('garages')
              .doc(offersModel.garageId)
              .snapshots()
              .map((cc) => GarageModel.fromJson(cc)),
          builder: (context, snapshot) {
            GarageModel garageModel = snapshot.data ??
                GarageModel(
                    ownerId: 'ownerId',
                    createdAt: DateTime.now().toIso8601String(),
                    submodel: '',
                    title: '',
                    imageUrl: offersModel.imageOne,
                    bodyStyle: 'Passenger vehicle',
                    make: '',
                    year: '',
                    model: '',
                    vin: '',
                    isCustomModel: false,
                    isCustomMake: false,
                    garageId: offersModel.garageId);
            return Scaffold(
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          SizedBox(
                            // color: Colors.red,
                            width: Get.width,
                            height: 300,
                            child: Stack(
                              children: [
                                PageView.builder(
                                    itemCount: 1 + offersModel.images.length,
                                    controller: pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return InkWell(
                                          onTap: () {
                                            List images = <dynamic>[
                                                  garageModel.imageUrl
                                                ] +
                                                offersModel.images;
                                            Get.to(() => FullImagePageView(
                                                  urls: images,
                                                  currentIndex: 0,
                                                ));
                                          },
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox.shrink(),
                                            imageUrl: garageModel.imageUrl,
                                            fit: BoxFit.cover,
                                            height: 300,
                                            width: Get.width,
                                          ),
                                        );
                                      } else {
                                        String url =
                                            offersModel.images[index - 1];
                                        return InkWell(
                                          onTap: () {
                                            List images = <dynamic>[
                                                  garageModel.imageUrl,
                                                ] +
                                                offersModel.images;
                                            Get.to(() => FullImagePageView(
                                                  urls: images,
                                                  currentIndex: index - 1,
                                                ));
                                          },
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) {
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox.shrink(),
                                            imageUrl: url,
                                            fit: BoxFit.cover,
                                            height: 300,
                                            width: Get.width,
                                          ),
                                        );
                                      }
                                    }),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white,
                                        ),
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              size: 15,
                                              color: primaryColor,
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              '${currentIndex + 1}/${offersModel.images.length + 1}',
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 12,
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
                            padding: const EdgeInsets.all(15.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    garageModel.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Flexible(
                                              child: Text(
                                                offersModel.address,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        formatDate(DateTime.parse(
                                            offersModel.createdAt)),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
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
                                    color: userController.isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : primaryColor.withOpacity(0.2),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset(
                                                getServices()
                                                    .firstWhere((test) =>
                                                        test.name ==
                                                        offersModel.issue)
                                                    .image,
                                                color: Colors.blueAccent,
                                                height: 28,
                                                width: 28,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Issue',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Text(
                                                    offersModel.issue,
                                                    style: TextStyle(
                                                      fontSize: 16,
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
                                          if (offersModel.additionalService !=
                                              '')
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  getAdditionalService()
                                                      .firstWhere((dd) =>
                                                          dd.name ==
                                                          offersModel
                                                              .additionalService)
                                                      .icon,
                                                  color: Colors.blueAccent,
                                                  height: 28,
                                                  width: 28,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Additional Service',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      offersModel
                                                          .additionalService,
                                                      style: TextStyle(
                                                        fontSize: 16,
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
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month,
                                                  color: Colors.blueAccent,
                                                  size: 28,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Year',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      garageModel.year,
                                                      style: TextStyle(
                                                        fontSize: 16,
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
                                      if (offersModel.additionalService != '')
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              color: Colors.blueAccent,
                                              size: 28,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Year',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 3,
                                                ),
                                                Text(
                                                  garageModel.year,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w800,
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
                                        height: 20,
                                      ),
                                      Container(
                                        height: 0.5,
                                        width: Get.width,
                                        color: userController.isDark
                                            ? Colors.white.withOpacity(0.2)
                                            : primaryColor.withOpacity(0.2),
                                      ),
                                      // const SizedBox(
                                      //   height: 30,
                                      // ),
                                      // Align(
                                      //   alignment: Alignment.centerLeft,
                                      //   child: Column(
                                      //     children: [
                                      //       Align(
                                      //         alignment: Alignment.centerLeft,
                                      //         child: Text(
                                      //           'Details',
                                      //           style: TextStyle(
                                      //             fontSize: 16,
                                      //             fontWeight: FontWeight.w800,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       const SizedBox(
                                      //         height: 30,
                                      //       ),
                                      //       Container(
                                      //         width: Get.width,
                                      //         decoration: BoxDecoration(
                                      //             borderRadius:
                                      //                 BorderRadius.circular(6),
                                      //             color: userController.isDark
                                      //                 ? Colors.white.withOpacity(0.1)
                                      //                 : primaryColor.withOpacity(0.05)),
                                      //         padding: const EdgeInsets.only(
                                      //           left: 10,
                                      //           right: 10,
                                      //           top: 10,
                                      //           bottom: 10,
                                      //         ),
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.start,
                                      //           children: [
                                      //             Text('Type',
                                      //                 style: TextStyle(
                                      //                     fontSize: 16,
                                      //                     fontWeight: FontWeight.w400)),
                                      //             const SizedBox(
                                      //               width: 60,
                                      //             ),
                                      //             Text(
                                      //                 offersModel.vehicleId
                                      //                     .split(',')
                                      //                     .first
                                      //                     .trim(),
                                      //                 style: TextStyle(
                                      //                     fontSize: 14,
                                      //                     fontWeight: FontWeight.w800)),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //       const SizedBox(
                                      //         height: 5,
                                      //       ),
                                      //       Container(
                                      //         width: Get.width,
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(6),
                                      //         ),
                                      //         padding: const EdgeInsets.only(
                                      //           left: 10,
                                      //           right: 10,
                                      //           top: 10,
                                      //           bottom: 10,
                                      //         ),
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.start,
                                      //           children: [
                                      //             Text('Make',
                                      //                 style: TextStyle(
                                      //                     fontSize: 16,
                                      //                     fontWeight: FontWeight.w400)),
                                      //             const SizedBox(
                                      //               width: 55,
                                      //             ),
                                      //             Text(
                                      //                 offersModel.vehicleId
                                      //                     .split(',')[1]
                                      //                     .trim(),
                                      //                 style: TextStyle(
                                      //                     fontSize: 14,
                                      //                     fontWeight: FontWeight.w800)),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //       const SizedBox(
                                      //         height: 5,
                                      //       ),
                                      //       Container(
                                      //         width: Get.width,
                                      //         decoration: BoxDecoration(
                                      //             borderRadius:
                                      //                 BorderRadius.circular(6),
                                      //             color: userController.isDark
                                      //                 ? Colors.white.withOpacity(0.1)
                                      //                 : primaryColor.withOpacity(0.05)),
                                      //         padding: const EdgeInsets.only(
                                      //           left: 10,
                                      //           right: 10,
                                      //           top: 10,
                                      //           bottom: 10,
                                      //         ),
                                      //         child: Row(
                                      //           mainAxisAlignment:
                                      //               MainAxisAlignment.start,
                                      //           children: [
                                      //             Text('Model',
                                      //                 style: TextStyle(
                                      //                     fontSize: 16,
                                      //                     fontWeight: FontWeight.w400)),
                                      //             const SizedBox(
                                      //               width: 48,
                                      //             ),
                                      //             Text(
                                      //                 offersModel.vehicleId
                                      //                     .split(',')[3]
                                      //                     .trim(),
                                      //                 style: TextStyle(
                                      //                     fontSize: 14,
                                      //                     fontWeight: FontWeight.w800)),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   height: 20,
                                      // ),
                                      Container(
                                        height: 0.5,
                                        width: Get.width,
                                        color: userController.isDark
                                            ? Colors.white.withOpacity(0.2)
                                            : primaryColor.withOpacity(0.2),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      if (garageModel.submodel != '')
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Submodel',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      if (garageModel.submodel != '')
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      if (garageModel.submodel != '')
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            garageModel.submodel,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      if (garageModel.submodel != '')
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      if (garageModel.submodel != '')
                                        Container(
                                          height: 0.5,
                                          width: Get.width,
                                          color: userController.isDark
                                              ? Colors.white.withOpacity(0.2)
                                              : primaryColor.withOpacity(0.2),
                                        ),
                                      if (garageModel.submodel != '')
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Description',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          offersModel.description == ''
                                              ? 'No description has been added to this request.'
                                              : offersModel.description,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        height: 0.5,
                                        width: Get.width,
                                        color: userController.isDark
                                            ? Colors.white.withOpacity(0.2)
                                            : primaryColor.withOpacity(0.2),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Location',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
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
                                                MainAxisAlignment.start,
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
                                                        offersModel.address,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
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
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        width: Get.width,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                                zoomControlsEnabled: false,
                                                initialCameraPosition:
                                                    CameraPosition(
                                                  target: LatLng(
                                                      offersModel.lat,
                                                      offersModel.long),
                                                  zoom: 16.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: InkWell(
                                                  onTap: () {
                                                    MapsLauncher
                                                        .launchCoordinates(
                                                            offersModel.lat,
                                                            offersModel.long);
                                                  },
                                                  child: Container(
                                                    width: Get.width * 0.6,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        color: userController
                                                                .isDark
                                                            ? primaryColor
                                                            : Colors.white,
                                                        border: Border.all(
                                                          color: userController
                                                                  .isDark
                                                              ? Colors.white
                                                              : primaryColor,
                                                        )),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          'See Location',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w900,
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
                                        color: userController.isDark
                                            ? Colors.white.withOpacity(0.2)
                                            : primaryColor.withOpacity(0.2),
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
                              ? primaryColor.withOpacity(opacity)
                              : Colors.white.withOpacity(opacity),
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
                                    Icons.arrow_back_ios_new,
                                    color: opacity < 0.5
                                        ? Colors.white
                                        : userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                  )),
                              Opacity(
                                opacity: opacity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      garageModel.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                            getServices()
                                                .firstWhere((element) =>
                                                    element.name ==
                                                    offersModel.issue)
                                                .image,
                                            color: userController.isDark
                                                ? Colors.white
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
                                            fontFamily: 'Avenir',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          offersModel.issue,
                                          style: TextStyle(
                                            // color: Colors.black,
                                            fontFamily: 'Avenir',
                                            fontWeight: FontWeight.w400,
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: offersModel.status != 'active'
                  ? null
                  : InkWell(
                      onTap: () {
                        Get.to(() => CreateRequestPage(
                              offersModel: offersModel,
                              garageModel: garageModel,
                            ));
                      },
                      child: Container(
                        height: 50,
                        width: Get.width * 0.9,
                        margin: const EdgeInsets.only(
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            'Update Request',
                            style: TextStyle(
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
            );
          }),
    );
  }
}
