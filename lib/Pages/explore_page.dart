// ignore_for_file: prefer_const_constructors

import 'dart:async';
// import 'package:fuse/fuse.dart'; // Import the fuse package

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Pages/my_fav_page.dart';
import 'package:vehype/Widgets/widget_to_icon.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
import 'second_user_profile.dart';

final _collectionReference = FirebaseFirestore.instance.collection('locations');

/// Geo query geoQueryCondition.
class _GeoQueryCondition {
  _GeoQueryCondition({
    required this.radiusInKm,
    required this.cameraPosition,
  });

  final double radiusInKm;
  final CameraPosition cameraPosition;
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  void initState() {
    super.initState();
    getLocations();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  double lat = 0.0;
  double long = 0.0;

  final double radiusInKm = 50;

// Field name of Cloud Firestore documents where the geohash is saved.
  final String field = 'geo';

  final CollectionReference<Map<String, dynamic>> collectionReference =
      FirebaseFirestore.instance.collection('users');
  getLocations() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;

    setState(() {
      lat = userModel.lat;
      long = userModel.long;
    });
  }

  UserModel? selectedMarker;

  List<Marker> addMarkers(List<UserModel> nearbyProviders) {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    List<Marker> markers = [];
    for (UserModel element in nearbyProviders) {
      print(element.userId);
      if (element.email == 'No email set') {
      } else {
        if (element.userId != userController.userModel!.userId) {
          markers.add(
            Marker(
                markerId: MarkerId(element.userId),
                position: LatLng(element.lat, element.long),
                icon: BitmapDescriptor.fromBytes(
                    userModel.favProviderIds.contains(element.userId)
                        ? userController.favMarkar
                        : userController.userMarker),
                onTap: () async {
                  GoogleMapController mapController = await _controller.future;
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(element.lat, element.long),
                        zoom: 15,
                      ),
                    ),
                  );
                  setState(() {
                    selectedMarker = element;
                  });
                }),
          );
        }
      }
    }

    return markers;
  }

  bool isSatLite = false;
  String searchText = '';
  List<UserModel> searchedUsers = [];
  // Function to search users
  // void searchUsers(String query, List<UserModel> nearbyProvidersStream) {
  //   // searchedUsers.clear(); // Clear previous search results

  //   // Iterate through nearbyProvidersStream to find matching users
  //   for (var element in nearbyProvidersStream) {
  //     final fuse = Fuzzy(element.services);
  //   }
  // }

  TextEditingController text = TextEditingController();
  // List services = [];
  List<UserModel> filterProvidersByServices(
      List<UserModel> providers, List targetServices) {
    return providers
        .where((provider) => provider.services
            .any((service) => targetServices.contains(service)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    GeoPoint tokyoStation = GeoPoint(userModel.lat, userModel.long);

    final GeoFirePoint center = GeoFirePoint(tokyoStation);
// Function to get GeoPoint instance from Cloud Firestore document data.
    GeoPoint geopointFrom(Map<String, dynamic> data) =>
        (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
    // Custom query condition.
    Query<Map<String, dynamic>> queryBuilder(
            Query<Map<String, dynamic>> query) =>
        query
            .where('accountType', isEqualTo: 'provider')
            .where('status', isEqualTo: 'active');
// Streamed document snapshots of geo query under given conditions.
    final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> stream =
        GeoCollectionReference<Map<String, dynamic>>(collectionReference)
            .subscribeWithin(
      center: center,
      radiusInKm: radiusInKm,
      field: field,
      geopointFrom: geopointFrom,
      queryBuilder: queryBuilder,
    );

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
          stream: stream,
          builder: (context,
              AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>>
                  snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            } else if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            }
            List<UserModel> nearbyProvidersStream = [];

            for (DocumentSnapshot<Map<String, dynamic>> element
                in snapshot.data ?? []) {
              nearbyProvidersStream.add(UserModel.fromJson(element));
            }
            Fuzzy<String> f = Fuzzy(
                nearbyProvidersStream.map((e) => e.searchKey).toList(),
                options: FuzzyOptions());
            List<Result<String>> matches = f.search(searchText);
            List<UserModel> filterList = [];

            if (searchText != '') {
              for (var match in matches) {
                var userModel = nearbyProvidersStream
                    .firstWhere((element) => element.searchKey == match.item);
                filterList.add(userModel);
              }
            }
            List<UserModel> filterByService =
                userController.selectedServicesFilter.isEmpty
                    ? nearbyProvidersStream
                    : filterProvidersByServices(nearbyProvidersStream,
                        userController.selectedServicesFilter);

            List<Marker> markers = addMarkers(filterByService);
            markers.add(
              Marker(
                markerId: const MarkerId('current'),
                position: LatLng(userModel.lat, userModel.long),
              ),
            );
            return Stack(
              children: [
                GoogleMap(
                  markers: markers.toSet(),
                  liteModeEnabled: false,
                  compassEnabled: false,
                  myLocationEnabled: false,
                  mapType: isSatLite ? MapType.satellite : MapType.normal,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, long),
                    zoom: 14.0,
                  ),
                  onTap: (s) {
                    if (selectedMarker != null) {
                      selectedMarker = null;
                      setState(() {});
                    }
                  },
                  onMapCreated: (controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Card(
                            margin: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                              ),
                              width: Get.width * 0.9,
                              height: 50,
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search_outlined,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: TextFormField(
                                    controller: text,
                                    onTap: () {
                                      if (selectedMarker != null) {
                                        selectedMarker = null;
                                        setState(() {});
                                      }
                                    },
                                    onTapOutside: (s) {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    },
                                    textInputAction: TextInputAction.search,
                                    onChanged: (s) {
                                      setState(() {
                                        searchText = s;
                                      });
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Search by Name or Service'),
                                  )),
                                  if (searchText.isNotEmpty)
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            searchText = '';
                                            filterList = [];
                                            text.clear();
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                        ))
                                ],
                              ),
                            ),
                          ),
                          if (filterList.isEmpty && searchedUsers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 0,
                                right: 15,
                                top: 15,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isSatLite = !isSatLite;
                                      });
                                    },
                                    child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                        ),
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(isSatLite
                                              ? Icons.map
                                              : Icons.map_outlined),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          if (filterList.isEmpty && searchedUsers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 0,
                                right: 15,
                                top: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedMarker = null;
                                      });
                                      Get.bottomSheet(
                                        ServiceFilterSheet(),
                                        backgroundColor: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        isScrollControlled: true,
                                      );
                                    },
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                          ),
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Stack(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/filter.svg',
                                                    height: 24,
                                                    width: 24,
                                                    color: userController.isDark
                                                        ? Colors.white
                                                        : primaryColor,
                                                  ),
                                                  if (userController
                                                      .selectedServicesFilter
                                                      .isNotEmpty)
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        200),
                                                            color: Colors.red),
                                                        height: 15,
                                                        width: 15,
                                                        child: Center(
                                                          child: Text(
                                                            userController
                                                                .selectedServicesFilter
                                                                .length
                                                                .toString(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // if (searchedUsers.isNotEmpty)
                          //   Expanded(
                          //     child: Container(
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.only(
                          //           topLeft: Radius.circular(30),
                          //           topRight: Radius.circular(30),
                          //         ),
                          //         color: userController.isDark
                          //             ? primaryColor
                          //             : Colors.white,
                          //       ),
                          //       margin: const EdgeInsets.only(top: 20),
                          //       child: Column(
                          //         children: [
                          //           Align(
                          //             alignment: Alignment.centerRight,
                          //             child: Padding(
                          //               padding: const EdgeInsets.all(12.0),
                          //               child: IconButton(
                          //                 onPressed: () {
                          //                   setState(() {
                          //                     searchedUsers = [];
                          //                     // filterList = [];
                          //                   });
                          //                 },
                          //                 icon: Icon(
                          //                   Icons.close,
                          //                   color: userController.isDark
                          //                       ? Colors.white
                          //                       : primaryColor,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //           Expanded(
                          //             child: ListView.builder(
                          //                 itemCount: searchedUsers.length,
                          //                 shrinkWrap: true,
                          //                 itemBuilder: (context, index) {
                          //                   return ProviderShortWidget(
                          //                       profile: searchedUsers[index]);
                          //                 }),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          if (filterList.isNotEmpty)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                ),
                                margin: const EdgeInsets.only(top: 20),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              searchText = '';
                                              filterList = [];
                                              text.clear();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                          itemCount: filterList.length,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return ProviderShortWidget(
                                                profile: filterList[index]);
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    )),
                if (selectedMarker != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        ProviderShortWidget(
                          profile: selectedMarker!,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
    );
  }

  onFilterListTap(List<UserModel> nearbyProvidersStream, Service service,
      UserController userController) {
    if (nearbyProvidersStream
        .where((provider) =>
            provider.services.any((s) => s.toString() == service.name))
        .toList()
        .isEmpty) {
      toastification.show(
        context: context, // optional if you use ToastificationWrapper
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: Text(
          'No Providers found for ${service.name}.',
          style: TextStyle(
            color: userController.isDark ? primaryColor : Colors.white,
          ),
        ),
        // you can also use RichText widget for title and description parameters
        // description: RichText(text: const TextSpan(text: '')),
        alignment: Alignment.topCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),

        icon: const Icon(Icons.close),
        primaryColor: Colors.red,
        backgroundColor: userController.isDark ? Colors.white : primaryColor,
        // foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        borderRadius: BorderRadius.circular(12),

        showProgressBar: false,
        closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: true,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: false,
        callbacks: ToastificationCallbacks(
          onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
          onCloseButtonTap: (toastItem) =>
              print('Toast ${toastItem.id} close button tapped'),
          onAutoCompleteCompleted: (toastItem) =>
              print('Toast ${toastItem.id} auto complete completed'),
          onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
        ),
      );
    } else {
      setState(() {
        // searchText = service.name.toLowerCase();
        searchedUsers = [];
        searchedUsers.addAll(nearbyProvidersStream
            .where((provider) =>
                provider.services.any((s) => s.toString() == service.name))
            .toList());
      });
      Get.close(1);
    }
  }

  Future<BitmapDescriptor> getCustomIcon(UserModel userData) async {
    return Container(
      height: 55,
      width: 55,
      child: Stack(
        children: [
          Icon(
            Icons.location_on,
            color: primaryColor,
            size: 55,
          ),
          Align(
            // left: 0,
            // right: 0,
            // top: 4,
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                top: 4,
              ),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: ExtendedImage.network(
                  userData.profileUrl,
                  fit: BoxFit.cover,
                  height: 20,
                  cache: true,
                  width: 20,
                  shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),
          ),
        ],
      ),
    ).toBitmapDescriptor();
  }
}

