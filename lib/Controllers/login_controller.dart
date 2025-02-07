// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:mixpanel_flutter/mixpanel_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/select_account_type_page.dart';
import 'package:vehype/Pages/setup_business_provider.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';

import '../Pages/splash_page.dart';
import '../const.dart';

class LoginController {
  static Future signInWithGoogle(BuildContext context) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        String emailSeeker = 'seeker@gmail.com';
        String emailProvider = 'provider@gmail.com';
        try {
          Get.dialog(const LoadingDialog(), barrierDismissible: false);

          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          String userId = userCredential.user!.uid;
          String? email = userCredential.user!.email;
          String? name = userCredential.user!.displayName;

          // Mixpanel mixpanel = await Mixpanel.init(
          //     'c40aeb8e3a8f1030b811314d56973f5a',
          //     trackAutomaticEvents: true);
          // mixpanel.identify(userId);

          // mixpanel.getPeople().set('\$name', name ?? '');
          sharedPreferences.setString('userId', userId);
          if (userCredential.additionalUserInfo!.isNewUser) {
            String? name = userCredential.user!.displayName;
            String? urlAvatar = userCredential.user!.photoURL;
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .set({
              'name': name,
              // 'accountType': 'owner',
              'profileUrl': urlAvatar,
              'id': userId,
              'email': email,
            });

            DocumentSnapshot<Map<String, dynamic>> snapshot =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get();
            UserModel userModel = UserModel.fromJson(snapshot);

            Get.close(1);

            Get.offAll(() => SelectAccountType(
                  userModelAccount: userModel,
                ));
          } else {
            UserController userController =
                Provider.of<UserController>(context, listen: false);
            // userController.getUserStream(userId);

            // if(){}
            DocumentSnapshot<Map<String, dynamic>> snapshot =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get();
            UserModel userModel = UserModel.fromJson(snapshot);

            if (userModel.accountType == '') {
              Get.close(1);

              Get.offAll(() => SelectAccountType(
                    userModelAccount: userModel,
                  ));
            } else {
              if (userModel.adminStatus == 'blocked') {
                Get.close(1);

                Get.offAll(() => const DisabledWidget());
              } else {
                OffersProvider offersProvider =
                    Provider.of<OffersProvider>(context, listen: false);
                userController.getUserStream(
                  userId + userModel.accountType,
                  onDataReceived: (userModel) {},
                );
                DocumentSnapshot<Map<String, dynamic>> usersnap =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId + userModel.accountType)
                        .get();
                if (userModel.accountType == 'provider') {
                  offersProvider.startListening(UserModel.fromJson(usersnap));
                  offersProvider.startListeningOffers(
                      UserModel.fromJson(usersnap).userId);
                } else {
                  offersProvider.startListeningOwnerOffers(
                      UserModel.fromJson(usersnap).userId);
                }
                // Get.close(1);/

                // await OneSignal.Notifications.requestPermission(true);
                OneSignal.login(userId + userModel.accountType);
                DocumentSnapshot<Map<String, dynamic>> userSnapss =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId + userModel.accountType)
                        .get();
                Get.close(1);
                // log(userSnapss.)

                // Get.offAll(() => const TabsPage());
                if (userSnapss.data()!['lat'] == null ||
                    userSnapss.data()!['lat'] == 0.0) {
                  Future.delayed(const Duration(seconds: 0)).then((s) {
                    Get.bottomSheet(
                      LocationPermissionSheet(
                        userController: userController,
                        isProvider:
                            userId + userModel.accountType == 'provider',
                      ),
                      backgroundColor:
                          userController.isDark ? primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      isDismissible: false,
                      // enableDrag: false,
                    );
                  });
                } else {
                  if (userSnapss.data()!['isBusinessSetup'] == null ||
                      userSnapss.data()!['isBusinessSetup'] == false) {
                    Get.offAll(() => SetupBusinessProvider());
                  } else {
                    Get.offAll(() => const TabsPage());
                  }
                }
              }
            }
          }
        } catch (e) {
          Get.close(1);
          Get.showSnackbar(GetSnackBar(
            message: 'Cancelled by user',
            duration: const Duration(seconds: 2),
          ));
        }
      } else {
        // Get.close(1);
        Get.showSnackbar(GetSnackBar(
          message: 'Cancelled by user',
          duration: const Duration(seconds: 2),
        ));
      }
    } on FirebaseAuthException catch (e) {
      // Get.close(1);
      Get.showSnackbar(GetSnackBar(
        message: e.message,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  loginWithApple(BuildContext context) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      // Check if Sign in with Apple is available
      bool isAvail = await SignInWithApple.isAvailable();
      if (!isAvail) {
        throw Exception('Sign in with Apple is not available on this device.');
      }

      // Log for debugging purposes
      // Get.dialog(const LoadingDialog(), barrierDismissible: false);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential using the received token
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      Get.dialog(const LoadingDialog(), barrierDismissible: false);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      String userId = userCredential.user!.uid;
      String? email = userCredential.user!.email;
      String? name = userCredential.user!.displayName;

      sharedPreferences.setString('userId', userId);

      if (userCredential.additionalUserInfo!.isNewUser) {
        String? urlAvatar = userCredential.user!.photoURL;
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': name,
          'profileUrl': urlAvatar,
          'id': userId,
          'email': email,
        });

        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        UserModel userModel = UserModel.fromJson(snapshot);

        Get.close(1);
        Get.offAll(() => SelectAccountType(userModelAccount: userModel));
      } else {
        UserController userController =
            Provider.of<UserController>(context, listen: false);

        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        UserModel userModel = UserModel.fromJson(snapshot);

        if (userModel.accountType == '') {
          Get.close(1);

          Get.offAll(() => SelectAccountType(userModelAccount: userModel));
        } else {
          if (userModel.adminStatus == 'blocked') {
            Get.close(1);

            Get.offAll(() => const DisabledWidget());
          } else {
            userController.getUserStream(userId + userModel.accountType);
            OneSignal.login(userId + userModel.accountType);

            DocumentSnapshot<Map<String, dynamic>> userSnapss =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId + userModel.accountType)
                    .get();
            Get.close(1);

            if (userSnapss.data()!['lat'] == null ||
                userSnapss.data()!['lat'] == 0.0) {
              Future.delayed(const Duration(seconds: 0)).then((s) {
                Get.bottomSheet(
                  LocationPermissionSheet(
                    userController: userController,
                    isProvider: userId + userModel.accountType == 'provider',
                  ),

                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  isDismissible: false,
                  // enableDrag: false,
                );
              });
            } else {
              if (userSnapss.data()!['isBusinessSetup'] == null ||
                  userSnapss.data()!['isBusinessSetup'] == false) {
                Get.offAll(() => SetupBusinessProvider());
              } else {
                Get.offAll(() => const TabsPage());
              }
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      Get.showSnackbar(GetSnackBar(
        message: 'Firebase Auth Error: ${e.message}',
        duration: const Duration(seconds: 3),
      ));
      print('Firebase Auth Exception: $e');
    } catch (e) {
      // Get.close(1);
      Get.showSnackbar(GetSnackBar(
        message: 'Error: $e',
        duration: const Duration(seconds: 2),
      ));
      print('Exception: $e');
    }
  }
}


/**
 * keytool -genkeypair -v -keystore vehype.keystore -alias vehypeAlias -keyalg RSA -keysize 2048 -validity 10000

 * java -jar pepk.jar --keystore=vehype.keystore --alias=vehypeAlias --output=output.zip  --signing-keystore=vehype.keystore --signing-key-alias=vehypeAlias --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem
 */