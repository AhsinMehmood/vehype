import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/second_user_profile.dart';
import 'package:vehype/Widgets/image_grid.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import 'full_image_view_page.dart';

class MyFavPage extends StatelessWidget {
  const MyFavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
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
          'My Favourites',
          style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('favBy', arrayContains: userModel.userId)
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            }
            if (!snap.hasData) {
              return Center(
                child: Text(
                  'No Favourites',
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }
            if (snap.data != null) {
              List<UserModel> favProviders = [];
              for (QueryDocumentSnapshot<Map<String, dynamic>> element
                  in snap.data!.docs) {
                favProviders.add(UserModel.fromJson(element));
              }
              if (favProviders.isEmpty) {
                return Center(
                  child: Text(
                    'No Favourites',
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: favProviders.length,
                    itemBuilder: (context, index) {
                      UserModel favProv = favProviders[index];
                      return ProviderShortWidget(
                        profile: favProv,
                      );
                    });
              }
            }
            return Center(
              child: Text(
                'No Favourites',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }),
    );
  }
}

class ProviderShortWidget extends StatefulWidget {
  final UserModel profile;
  const ProviderShortWidget({super.key, required this.profile});

  @override
  State<ProviderShortWidget> createState() => _ProviderShortWidget();
}

class _ProviderShortWidget extends State<ProviderShortWidget> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Get.to(() => SecondUserProfile(userId: widget.profile.userId));
        },
        child: Container(
          decoration: BoxDecoration(
              color: userController.isDark ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: userController.isDark
                    ? Colors.white.withOpacity(0.4)
                    : primaryColor.withOpacity(0.4),
              )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (widget.profile.gallery.isNotEmpty)
                  SizedBox(
                    height: 120,
                    width: Get.width,
                    child: MasonryView(
                      listOfItem: widget.profile.gallery,
                      // numberOfColumn: 2,
                      itemBuilder: (item) {
                        return InkWell(
                            onTap: () {
                              Get.to(() => SecondUserProfile(
                                  userId: widget.profile.userId));
                            },
                            child: ExtendedImage.network(item));
                      },
                    ),
                  ),
                if (widget.profile.gallery.isNotEmpty)
                  const SizedBox(
                    height: 15,
                  ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => FullImagePageView(
                                urls: [widget.profile.profileUrl]));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: ExtendedImage.network(
                              widget.profile.profileUrl,
                              width: 55,
                              height: 55,
                              fit: BoxFit.fill,
                              cache: true,
                              // border: Border.all(color: Colors.red, width: 1.0),
                              shape: BoxShape.circle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(200.0)),
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
                              widget.profile.name,
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 15,
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
                                    rating: widget.profile.rating,
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
                                    '(${widget.profile.ratings.length.toString()})',
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
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            MapsLauncher.launchCoordinates(
                                widget.profile.lat, widget.profile.long);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.directions_outlined,
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
