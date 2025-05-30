// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Widgets/image_grid.dart';
import 'package:vehype/Widgets/working_hours_widget.dart';
// import 'package:vehype/Widgets/image_grid.dart';
import 'package:vehype/const.dart';
import 'package:http/http.dart' as http;

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'comments_page.dart';
import 'send_request_invite_page.dart';

class RatingsModel {
  final String id;
  final String images;
  final String comment;
  final double rating;

  RatingsModel(
      {required this.id,
      required this.images,
      required this.comment,
      required this.rating});
}

class SecondUserProfile extends StatefulWidget {
  final String userId;

  const SecondUserProfile({super.key, required this.userId});

  @override
  State<SecondUserProfile> createState() => _SecondUserProfileState();
}

class _SecondUserProfileState extends State<SecondUserProfile> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: StreamBuilder<UserModel>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .snapshots()
              .map((event) => UserModel.fromJson(event)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            }
            List<RatingsModel> ratings = [];

            UserModel profileModel = snapshot.data!;
            for (var element in profileModel.ratings) {
              if (element['images'] != null) {
                ratings.add(RatingsModel(
                    id: element['id'],
                    images: element['images'],
                    comment: element['comment'],
                    rating: element['rating']));
              }
            }
            if (profileModel.accountType.toLowerCase() == 'provider') {
              return ProviderProfileWidget(
                  userController: userController,
                  profileModel: profileModel,
                  ratings: ratings);
            } else {
              return SeekerProfileWidget(
                  userController: userController,
                  profileModel: profileModel,
                  ratings: ratings);
            }
          }),
    );
  }
}

class SeekerProfileWidget extends StatelessWidget {
  const SeekerProfileWidget({
    super.key,
    required this.userController,
    required this.profileModel,
    required this.ratings,
  });

  final UserController userController;
  final UserModel profileModel;
  final List<RatingsModel> ratings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 40,
            left: 12,
            right: 12,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      Get.close(1);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() =>
                          FullImagePageView(urls: [profileModel.profileUrl]));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const SizedBox.shrink(),
                        imageUrl: profileModel.profileUrl,
                        width: 65,
                        height: 65,
                        fit: BoxFit.fill,

                        //cancelToken: cancellationToken,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileModel.name,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () {
                          // Get.to(()=>Rat);
                        },
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: profileModel.rating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              '(${profileModel.ratings.length.toString()})',
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 1,
                width: Get.width * 0.8,
                color: changeColor(color: 'D9D9D9'),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Reviews',
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: ReviewsTab(userData: profileModel)),
      ],
    );
  }
}

class ProviderProfileWidget extends StatelessWidget {
  const ProviderProfileWidget({
    super.key,
    required this.userController,
    required this.profileModel,
    required this.ratings,
  });

