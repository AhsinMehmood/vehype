import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/splash_page.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        await _handleLogout();
      } else {}
    });
  }

  Future<void> _handleLogout() async {
    await OneSignal.logout();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {}

    Get.offAll(() => SplashPage());
  }
}
