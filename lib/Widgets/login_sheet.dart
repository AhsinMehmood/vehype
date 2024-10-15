import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

class LoginSheet extends StatelessWidget {
  final Function onSuccess;
  const LoginSheet({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(12),
      width: Get.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Get.close(1);
                  },
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Sign In to Continue',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(200),
              onTap: () async {
                final GoogleSignIn _googleSignIn = GoogleSignIn();
                try {
                  Get.dialog(LoadingDialog(), barrierDismissible: false);
                  // Trigger Google Sign-In flow
                  final GoogleSignInAccount? googleUser =
                      await _googleSignIn.signIn();

                  if (googleUser == null) {
                    // Get.close(1);

                    // return null; // The user canceled the sign-in
                  }

                  final GoogleSignInAuthentication googleAuth =
                      await googleUser!.authentication;

                  // Create a new credential
                  final AuthCredential credential =
                      GoogleAuthProvider.credential(
                    accessToken: googleAuth.accessToken,
                    idToken: googleAuth.idToken,
                  );

                  // Link Google account with anonymous user

                  try {
                    // Example: Link Google credential to an anonymous user
                    UserCredential userCredential = await FirebaseAuth
                        .instance.currentUser!
                        .linkWithCredential(credential);
                    print("Successfully linked: ${userCredential.user!.uid}");
                    toastification.show(
                      context: context,
                      title: Text('Successfully linked'),
                      style: ToastificationStyle.minimal,
                      type: ToastificationType.success,
                      autoCloseDuration: const Duration(seconds: 4),
                    );

                    String? name = userCredential.user!.displayName;
                    String? urlAvatar = userCredential.user!.photoURL;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userController.userModel!.userId)
                        .update({
                      'name': name,
                      'email': userCredential.user!.email,
                      'profileUrl': urlAvatar,
                    });
                    await Future.delayed(Duration(seconds: 1));
                    Get.close(1);

                    Get.close(1);

                    onSuccess();
                  } on FirebaseAuthException catch (e) {
                    Get.close(1);
                    GoogleSignIn().signOut();
                    GoogleSignIn().disconnect();

                    if (e.code == 'credential-already-in-use') {
                      toastification.show(
                        context: context,
                        title: Text(
                            'The account is already linked with another account.'),
                        style: ToastificationStyle.minimal,
                        type: ToastificationType.error,
                        autoCloseDuration: const Duration(seconds: 4),
                      );
                    } else if (e.code ==
                        'account-exists-with-different-credential') {
                      toastification.show(
                        context: context,
                        title: Text(
                            'The account already exists with a different credential.'),
                        style: ToastificationStyle.minimal,
                        type: ToastificationType.error,
                        autoCloseDuration: const Duration(seconds: 4),
                      );
                      // You can fetch available sign-in methods here:
                    } else if (e.code == 'requires-recent-login') {
                      toastification.show(
                        context: context,
                        title: Text(
                            'Recent login required. Please re-authenticate.'),
                        style: ToastificationStyle.minimal,
                        type: ToastificationType.error,
                        autoCloseDuration: const Duration(seconds: 4),
                      );
                    } else {
                      print('Error occurred: ${e.message}');
                    }
                  }
                } catch (e) {
                  Get.close(1);

                  print("Google sign-in failed: $e");
                  // return null;
                }
                // Get.bottomSheet(
                //   loginSheet(1),
                //   isScrollControlled: true,
                // );
                // LoginController.signInWithGoogle(context);
                // UserController userController =
                //     Provider.of<UserController>(context,
                //         listen: false);
                // userController.changeTabIndex(0);
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
                    color: userController.isDark ? Colors.white : primaryColor,
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
                            fontSize: 17,
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
              height: 10,
            ),
            if (Platform.isIOS)
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () async {
                  try {
                    Get.dialog(LoadingDialog(), barrierDismissible: false);
                    // Perform Apple Sign-In
                    final appleCredential =
                        await SignInWithApple.getAppleIDCredential(
                      scopes: [
                        AppleIDAuthorizationScopes.email,
                        AppleIDAuthorizationScopes.fullName,
                      ],
                    );

                    // Create OAuth credential for Firebase
                    final oauthCredential =
                        OAuthProvider("apple.com").credential(
                      idToken: appleCredential.identityToken,
                      accessToken: appleCredential.authorizationCode,
                    );

                    // Sign in the user or link with the Apple account
                    User user = FirebaseAuth.instance.currentUser!;

                    // Link the Apple credential with the anonymous user
                    UserCredential userCredential =
                        await user.linkWithCredential(oauthCredential);
                    // Get.close(1);
                    String? name = userCredential.user!.displayName;
                    String? urlAvatar = userCredential.user!.photoURL;
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userController.userModel!.userId)
                        .update({
                      'name': name,
                      'email': userCredential.user!.email,
                      'profileUrl': urlAvatar,
                    });
                    await Future.delayed(Duration(seconds: 1));
                    Get.close(1);

                    Get.close(1);
                    onSuccess();
                  } on FirebaseAuthException catch (e) {
                    Get.close(1);

                    if (e.code == 'credential-already-in-use') {
                      toastification.show(
                        context: context,
                        title: Text(
                            'Apple credential already in use by another account.'),
                        style: ToastificationStyle.minimal,
                        type: ToastificationType.error,
                        autoCloseDuration: const Duration(seconds: 4),
                      );
                    } else if (e.code ==
                        'account-exists-with-different-credential') {
                      toastification.show(
                        context: context,
                        title: Text(
                            'Account exists with a different credential. Use the correct sign-in method.'),
                        style: ToastificationStyle.minimal,
                        type: ToastificationType.error,
                        autoCloseDuration: const Duration(seconds: 4),
                      );
                    } else if (e.code == 'requires-recent-login') {
                      toastification.show(
                        context: context,
                        title: Text(
                            'Recent login required. Re-authenticate and try again.'),
                        style: ToastificationStyle.minimal,
                        type: ToastificationType.error,
                        autoCloseDuration: const Duration(seconds: 4),
                      );
                    } else {
                      Get.close(1);

                      print('Error occurred: ${e.message}');
                    }
                  } catch (e) {
                    Get.close(1);

                    print('Apple sign-in failed: $e');
                  }
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
                      color: changeColor(color: '#0A516F'),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            fontSize: 17,
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
                height: 10,
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
                    // fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'By tapping ‘Sign in’, you agree to our ',
                      style: TextStyle(
                        // fontFamily: 'Avenir',ss
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    _createClickableTextSpan(
                        'Terms',
                        userController.isDark
                            ? Colors.white.withOpacity(0.8)
                            : primaryColor.withOpacity(0.8), () {
                      launchUrl(Uri.parse(
                          'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                    }),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: '\nLearn how we process your data in our',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    _createClickableTextSpan(
                        ' Privacy Policy',
                        userController.isDark
                            ? Colors.white.withOpacity(0.8)
                            : primaryColor.withOpacity(0.8), () {
                      launchUrl(Uri.parse(
                          'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                    }),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        //fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    _createClickableTextSpan(
                        'Cookies Policy',
                        userController.isDark
                            ? Colors.white.withOpacity(0.8)
                            : primaryColor.withOpacity(0.8), () {
                      launchUrl(Uri.parse(
                          'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                    }),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        //  fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
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