  final UserController userController;
  final UserModel profileModel;
  final List<RatingsModel> ratings;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          body: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    left: 12,
                    right: 12,
                  ),
                  child: SecondUserHeaderWidget(
                    profile: profileModel,
                    rating: ratings,
                  )),
              SizedBox(
                height: 40,
                width: Get.width,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: userController.isDark
                      ? Colors.white.withOpacity(0.5)
                      : primaryColor.withOpacity(0.5),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    color: userController.isDark
                        ? Colors.white.withOpacity(0.5)
                        : primaryColor.withOpacity(0.5),
                  ),
                  labelColor:
                      userController.isDark ? Colors.white : primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                  tabs: [
                    Tab(text: 'Overview'.toUpperCase()),
                    Tab(text: 'Services'.toUpperCase()),
                    Tab(text: 'REVIEWS'),
                    Tab(text: 'GALLERY'),

                    // Text('Overview'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(children: [
                  OverviewTab(
                    profileModel: profileModel,
                  ),
                  ServicesTab(
                    profileModel: profileModel,
                  ),
                  ReviewsTab(
                    userData: profileModel,
                  ),
                  PhotosTab(
                    profile: profileModel,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhotosTab extends StatelessWidget {
  final UserModel profile;
  final bool isGallery;
  const PhotosTab({super.key, required this.profile, this.isGallery = false});

  @override
  Widget build(BuildContext context) {
    List gallery = profile.gallery.reversed.toList();
    // print(gallery.first);
    // ignore: avoid_unnecessary_containers
    return Container(
      child: gallery.isEmpty
          ? Center(
              child: Text('Nothing here!'),
            )
          : ListView.builder(
              // numberOfColumn: 2,
              itemCount: gallery.length,
              padding: const EdgeInsets.only(
                bottom: 70,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // int index = profile.gallery.indexOf(item);

                    Get.to(() => FullImagePageView(
                          urls: profile.gallery,
                          currentIndex: index,
                        ));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: profile.gallery[index],
                        width: Get.width * 0.9,
                        height: Get.width * 0.5,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => SizedBox(
                          child: Center(child: Text('No Image Found')),
                        ),
                        // borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OverviewTab extends StatefulWidget {
  final UserModel profileModel;

  const OverviewTab({super.key, required this.profileModel});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  double latitude = 37.77483;
  double longitude = -122.41942;
  String address = 'Fetching Address';

  @override
  void initState() {
    super.initState();
    getAddressFromLatLng();
  }

  Future<void> getAddressFromLatLng() async {
    latitude = widget.profileModel.lat;
    longitude = widget.profileModel.long;
    if (widget.profileModel.businessAddress.isEmpty) {
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
              address = json['results'][0]['formatted_address'];
            });
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.profileModel.userId)
                .update({
              'businessAddress': address,
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
    } else {
      address = widget.profileModel.businessAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  widget.profileModel.businessInfo,
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 1,
            width: Get.width * 0.9,
            color: changeColor(color: 'D9D9D9'),
          ),
          if (widget.profileModel.workingHours.isNotEmpty)
            WorkingHoursWidget(
              workingHours: widget.profileModel.workingHours,
              isOwner: true,
            ),
          if (widget.profileModel.workingHours.isNotEmpty)
            Container(
              height: 1,
              width: Get.width * 0.9,
              color: changeColor(color: 'D9D9D9'),
            ),
          InkWell(
            onTap: () {
              MapsLauncher.launchCoordinates(
                  widget.profileModel.lat, widget.profileModel.long);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
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
          Container(
            height: 1,
            width: Get.width * 0.9,
            color: changeColor(color: 'D9D9D9'),
          ),

          // Container(
          //   height: 1,
          //   width: Get.width * 0.8,
          //   color: changeColor(color: 'D9D9D9'),
          // ),
          // if (userModel.status != 'approved')
          const SizedBox(
            height: 20,
          ),
          if (widget.profileModel.contactInfo != '')
            InkWell(
              onTap: () {
                String telUrl = 'tel:${widget.profileModel.contactInfo}';
                launchUrl(Uri.parse(telUrl));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.blue,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.profileModel.contactInfo,
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.profileModel.contactInfo != '')
            const SizedBox(
              height: 15,
            ),
          if (widget.profileModel.contactInfo != '')
            Container(
              height: 1,
              width: Get.width * 0.9,
              color: changeColor(color: 'D9D9D9'),
            ),
          const SizedBox(
            height: 20,
          ),
          if (widget.profileModel.website != '')
            InkWell(
              onTap: () {
                launchUrl(Uri.parse(widget.profileModel.website));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/explore.png',
                      height: 20,
                      width: 20,
                      // ignore: deprecated_member_use
                      color: Colors.blue,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.profileModel.website,
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.profileModel.website != '')
            const SizedBox(
              height: 15,
            ),
        ],
      ),
    );
  }
}

class ServicesTab extends StatelessWidget {
  final UserModel profileModel;

  const ServicesTab({super.key, required this.profileModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          if (profileModel.additionalServices.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {},
                  child: Text(
                    'Additional Services',
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          if (profileModel.additionalServices.isNotEmpty)
            const SizedBox(
              height: 10,
            ),
          if (profileModel.additionalServices.isNotEmpty)
            for (var service in profileModel.additionalServices)
              InkWell(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1, top: 12, left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                          getAdditionalService()
                              .firstWhere((element) => element.name == service)
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
                        service,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (profileModel.additionalServices.isNotEmpty)
            const SizedBox(
              height: 20,
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {},
                child: Text(
                  'My Services',
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          for (var service in profileModel.services)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: userController.isDark ? primaryColor : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                        getServices()
                            .firstWhere((element) => element.name == service)
                            .image,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        height: 45,
                        width: 45),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      service,
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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

class ReviewsTab extends StatefulWidget {
  final UserModel userData;
  const ReviewsTab({super.key, required this.userData});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  String selectedIssue = '';
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final filteredRatings = selectedIssue.isEmpty
        ? widget.userData.ratings
        : widget.userData.ratings
            .where((rating) => rating['service'] == selectedIssue)
            .toList();
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Filter reviews by service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 60,
          // color: Colors.red,
          child: ListView.builder(
              itemCount: getServices().length,
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Service service = getServices()[index];
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onTap: () {
                      if (selectedIssue == service.name) {
                        setState(() {
                          selectedIssue = '';
                        });
                      } else {
                        setState(() {
                          selectedIssue = service.name;
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          service.image,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          height: 50,
                          width: 50,
                        ),
                        if (selectedIssue == service.name)
                          Positioned(
                            right: 2,
                            top: 3,
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(200),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
        ),
        if (selectedIssue.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Chip(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  label: Text(
                    selectedIssue,
                  ),
                  labelStyle: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                  ),
                  deleteIcon: Icon(Icons.close),
                  deleteIconColor:
                      userController.isDark ? primaryColor : Colors.white,
                  onDeleted: () {
                    setState(() {
                      selectedIssue = ''; // Reset to default
                      // _sortAndFilterOffers();
                    });
                  },
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                ),
              ],
            ),
          ),
        Expanded(
          child: filteredRatings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.reviews, // A relevant icon
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No reviews found",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 5),
                      // Text(
                      //   "Be the first to leave a review for this service!",
                      //   style: TextStyle(fontSize: 14, color: Colors.grey),
                      // ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredRatings.length,
                  shrinkWrap: true,
                  // physics: const Ne(),
                  padding: const EdgeInsets.only(
                    top: 5,
                    bottom: 50,
                  ),
                  itemBuilder: (context, inde) {
                    String issue = filteredRatings[inde]['service'];
                    return StreamBuilder<UserModel>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(filteredRatings[inde]['id'])
                            .snapshots()
                            .map((event) => UserModel.fromJson(event)),
                        builder: (context, AsyncSnapshot<UserModel> snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox(
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                ),
                              ),
                            );
                          }
                          UserModel commenterData = snapshot.data!;

                          return CommentWidget(
                              commenterData: commenterData,
                              data: widget.userData,
                              inde: inde);
                        });
                  }),
        ),
      ],
    );
  }
}

class SecondUserHeaderWidget extends StatelessWidget {
  final UserModel profile;
  final List<RatingsModel> rating;
  const SecondUserHeaderWidget(
      {super.key, required this.profile, required this.rating});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    List imageUrls = [];
    for (var element in rating) {
      if (element.images != '') {
        imageUrls.add(element.images);
      }
    }
    // UserModel userModel = userController.userModel!;

    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  Get.close(1);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: userController.isDark ? Colors.white : primaryColor,
                )),
            InkWell(
              onTap: () {
                Get.to(() => FullImagePageView(urls: [profile.profileUrl]));
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: CachedNetworkImage(
                      placeholder: (context, url) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) =>
                          const SizedBox.shrink(),
                      imageUrl: profile.profileUrl,
                      width: 55,
                      height: 55,
                      fit: BoxFit.fill,

                      //cancelToken: cancellationToken,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: profile.isVerified ? 20 : null,
                      // width: 30,
                      decoration: BoxDecoration(
                          color: profile.isVerified
                              ? Colors.green.withOpacity(0.9)
                              : Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6)),
                      child: Center(
                        child: Text(
                          profile.isVerified ? 'VERIFIED' : 'NON\nVERIFIED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: profile.isVerified ? 12 : 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBarIndicator(
                      rating: profile.rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      ' (${profile.ratings.length} Happy Customers)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 50,
          width: Get.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    MapsLauncher.launchCoordinates(profile.lat, profile.long);
                  },
                  child: Container(
                    height: 40,
                    width: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Directions',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                InkWell(
                  onTap: () async {
                    Get.to(() => SendRequestInvitePage(profileModel: profile));
                  },
                  child: Container(
                    height: 40,
                    width: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        border: Border.all(
                          color: Colors.blue,
                        )),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/messages.svg',
                            height: 20,
                            width: 20,
                            // ignore: deprecated_member_use
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Send an Inquiry',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (profile.contactInfo != '')
                  const SizedBox(
                    width: 12,
                  ),
                if (profile.contactInfo != '')
                  InkWell(
                    onTap: () {
                      String telUrl = 'tel:${profile.contactInfo}';
                      launchUrl(Uri.parse(telUrl));
                    },
                    child: Container(
                      height: 40,
                      width: 90,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(
                            color: Colors.blue,
                          )),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.call,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Call',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (profile.website != '')
                  const SizedBox(
                    width: 12,
                  ),
                if (profile.website != '')
                  InkWell(
                    onTap: () {
                      launchUrl(Uri.parse(profile.website));
                    },
                    child: Container(
                      height: 40,
                      width: 120,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          border: Border.all(
                            color: Colors.blue,
                          )),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/explore.png',
                              height: 20,
                              width: 20,
                              // ignore: deprecated_member_use
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Website',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  width: 12,
                ),
                InkWell(
                  onTap: () {
                    if (userController.userModel!.favProviderIds
                        .contains(profile.userId)) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(userController.userModel!.userId)
                          .update({
                        'favProviderIds':
                            FieldValue.arrayRemove([profile.userId])
                      });
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(profile.userId)
                          .update({
                        'favBy': FieldValue.arrayRemove(
                            [userController.userModel!.userId])
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(userController.userModel!.userId)
                          .update({
                        'favProviderIds':
                            FieldValue.arrayUnion([profile.userId])
                      });
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(profile.userId)
                          .update({
                        'favBy': FieldValue.arrayUnion(
                            [userController.userModel!.userId])
                      });
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        border: Border.all(
                          color: Colors.blue,
                        )),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            userController.userModel!.favProviderIds
                                    .contains(profile.userId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: userController.userModel!.favProviderIds
                                    .contains(profile.userId)
                                ? Colors.red
                                : Colors.grey,
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
          height: 15,
        ),
        if (profile.gallery.isNotEmpty)
          SizedBox(
            height: 250,
            width: Get.width,
            child: MasonryView(
              listOfItem: profile.gallery,
              // numberOfColumn: 2,
              itemBuilder: (item) {
                return InkWell(
                    onTap: () {
                      int index = profile.gallery.indexOf(item);

                      Get.to(() => FullImagePageView(
                            urls: profile.gallery,
                            currentIndex: index,
                          ));
                    },
                    child: CachedNetworkImage(
                        placeholder: (context, url) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorWidget: (context, url, error) =>
                            const SizedBox.shrink(),
                        imageUrl: item));
              },
            ),
          ),
        if (profile.gallery.isNotEmpty)
          const SizedBox(
            height: 15,
          ),
      ],
    );
  }
}