class ServiceFilterSheet extends StatelessWidget {
  const ServiceFilterSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.9,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (userController.selectedServicesFilter.isNotEmpty) {
                    userController.clearServie();
                  } else {
                    final List<Service> services = getServices();
                    // List servicesToUpdate = [];
                    for (var element in services) {
                      userController.selectService(element.name);
                    }
                  }
                },
                child: Text(
                  userController.selectedServicesFilter.isNotEmpty
                      ? 'Clear'.toUpperCase()
                      : 'Select All'.toUpperCase(),
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Filter by Services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.close(1);
                },
                icon: Icon(
                  Icons.close,
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getServices().length,
              itemBuilder: (context, index) {
                Service service = getServices()[index];

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        userController.selectService(service.name);
                        // appProvider.selectPrefs(pref);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                    value: userController.selectedServicesFilter
                                        .contains(service.name),
                                    onChanged: (s) {
                                      // appProvider.selectPrefs(pref);
                                      userController
                                          .selectService(service.name);
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
                          Row(
                            children: [
                              // Text(
                              //   nearbyProvidersStream
                              //       .where((provider) => provider.services.any(
                              //           (s) =>
                              //               s.toString().toLowerCase() ==
                              //               service.name.toLowerCase()))
                              //       .toList()
                              //       .length
                              //       .toString(),
                              //   style: TextStyle(
                              //     color: userController.isDark
                              //         ? Colors.white
                              //         : primaryColor,
                              //     fontSize: 17,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              const SizedBox(
                                width: 6,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterByServiceSheet extends StatelessWidget {
  const FilterByServiceSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      // height: 280,

      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            'Filter Services by Required Service Type',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
