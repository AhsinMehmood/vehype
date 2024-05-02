// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class SecondUserProfile extends StatelessWidget {
  final String userId;
  const SecondUserProfile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.close,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
      ),
      body: StreamBuilder<UserModel>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots()
              .map((event) => UserModel.fromJson(event)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            }
            UserModel userModel = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: ExtendedImage.network(
                          userModel.profileUrl,
                          width: 75,
                          height: 75,
                          fit: BoxFit.fill,
                          cache: true,
                          // border: Border.all(color: Colors.red, width: 1.0),
                          shape: BoxShape.circle,
                          borderRadius:
                              BorderRadius.all(Radius.circular(200.0)),
                          //cancelToken: cancellationToken,
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
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          RatingBarIndicator(
                            rating: userModel.rating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 25.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          // Text(
                          //   userModel.email,
                          //   style: TextStyle(
                          //     color: userController.isDark
                          //         ? Colors.white
                          //         : primaryColor,
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w400,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.close(1);
                          MapsLauncher.launchCoordinates(
                              userModel.lat, userModel.long);
                        },
                        child: Text(
                          'Show Directions',
                          style: TextStyle(
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fixedSize: Size(Get.width * 0.8, 55)),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
