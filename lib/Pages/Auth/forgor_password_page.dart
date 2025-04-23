import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/login_controller.dart';

import 'package:vehype/Controllers/user_controller.dart';

import 'package:vehype/const.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isValidEmail(String email) {
    final trimmedEmail = email.trim();
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(trimmedEmail);
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back_ios_new))),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(height: Get.height * 0.05),

                      /// Title
                      Text(
                        'Reset Your Password',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: userController.isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      /// Subtitle
                      Text(
                        'Enter your registered email and we’ll send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white70
                              : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// Email Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: userController.isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'e.g. johndoe@example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: userController.isDark
                                  ? Colors.white54
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                      ),
                      SizedBox(height: Get.height * 0.2),

                      /// Send Email Button
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
                        onPressed: () async {
                          if (emailController.text.isEmpty) {
                            Get.showSnackbar(GetSnackBar(
                              message: 'Email is required!',
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
                          LoginController.resetPassword(
                              emailController.text.trim());
                        },
                        child: const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
