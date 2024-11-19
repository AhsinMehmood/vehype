// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';
// import 'package:fuse/fuse.dart'; // Import the fuse package

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:searchfield/searchfield.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Pages/my_fav_page.dart';
import 'package:vehype/Widgets/widget_to_icon.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;
import 'package:widget_marker_google_map/widget_marker_google_map.dart';
import 'dart:ui' as ui;

import '../Controllers/user_controller.dart';
import '../Models/user_model.dart';
// import 'package:widget_to_marker/widget_to_marker.dart';

// final _collectionReference = FirebaseFirestore.instance.collection('locations');

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

  FocusNode searchnode = FocusNode();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  // GoogleMapController? mapController;
  // String _mapStyle = '';
  double lat = 0.0;
  double long = 0.0;
  bool focus = false;

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

  List<WidgetMarker> addMarkers(List<UserModel> nearbyProviders) {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    List<WidgetMarker> markers = [];
    for (UserModel element in nearbyProviders) {
      if (element.email == 'No email set') {
      } else {
        if (element.userId != userController.userModel!.userId) {
          markers.add(WidgetMarker(
              markerId: element.userId,
              position: LatLng(element.lat, element.long),
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
              },
              widget: Container(
              height: 54,
                // width: 70,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: CachedNetworkImage(
                        imageUrl: element.profileUrl,
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      element.name,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )));
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
//  rootBundle.loadString('assets/dark_mode_map.json').then((style) {
//       _mapStyle = style;
//     });
    final GeoFirePoint center = GeoFirePoint(tokyoStation);
// Function to get GeoPoint instance from Cloud Firestore document data.
    GeoPoint geopointFrom(Map<String, dynamic> data) =>
        (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
    // Custom query condition.
    Query<Map<String, dynamic>> queryBuilder(
            Query<Map<String, dynamic>> query) =>
        query.where('accountType', isEqualTo: 'provider');
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
      body: SafeArea(
          child: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
              stream: stream,
              builder: (context,
                  AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                    ),
                  );
                }
                List<UserModel> nearbyProvidersStream = [];

                for (DocumentSnapshot<Map<String, dynamic>> element
                    in snapshot.data ?? []) {
                  bool isDelete = element.data()?['isDelete'] ?? false;
                  if (element.data()?['name'] != 'Guest User') {
                    if (!isDelete) {
                      // Checks both false and missing (defaulting to false)
                      nearbyProvidersStream.add(UserModel.fromJson(element));
                    }
                  }
                }
                Fuzzy<String> f = Fuzzy(
                    nearbyProvidersStream.map((e) => e.searchKey).toList(),
                    options: FuzzyOptions());
                List<Result<String>> matches = f.search(searchText);
                List<UserModel> filterList = [];

                if (searchText != '') {
                  for (var match in matches) {
                    var userModel = nearbyProvidersStream.firstWhere(
                        (element) => element.searchKey == match.item);
                    filterList.add(userModel);
                  }
                }
                List<UserModel> filterByService =
                    userController.selectedServicesFilter.isEmpty
                        ? nearbyProvidersStream
                        : filterProvidersByServices(nearbyProvidersStream,
                            userController.selectedServicesFilter);

                List<WidgetMarker> markers = addMarkers(filterByService);
                markers.add(
                  WidgetMarker(
                    markerId: 'current',
                    widget: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: CachedNetworkImage(
                        imageUrl: userModel.profileUrl,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    position: LatLng(userModel.lat, userModel.long),
                  ),
                );
                return Stack(
                  children: [
                    WidgetMarkerGoogleMap(
                      // markers: markers.toSet(),
                      widgetMarkers: markers,
                      liteModeEnabled: false,
                      compassEnabled: false,
                      myLocationEnabled: false,
                      mapType: isSatLite ? MapType.satellite : MapType.normal,
                      zoomControlsEnabled: false,
                      zoomGesturesEnabled: true,
                      onCameraMove: (position) {
                        lat = position.target.latitude;
                        long = position.target.longitude;
                        setState(() {});
                      },
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
                              // if (searchnode.hasFocus)/
                              Visibility(
                                visible: focus,
                                child: Card(
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                  margin: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    width: Get.width * 0.9,
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
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
                                          focusNode: searchnode,
                                          controller: text,
                                          onTap: () {
                                            if (selectedMarker != null) {
                                              selectedMarker = null;

                                              setState(() {});
                                            }
                                          },
                                          onTapOutside: (s) {
                                            if (searchText.isEmpty) {
                                              setState(() {
                                                focus = false;
                                              });
                                            }
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                          },
                                          textInputAction:
                                              TextInputAction.search,
                                          onChanged: (s) {
                                            setState(() {
                                              searchText = s;
                                            });
                                          },
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                fontWeight: FontWeight.w200,
                                              ),
                                              hintText:
                                                  'Search by Name or Service'),
                                        )),

                                        // SearchField(
                                        //   onSearchTextChanged: (query) {

                                        //     return searchedUsers
                                        //         .map((e) =>
                                        //             SearchFieldListItem<String>(
                                        //                 e.searchKey,
                                        //                 child: ProviderShortWidget(
                                        //                   profile: e,
                                        //                 )))
                                        //         .toList();
                                        //   },
                                        //   onTap: () async {},

                                        //   /// widget to show when suggestions are empty
                                        //   emptyWidget: Container(
                                        //       // decoration: suggestionDecoration,
                                        //       height: 200,
                                        //       child: const Center(
                                        //           child: CircularProgressIndicator(
                                        //               // color: Colors.white,
                                        //               ))),
                                        //   hint: 'Search by Name or Service',
                                        //   itemHeight: 50,
                                        //   scrollbarDecoration: ScrollbarDecoration(),
                                        //   // suggestionStyle: const TextStyle(
                                        //   //     fontSize: 24, color: Colors.white),
                                        //   // searchInputDecoration: InputDecoration(...),
                                        //   // border: OutlineInputBorder(...)p
                                        //   // fillColor: Colors.white,
                                        //   // filled: true,
                                        //   onTapOutside: (s) {
                                        //     FocusScope.of(context)
                                        //         .requestFocus(FocusNode());
                                        //   },
                                        //   textInputAction: TextInputAction.search,
                                        //   // suggestionsDecoration: suggestionDecoration,
                                        //   suggestions: searchedUsers
                                        //       .map((e) => SearchFieldListItem<String>(
                                        //           e.searchKey,
                                        //           child: ProviderShortWidget(
                                        //             profile: e,
                                        //           )))
                                        //       .toList(),
                                        //   // focusNode: ,
                                        //   suggestionState: Suggestion.expand,
                                        //   onSuggestionTap:
                                        //       (SearchFieldListItem<String> x) {
                                        //     FocusScope.of(context)
                                        //         .requestFocus(FocusNode());
                                        //     // focus.unfocus();
                                        //   },
                                        // ),

                                        if (searchText.isNotEmpty)
                                          IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  searchText = '';
                                                  filterList = [];
                                                  text.clear();
                                                  focus = false;
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
                              ),
                              if (filterList.isNotEmpty)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                    ),
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 5,
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
                    if (selectedMarker == null)
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (searchText.isEmpty && focus == false)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 15, top: 0, bottom: 0),
                                  child: InkWell(
                                    onTap: () async {
                                      // FocusScope.of(context).requestFocus(searchnode);
                                      final GoogleMapController mapController =
                                          await _controller.future;

                                      // Define a new camera position
                                      CameraPosition newPosition =
                                          CameraPosition(
                                        target: LatLng(lat,
                                            long), // Example coordinates (San Francisco)
                                        zoom: 14.0, // Example zoom level
                                      );

                                      // Create a CameraUpdate object with the new position
                                      CameraUpdate cameraUpdate =
                                          CameraUpdate.newCameraPosition(
                                              newPosition);

                                      // Animate the camera to the new position
                                      mapController.animateCamera(cameraUpdate);
                                    },
                                    child: Card(
                                        elevation: 1.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.my_location_outlined,
                                          ),
                                        )),
                                  ),
                                ),
                              if (filterList.isEmpty && searchedUsers.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 15,
                                    // top: 15,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        isSatLite = !isSatLite;
                                      });
                                    },
                                    child: Card(
                                        elevation: 1.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                ),
                              if (filterList.isEmpty && searchedUsers.isEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 0,
                                    right: 15,
                                    bottom: searchnode.hasFocus ? 15 : 0,
                                    top: 0,
                                  ),
                                  child: InkWell(
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
                                              BorderRadius.circular(12),
                                        ),
                                        isScrollControlled: true,
                                      );
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Card(
                                          elevation: 1.0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
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
                                ),
                              if (searchText.isEmpty && focus == false)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 15, top: 0, bottom: 15),
                                  child: InkWell(
                                    onTap: () {
                                      // FocusScope.of(context).requestFocus(searchnode);

                                      setState(() {
                                        focus = true;
                                      });
                                      Future.delayed(Durations.medium4)
                                          .then((s) {
                                        FocusScope.of(context)
                                            .requestFocus(searchnode);
                                      });
                                    },
                                    child: Card(
                                        elevation: 1.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.search_outlined,
                                          ),
                                        )),
                                  ),
                                ),
                            ],
                          ))
                  ],
                );
              })),
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
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: Text(
          'No Providers found for ${service.name}.',
        ),
        showProgressBar: true,
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
    return SizedBox(
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
                child: CachedNetworkImage(
                  placeholder: (context, url) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                  imageUrl: userData.profileUrl,
                  fit: BoxFit.cover,
                  height: 20,
                  width: 20,
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
