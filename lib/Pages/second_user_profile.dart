// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Widgets/image_grid.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class SecondUserProfile extends StatelessWidget {
  final String userId;
  const SecondUserProfile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return DefaultTabController(
      length: 5,
      child: StreamBuilder<UserModel>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
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
            UserModel userModel = snapshot.data!;
            return Scaffold(
              body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: 300.0,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(userModel.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              )),
                          background:
                              SecondUserHeaderWidget(userModel: userModel)),
                      bottom: TabBar(
                        isScrollable: true,
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
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                        tabs: [
                          Tab(text: 'Overview'.toUpperCase()),
                          Tab(text: 'Services'.toUpperCase()),
                          Tab(text: 'REVIEWS'),
                          Tab(text: 'PHOTOS'),
                          Tab(text: 'ABOUT'),

                          // Text('Overview'),
                        ],
                      ),
                    ),
                  ];
                },
                body: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //   height: 30,
                          //   width: Get.width,
                          //   child:
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class SecondUserHeaderWidget extends StatelessWidget {
  final UserModel userModel;
  const SecondUserHeaderWidget({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        GestureDetector(
          onTap: () {
            Get.close(1);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 4,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Get.to(() => FullImagePageView(url: userModel.profileUrl));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: ExtendedImage.network(
                  userModel.profileUrl,
                  width: 55,
                  height: 55,
                  fit: BoxFit.fill,
                  cache: true,
                  // border: Border.all(color: Colors.red, width: 1.0),
                  shape: BoxShape.circle,
                  borderRadius: BorderRadius.all(Radius.circular(200.0)),
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
                  userModel.name,
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
                        rating: userModel.rating,
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
                        '(${userModel.ratings.length.toString()})',
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 13,
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
                    MapsLauncher.launchCoordinates(
                        userModel.lat, userModel.long);
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
                Container(
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
                        Image.asset(
                          'assets/repair.png',
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
                          'Send Request Invite',
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
                const SizedBox(
                  width: 12,
                ),
                Container(
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
                const SizedBox(
                  width: 12,
                ),
                Container(
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
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 250,
          width: Get.width,
          child: MasonryView(
            listOfItem: userModel.gallery,
            // numberOfColumn: 2,
            itemBuilder: (item) {
              return InkWell(
                  onTap: () {
                    Get.to(() => FullImagePageView(url: item));
                  },
                  child: ExtendedImage.network(item));
            },
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
