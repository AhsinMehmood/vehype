// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/choose_account_type.dart';
import 'package:vehype/Pages/edit_profile_page.dart';
import 'package:vehype/Pages/explore_page.dart';
import 'package:vehype/Pages/my_garage.dart';
import 'package:vehype/Pages/orders_history_provider.dart';
import 'package:vehype/const.dart';

import '../Models/user_model.dart';
import 'admin_home_page.dart';
import 'comments_page.dart';
import 'delete_account_page.dart';
import 'orders_history_seeker.dart';
import 'splash_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: Text(
      //     'VEHYPE',
      //     style: TextStyle(
      //       color: userController.isDark ? Colors.white : primaryColor,
      //       fontSize: 20,
      //       fontWeight: FontWeight.w800,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (userModel.email == 'No email set') {
                        Get.showSnackbar(GetSnackBar(
                          message: 'Login to continue',
                          duration: const Duration(
                            seconds: 3,
                          ),
                          backgroundColor: userController.isDark
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
                                color: userController.isDark
                                    ? primaryColor
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ));
                      } else {
                        Get.to(() => EditProfilePage());
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: ExtendedImage.network(
                        userModel.profileUrl,

                        width: 75,
                        height: 75,
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
                      InkWell(
                        onTap: () {
                          if (userModel.email == 'No email set') {
                            Get.showSnackbar(GetSnackBar(
                              message: 'Login to continue',
                              duration: const Duration(
                                seconds: 3,
                              ),
                              backgroundColor: userController.isDark
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
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ));
                          } else {
                            Get.to(() => CommentsPage(data: userModel));
                          }
                        },
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: userModel.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 25.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              userModel.ratings.length.toString(),
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        userModel.email,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          // Get.to(() => EditProfilePage());
                          userController.changeTheme(!userController.isDark);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Theme ${userController.isDark ? 'Dark' : 'Light'}',
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              width: 45,
                              height: 30,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: CupertinoSwitch(
                                    value: userController.isDark,
                                    activeColor: Colors.white30,
                                    onChanged: (bool value) {
                                      userController.changeTheme(value);
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (userModel.accountType == 'seeker')
                        InkWell(
                          onTap: () async {
                            if (userModel.email == 'No email set') {
                              Get.showSnackbar(GetSnackBar(
                                message: 'Login to continue',
                                duration: const Duration(
                                  seconds: 3,
                                ),
                                backgroundColor: userController.isDark
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
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ));
                            } else {
                              Get.to(() => ExplorePage());
                            }
                          },
                          child: Text(
                            'Explore Nearby',
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      if (userModel.accountType == 'seeker')
                        const SizedBox(
                          height: 10,
                        ),

                      InkWell(
                        onTap: () async {
                          if (userModel.email == 'No email set') {
                            Get.showSnackbar(GetSnackBar(
                              message: 'Login to continue',
                              duration: const Duration(
                                seconds: 3,
                              ),
                              backgroundColor: userController.isDark
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
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ));
                          } else {
                            Get.to(() => EditProfilePage());
                          }
                        },
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (userController.isAdmin)
                        InkWell(
                          onTap: () {
                            Get.to(() => AdminHomePage());
                          },
                          child: Text(
                            'Manage Users',
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      if (userController.isAdmin)
                        const SizedBox(
                          height: 10,
                        ),
                      // if (userModel.accountType != 'seeker')
                      //   InkWell(
                      //     onTap: () async {
                      //       Get.to(() => OrdersHistoryProvider());
                      //     },
                      //     child: Text(
                      //       'Requests History',
                      //       style: TextStyle(
                      //         color: userController.isDark
                      //             ? Colors.white
                      //             : primaryColor,
                      //         fontFamily: 'Avenir',
                      //         fontWeight: FontWeight.w800,
                      //         fontSize: 20,
                      //       ),
                      //     ),
                      //   ),

                      // if (userModel.accountType != 'seeker')

                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 1,
                        width: Get.width * 0.8,
                        color: changeColor(color: 'D9D9D9'),
                      ),
                      // if (userModel.status != 'approved')
                      // const SizedBox(
                      //   height: 20,
                      // ),

                      // InkWell(
                      //   onTap: () async {
                      //     // Get.offAll(() => SplashPage());
                      //   },
                      //   child: Text(
                      //     'Notifications',
                      //     style: TextStyle(
                      //       color: userController.isDark ? Colors.white : primaryColor,
                      //       fontFamily: 'Avenir',
                      //       fontWeight: FontWeight.w800,
                      //       fontSize: 20,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // Container(
                      //   height: 1,
                      //   width: Get.width * 0.8,
                      //   color: changeColor(color: 'D9D9D9'),
                      // ),
                      // if (userModel.status != 'approved')
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          // Get.offAll(() => SplashPage());
                          launchUrlString('mailto:support@vehype.com');
                        },
                        child: Text(
                          'Contact Us',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          // Get.offAll(() => SplashPage());
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          // Get.offAll(() => SplashPage());
                        },
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          if (userModel.email == 'No email set') {
                            Get.showSnackbar(GetSnackBar(
                              message: 'Login to continue',
                              duration: const Duration(
                                seconds: 3,
                              ),
                              backgroundColor: userController.isDark
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
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ));
                          } else {
                            Get.to(() => DeleteAccountPage());
                          }
                        },
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          if (userModel.email == 'No email set') {
                            Get.showSnackbar(GetSnackBar(
                              message: 'Login to continue',
                              duration: const Duration(
                                seconds: 3,
                              ),
                              backgroundColor: userController.isDark
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
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ));
                          } else {
                            UserController().logout(userModel);
                            userController.changeTabIndex(0);
                          }
                          // Get.offAll(SplashPage());
                        },
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'App Version: 3.0.3.32',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Avenir',
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
