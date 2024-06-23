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
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vehype/Controllers/garage_controller.dart';
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
  void searchUsers(String query, List<UserModel> nearbyProvidersStream) {
    searchedUsers.clear(); // Clear previous search results

    // Iterate through nearbyProvidersStream to find matching users
    for (var element in nearbyProvidersStream) {
      final fuse = Fuzzy(element.services);
    }
  }

  TextEditingController text = TextEditingController();
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
            List<Marker> markers = addMarkers(nearbyProvidersStream);
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
                                        hintText: 'Type to Search...'),
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
                          if (filterList.isEmpty)
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
                                child: ListView.builder(
                                    itemCount: filterList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ProviderShortWidget(
                                          profile: filterList[index]);
                                    }),
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
