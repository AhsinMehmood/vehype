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

import '../Pages/service_set_opening_hours.dart';

import '../Pages/splash_page.dart';
import '../const.dart';
import '../providers/garage_provider.dart';

class LoginController {
  static Future<void> resetPassword(String email) async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      print('Password reset email sent');
      Get.close(2);

      Get.snackbar(
        'Password Reset',
        'A password reset link has been sent to your email.',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 4),
      );
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      print('Error: ${e.message}');
      _showSnackbar('Error: ${e.message}');

      // Handle specific error cases if needed
    }
  }

  static Future<void> signUpWithEmail({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      // await userCredential.user?.updateDisplayName(fullName);

      // Create user data in Firestore and navigate
      await createAccountGotoNextPage(userCredential, context,
          fullName: fullName);
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      _showSnackbar(e.message ?? 'Signup failed');
    } catch (e) {
      Get.close(1);
      _showSnackbar('Unexpected error: $e');
    }
  }

  static Future<void> loginWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await createAccountGotoNextPage(userCredential, context);
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      debugPrint(e.message);
      _showSnackbar(e.message ?? 'Login failed');
    } catch (e) {
      Get.close(1);
      _showSnackbar('Unexpected error: $e');
    }
  }

  static Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        _showSnackbar('Cancelled by user');
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth == null) {
        _showSnackbar('Authentication failed');
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      Get.dialog(const LoadingDialog(), barrierDismissible: false);

      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        await createAccountGotoNextPage(userCredential, context);
      } catch (e) {
        _showSnackbar('Something went wrong during sign in.');
        Get.close(1);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar(e.message ?? 'Firebase error occurred.');
    } catch (e) {
      _showSnackbar('Unexpected error: $e');
    }
  }

  static void _showSnackbar(String message) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      duration: const Duration(seconds: 3),
    ));
  }

  static Future<void> createAccountGotoNextPage(
      UserCredential userCredential, BuildContext context,
      {String fullName = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final user = userCredential.user!;
    final String userId = user.uid;

    prefs.setString('userId', userId);

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    // Only call this ONCE to close loading

    if (isNewUser) {
      // print('is New User');
      await _handleNewUser(user, fullName: fullName);
      // print('is New User after handle user');

      final userModel = await _getUserModel(userId);
      // print('is New User after get user model');

      // Get.close(1);

      _navigateToSelectAccountType(userModel);
    } else {
      final userModel = await _getUserModel(userId);

      await _handleExistingUser(context, userModel, userId);
    }
  }

  static Future<void> _handleNewUser(User user,
      {required String fullName}) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await docRef.set({
      'name': fullName.isEmpty ? user.displayName : fullName,
      'profileUrl': user.photoURL,
      'id': user.uid,
      'email': user.email,
    });
  }

  static Future<UserModel> _getUserModel(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return UserModel.fromJson(snapshot);
  }

  static void _navigateToSelectAccountType(UserModel userModel) {
    Get.close(1);
    Get.offAll(() => SelectAccountType(userModelAccount: userModel));
  }

  static Future<void> _handleExistingUser(
      BuildContext context, UserModel userModel, String userId) async {
    final userController = Provider.of<UserController>(context, listen: false);

    if (userModel.accountType.isEmpty) {
      _navigateToSelectAccountType(userModel);
      return;
    }

    if (userModel.adminStatus == 'blocked') {
      // Get.close(1);
      Get.offAll(() => const DisabledWidget());
      return;
    }

    final accountId = userId + userModel.accountType;
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(accountId)
        .get();

    final fullUserModel = UserModel.fromJson(userSnap);

    userController.getUserStream(accountId, onDataReceived: (_) {});
    OneSignal.login(accountId);

    final offersProvider = Provider.of<OffersProvider>(context, listen: false);
    final garageProvider = Provider.of<GarageProvider>(context, listen: false);

    if (userModel.accountType == 'provider') {
      offersProvider.startListening(fullUserModel);
      offersProvider.startListeningOffers(fullUserModel.userId);
    } else {
      garageProvider.fetchGarages(fullUserModel.userId);
      offersProvider.startListeningOwnerOffers(fullUserModel.userId);
    }

    Get.close(1);
    await navigateBasedOnProfile(
        userSnap, userModel.accountType, userController);
  }

  static Future<void> navigateBasedOnProfile(
      DocumentSnapshot<Map<String, dynamic>> userSnap,
      String accountType,
      UserController userController) async {
    final data = userSnap.data()!;
    final userModel = UserModel.fromJson(userSnap);

    if (data['lat'] == null || data['lat'] == 0.0) {
      Future.delayed(Duration.zero).then((_) {
        Get.bottomSheet(
          LocationPermissionSheet(
            userController: userController,
            isProvider: accountType == 'provider',
          ),
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
          ),
          isDismissible: false,
        );
      });
    } else if ((data['isBusinessSetup'] == null ||
            data['isBusinessSetup'] == false) &&
        accountType == 'provider') {
      Get.offAll(() => SetupBusinessProvider(
            placeDetails: null,
          ));
    } else if (!userModel.isSetOpeningHours && accountType == 'provider') {
      Get.offAll(() => ServiceSetOpeningHours(shopHours: {}));
    } else {
      Get.offAll(() => TabsPage());
    }
  }

  Future<void> loginWithApple(BuildContext context) async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        _showSnackbar('Sign in with Apple is not available on this device.');
        return;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      Get.dialog(const LoadingDialog(), barrierDismissible: false);

      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(oauthCredential);

        await createAccountGotoNextPage(userCredential, context);
      } catch (e) {
        Get.close(1);
        _showSnackbar('Apple login failed. Please try again.');
        debugPrint('Credential Sign-In Error: $e');
      }
    } on FirebaseAuthException catch (e) {
      Get.close(1);
      _showSnackbar('Firebase Auth Error: ${e.message}');
      debugPrint('Firebase Auth Exception: $e');
    } catch (e) {
      _showSnackbar('Unexpected error: $e');
      debugPrint('General Exception: $e');
    }
  }
}


/**
 * keytool -genkeypair -v -keystore vehype.keystore -alias vehypeAlias -keyalg RSA -keysize 2048 -validity 10000

 * java -jar pepk.jar --keystore=vehype.keystore --alias=vehypeAlias --output=output.zip  --signing-keystore=vehype.keystore --signing-key-alias=vehypeAlias --rsa-aes-encryption --encryption-key-path=encryption_public_key.pem
 */