// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Pages/choose_account_type.dart';
import 'package:vehype/Pages/edit_profile_page.dart';
import 'package:vehype/const.dart';

import '../Models/user_model.dart';
import 'admin_home_page.dart';
import 'comments_page.dart';
import 'delete_account_page.dart';
import 'my_fav_page.dart';
// import 'orders_history_seeker.dart';

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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                              itemSize: 24.0,
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
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
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
                          'Manage Profile',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
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
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      if (userController.isAdmin)
                        const SizedBox(
                          height: 10,
                        ),
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
                      const SizedBox(
                        height: 10,
                      ),
                      // if (userModel.accountType != 'seeker')

                      // if (userModel.status != 'approved')

                      if (userModel.accountType == 'seeker')
                        InkWell(
                          onTap: () async {
                            Get.to(() => MyFavPage());
                          },
                          child: Text(
                            'My Favourites',
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 1,
                        width: Get.width * 0.8,
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

                      InkWell(
                        onTap: () async {
                          // Get.offAll(() => SplashPage());
                          Share.share(
                              'Spread the Word: VEHYPE Connects Vehicle Owners with Top Service Owners! https://vehype.com/');
                        },
                        child: Text(
                          'Share VEHYPE',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          // Get.offAll(() => SplashPage());
                          launchUrl(Uri.parse(
                              'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          launchUrl(Uri.parse(
                              'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                          // Get.offAll(() => SplashPage());
                        },
                        child: Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
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
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        // 89
                        onTap: () async {
                          Get.bottomSheet(LogoutConfirmation());
                        },
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
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
                      InkWell(
                        onTap: () async {
                          // List ooo = [
                          //   'x7PQVwdWnc14dS1cij4O',
                          //   'yf5y8dWdzhAYLVDxgbHV',
                          //   'tKIK5bnXNNkgomMJf0DW',
                          //   'sv3yUlk7PFvwpbslA6WU',
                          //   'sskm4ngC1Dt25bZPM4Rl',
                          //   'f7EF2OpJ3SVIOYn1C6Yc',
                          //   'c3b96p3ABZaOf1hslKPP',
                          //   'ax0QMCvkzHsZcV6LeVOS',
                          //   'Ulqy4uEtJ5wiOL6Prego',
                          //   'U93H8n7mWPh0WrvsdwlY',
                          //   'QUAXU4wZQmKJibZp5ZP9',
                          //   'LWfswqfZHdRhFRHz063I',
                          //   'KpPGfnynSrpoqBQwglgV',
                          //   'Ay5LEbBJqHPwdJ2m5AJt',
                          //   'A75ctiAnB29MEQjvt16y',
                          //   '9MZu0LegYFOUkr0p1TQ8',
                          //   '7L63wFpOJXJI266lHIgQ',
                          //   '73ESk7pJehHxOSOWvGCM',
                          //   '1t1PDUS2U43OkfHnaRmY',
                          // ];
                          // for (var id in ooo) {
                          //   DocumentSnapshot<Map<String, dynamic>> offeee =
                          //       await FirebaseFirestore.instance
                          //           .collection('offers')
                          //           .doc(id)
                          //           .get();
                          //   print(offeee.data()!['status']);
                          //   print(offeee.data()!['garageId'] ?? 'GARAAfwe id');
                          // }
                          // QuerySnapshot<Map<String, dynamic>> offersSnap =
                          //     await FirebaseFirestore.instance
                          //         .collection('chats')
                          //         .get();
                          // List<ChatModel> offers = [];
                          // for (var offer in offersSnap.docs) {
                          //   offers.add(ChatModel.fromJson(offer));
                          // }
                          // for (var element in offers) {
                          //   DocumentSnapshot<Map<String, dynamic>> garageSnp =
                          //       await FirebaseFirestore.instance
                          //           .collection('offers')
                          //           .doc(element.offerId)
                          //           .get();
                          //   if (!garageSnp.exists) {
                          //     await FirebaseFirestore.instance
                          //         .collection('chats')
                          //         .doc(element.id)
                          //         .delete();
                          //   }

                          // if (element.offerRequestId == '') {

                          //   await FirebaseFirestore.instance
                          //       .collection('offers')
                          //       .doc(element.offerId)
                          //       .update({
                          //     'garageId': garageSnp.docs.first.id,
                          //   }); p
                          //   print(element.offerId +
                          //       ' goingggg' +
                          //       garageSnp.docs.first.id);
                          // }
                          // }
                        },
                        child: Text(
                          'App Version: 3.0.3.$currentVersion',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
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

class LogoutConfirmation extends StatelessWidget {
  const LogoutConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: userController.isDark ? primaryColor : Colors.white),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                Get.close(1);

                UserController().logout(userController.userModel!, context);
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.6, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: userController.isDark ? primaryColor : Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
              },
              child: Container(
                height: 50,
                width: Get.width * 0.6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: Center(
                  child: Text(
                    'Stay Login',
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
