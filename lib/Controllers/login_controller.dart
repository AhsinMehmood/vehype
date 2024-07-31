// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/select_account_type_page.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:crypto/crypto.dart';

import '../Pages/splash_page.dart';

class LoginController {
  static Future signInWithGoogle(BuildContext context) async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
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
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        String userId = userCredential.user!.uid;
        String? email = userCredential.user!.email;
        String? name = userCredential.user!.displayName;

        Mixpanel mixpanel = await Mixpanel.init(
            'c40aeb8e3a8f1030b811314d56973f5a',
            trackAutomaticEvents: true);
        mixpanel.identify(userId);

        mixpanel.getPeople().set('\$name', name ?? '');
        sharedPreferences.setString('userId', userId);
        if (userCredential.additionalUserInfo!.isNewUser) {
          String? name = userCredential.user!.displayName;
          String? urlAvatar = userCredential.user!.photoURL;
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
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

          Get.close(1);

          if (userModel.accountType == '') {
            Get.offAll(() => SelectAccountType(
                  userModelAccount: userModel,
                ));
          } else {
            if (userModel.adminStatus == 'blocked') {
              Get.offAll(() => const DisabledWidget());
            } else {
              userController.getUserStream(userId + userModel.accountType);
              DocumentSnapshot<Map<String, dynamic>> accountType =
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get();
              OneSignal.login(userId + userModel.accountType);
              // Get.offAll(() => const TabsPage());
              Get.offAll(() => const TabsPage());
            }
          }
        }
      } else {
        Get.close(1);
        Get.showSnackbar(GetSnackBar(
          message: 'Cancelled by user',
          duration: const Duration(seconds: 2),
        ));
      }
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      Get.showSnackbar(GetSnackBar(
        message: e.message,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  loginWithApple(BuildContext context) async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
      );

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

        // if(){}
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        UserModel userModel = UserModel.fromJson(snapshot);
        Get.close(1);
        if (userModel.accountType == '') {
          Get.offAll(() => SelectAccountType(
                userModelAccount: userModel,
              ));
        } else {
          if (userModel.adminStatus == 'blocked') {
            Get.offAll(() => const DisabledWidget());
          } else {
            userController.getUserStream(userId + userModel.accountType);
            DocumentSnapshot<Map<String, dynamic>> accountType =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get();
            OneSignal.login(userId + userModel.accountType);

            Get.offAll(() => const TabsPage());
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.close(1);

      Get.showSnackbar(GetSnackBar(
        message: e.message,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}


/**
 * keytool -genkeypair -v -keystore vehype.keystore -alias vehypeAlias -keyalg RSA -keysize 2048 -validity 10000

 * java -jar pepk.jar --keystore=vehype.keystore --alias=vehypeAlias --output=output.zip  --signing-keystore=vehype.keystore --signing-key-alias=vehypeAlias --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem
 */