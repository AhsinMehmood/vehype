import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../../Controllers/login_controller.dart';
import '../../Controllers/offers_provider.dart';
import '../../Widgets/loading_dialog.dart';

import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  bool isShowPassword = false;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Welcome to VEHYPE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Park. Request. Get Estimates.\nPowered by AI.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: TextFormField(
                        controller: fullNameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                6.0), // Optional for rounded corners
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: TextFormField(
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                6.0), // Optional for rounded corners
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: TextFormField(
                        controller: passwordController,
                        textInputAction: TextInputAction.done,
                        obscureText: !isShowPassword,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isShowPassword = !isShowPassword;
                                });
                              },
                              icon: Icon(!isShowPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined)),
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                6.0), // Optional for rounded corners
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    maximumSize: Size(Get.width * 0.9, 50),
                    minimumSize: Size(Get.width * 0.9, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    backgroundColor: userController.isDark
                        ? const Color.fromARGB(255, 80, 109, 123)
                        : primaryColor,
                  ),
                  onPressed: () {
                    if (fullNameController.text.isEmpty) {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Name is required!',
                        duration: Duration(seconds: 3),
                      ));
                      return;
                    }
                    if (emailController.text.isEmpty) {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Email is required!',
                        duration: Duration(seconds: 3),
                      ));
                      return;
                    }
                    if (passwordController.text.isEmpty) {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Password is required!',
                        duration: Duration(seconds: 3),
                      ));
                      return;
                    }
                    if (!isValidEmail(emailController.text)) {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Email is invalid!',
                        duration: Duration(seconds: 3),
                      ));
                      return;
                    }
                    LoginController.signUpWithEmail(
                        context: context,
                        fullName: fullNameController.text,
                        email: emailController.text,
                        password: passwordController.text);
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    Get.offAll(() => LoginPage());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Login here',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('Or'),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // if (Platform.isIOS)
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        LoginController.signInWithGoogle(context);
                        UserController userController =
                            Provider.of<UserController>(context, listen: false);
                        userController.changeTabIndex(0);
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.only(
                          top: 5,
                          bottom: 5,
                          left: 5,
                          right: 5,
                        ),
                        width: Get.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/google.png',
                              height: 30,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (Platform.isIOS)
                      const SizedBox(
                        height: 10,
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
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 5,
                            right: 5,
                          ),
                          width: Get.width,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/apple.png',
                                height: 30,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Continue with Apple',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    try {
                      Get.dialog(const LoadingDialog(),
                          barrierDismissible: false);

                      await FirebaseAuth.instance.signInAnonymously();

                      User? user = FirebaseAuth.instance.currentUser;
                      SharedPreferences sharedpref =
                          await SharedPreferences.getInstance();
                      sharedpref.setString('userId', user!.uid);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        'name': 'Guest User',
                        // 'accountType': 'owner',
                        'profileUrl':
                            'https://firebasestorage.googleapis.com/v0/b/vehype-386313.appspot.com/o/ic_guest.png?alt=media&token=e19d36fd-59b1-4f6e-899b-d98a1ef2ce6e',
                        'id': user.uid,
                        'email': 'No email set',
                      });
                      UserController userController =
                          Provider.of<UserController>(context, listen: false);
                      userController.changeTabIndex(0);
                      // userController.getUserStream(user.uid);
                      final offersProvider =
                          Provider.of<OffersProvider>(context, listen: false);
                      Get.close(1);
                      userController.setAsUser(offersProvider);
                    } catch (e) {
                      Get.close(1);
                      print(e);
                      Get.showSnackbar(
                        GetSnackBar(
                          message: 'Something went wrong, please try again!',
                          duration: Duration(seconds: 3),
                          snackPosition: SnackPosition.TOP,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 5,
                      right: 5,
                    ),
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor)),
                    child: Center(
                      child: Text(
                        'Continue as a Guest',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                          text: 'By signing, you agree to our ',
                          style: TextStyle(
                            // fontFamily: 'Avenir',ss
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
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
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: '\nLearn how we process your data in our',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
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
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
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
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final trimmedEmail = email.trim();
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(trimmedEmail);
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
