// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/login_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Widgets/loading_dialog.dart';
import 'select_account_type_page.dart';

class ChooseAccountTypePage extends StatelessWidget {
  const ChooseAccountTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Text(
                'VEHYPE',
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 28,
                  fontFamily: poppinsBold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'VEHYPE is an app based on ratings given in-between vehicle owners and service providers.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // padding: const EdgeInsets.all(25),
                      width: Get.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(200),
                              onTap: () {
                                // Get.bottomSheet(
                                //   loginSheet(1),
                                //   isScrollControlled: true,
                                // );
                                LoginController.signInWithGoogle(context);
                                UserController userController =
                                    Provider.of<UserController>(context,
                                        listen: false);
                                userController.changeTabIndex(0);
                                // GarageController()
                                //     .callGetAndSaveDataToFirestore();
                                // Get.to(() => const CompleteProfile());
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0.0,
                                child: Container(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                    left: 5,
                                    right: 5,
                                  ),
                                  width: Get.width * 0.8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    // border: Border.all(
                                    //   color: userController.isDark
                                    //       ? Colors.yellowAccent
                                    //       : Colors.green,
                                    // ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/google.png',
                                        height: 30,
                                        width: 30,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        'Sign in with Google',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: userController.isDark
                                                ? primaryColor
                                                : Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            if (Platform.isIOS)
                              InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () {
                                  LoginController().loginWithApple(context);
                                  UserController userController =
                                      Provider.of<UserController>(context,
                                          listen: false);
                                  userController.changeTabIndex(0);
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0.0,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                    ),
                                    width: Get.width * 0.8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.black,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/apple.png',
                                          height: 30,
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        Text(
                                          'Sign in with Apple',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (Platform.isIOS)
                              const SizedBox(
                                height: 15,
                              ),
                            InkWell(
                              onTap: () async {
                                Get.dialog(const LoadingDialog(),
                                    barrierDismissible: false);

                                await FirebaseAuth.instance.signInAnonymously();
                                User? user = FirebaseAuth.instance.currentUser;

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user!.uid)
                                    .set({
                                  'name': 'Guest User',
                                  // 'accountType': 'owner',
                                  'profileUrl':
                                      'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/ic_guest.png?alt=media&token=e19d36fd-59b1-4f6e-899b-d98a1ef2ce6e',
                                  'id': user.uid,
                                  'email': 'No email set',
                                });
                                UserController userController =
                                    Provider.of<UserController>(context,
                                        listen: false);
                                userController.changeTabIndex(0);
                                DocumentSnapshot<Map<String, dynamic>>
                                    snapshot = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(user.uid)
                                        .get();
                                UserModel userModel =
                                    UserModel.fromJson(snapshot);

                                Get.close(1);
                                Get.offAll(() => SelectAccountType(
                                      userModelAccount: userModel,
                                    ));
                                // userController.getUserStream(user.uid);
                              },
                              child: Text(
                                'Continue as a Guest',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  // textBaseline: TextBaseline.ideographic,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          'By tapping ‘Sign in’, you agree to our ',
                                      style: TextStyle(
                                        // fontFamily: 'Avenir',ss
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                      ),
                                    ),
                                    _createClickableTextSpan(
                                        'Terms',
                                        userController.isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : primaryColor.withOpacity(0.8),
                                        () {
                                      launchUrl(Uri.parse(
                                          'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                                    }),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          '\nLearn how we process your data in our',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                      ),
                                    ),
                                    _createClickableTextSpan(
                                        ' Privacy Policy',
                                        userController.isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : primaryColor.withOpacity(0.8),
                                        () {
                                      launchUrl(Uri.parse(
                                          'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                                    }),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyle(
                                        fontFamily: 'Avenir',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                      ),
                                    ),
                                    _createClickableTextSpan(
                                        'Cookies Policy',
                                        userController.isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : primaryColor.withOpacity(0.8),
                                        () {
                                      launchUrl(Uri.parse(
                                          'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                                    }),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        fontFamily: 'Avenir',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
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
                              height: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: primaryColor,
                    //         elevation: 1.0,
                    //         fixedSize: Size(Get.width * 0.7, 50),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(15),
                    //         ),
                    //       ),
                    //       onPressed: () {
                    //         Get.bottomSheet(loginSheet(),
                    //             isScrollControlled: true);
                    //       },
                    //       child: Center(
                    //         child: Text(
                    //           'I\'m Vehicle Owner',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 17,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       )),
                    // ),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    // ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.black,
                    //       elevation: 1.0,
                    //       fixedSize: Size(Get.width * 0.7, 50),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(15),
                    //       ),
                    //     ),
                    //     onPressed: () {

                    //     },
                    //     child: Center(
                    //       child: Text(
                    //         'I\'m Service Owner',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 17,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     )),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget loginSheet(int loginType) {
    return BottomSheet(
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // backgroundColor: Colo,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(200),
                    onTap: () {
                      // LoginController.signInWithGoogle('provider', context);
                      // LoginController.signInWithGoogle(
                      //     userProvider: userProvider, context: context);
                      // Get.to(() => const CompleteProfile());
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        width: Get.width * 0.7,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'I\'m Service Owner',
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(200),
                    onTap: () {
                      // Get.close(1);

                      // LoginController.signInWithGoogle('seeker', context);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200),
                      ),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        width: Get.width * 0.7,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Color.fromARGB(255, 3, 0, 10),
                            border: Border.all(
                              color: Color.fromARGB(255, 3, 0, 10),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'I\'m Vehicle Owner',
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            )
                          ],
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
        });
  }

  TextSpan _createClickableTextSpan(
      String text, Color color, VoidCallback onTap) {
    return TextSpan(
      text: '$text ',
      style: TextStyle(
        color: color,
        fontSize: 16,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }
}
