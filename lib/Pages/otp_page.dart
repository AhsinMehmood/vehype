import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  TextEditingController otpController = TextEditingController();
  bool isResendAvailable = false;
  int resendCountdown = 30;
  Timer? _timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sendOtp(widget.phoneNumber);
  }

  // Step 1: Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    setState(() {
      isResendAvailable = false;
      resendCountdown = 30;
    });
    startResendTimer();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await linkPhoneNumber(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("Error", e.message ?? "Verification failed",
            backgroundColor: Colors.red, colorText: Colors.white);
      },
      codeSent: (String verification, int? resendToken) {
        verificationId = verification;
        setState(() {});
        Get.snackbar("OTP Sent", "Check your phone for the OTP",
            backgroundColor: Colors.green, colorText: Colors.white);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("OTP Timeout");
      },
    );
  }

  // Step 2: Verify OTP
  Future<void> verifyOtp() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (otpController.text.isEmpty || otpController.text.length < 6) {
        Get.snackbar("Error", "A 6 digit OTP is required!",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpController.text);

      await linkPhoneNumber(credential);
    } catch (e) {
      Get.snackbar("Verification Failed", "Invalid OTP. Try again",
          backgroundColor: Colors.red, colorText: Colors.white);
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> linkPhoneNumber(PhoneAuthCredential credential) async {
    User? user = _auth.currentUser;
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    if (user == null) {
      Get.snackbar("Error", "No authenticated user found.",
          backgroundColor: Colors.red, colorText: Colors.white);

      return;
    }

    try {
      // Try linking the phone number to the current user
      await user.linkWithCredential(credential);

      // Update Firestore user data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userController.userModel!.userId)
          .update({'isBusinessSetup': true, 'contactInfo': widget.phoneNumber});

      // Navigate to Home
      Get.offAll(() => TabsPage());
      Get.snackbar("Success", "Phone number verified successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked' ||
          e.code == 'credential-already-in-use') {
        // ✅ Phone number is already linked to the same user → Simply login
        await _auth.signInWithCredential(credential);

        Get.offAll(() => TabsPage());
        Get.snackbar("Success", "Logged in successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        return;
      }

      // ❌ Handle other specific Firebase Auth errors
      String errorMessage = "Failed to verify phone number.";
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = "The OTP entered is incorrect. Please try again.";
          break;
        case 'invalid-verification-id':
          errorMessage = "Invalid verification ID. Please request a new OTP.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many attempts. Please try again later.";
          break;
        case 'session-expired':
          errorMessage =
              "The verification session has expired. Please resend the OTP.";
          break;
        default:
          errorMessage = e.message ?? "Something went wrong. Please try again.";
          break;
      }

      Get.snackbar("Error", errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Resend Timer
  void startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendCountdown > 0) {
        setState(() {
          resendCountdown--;
        });
      } else {
        setState(() {
          isResendAvailable = true;
          timer.cancel();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new,
            )),
        title: Text(
          'Verify Phone',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              SvgPicture.asset('assets/otp.svg'),
              const SizedBox(height: 40),
              Text(
                "Enter the 6-digit code sent to",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 5),
              Text(
                widget.phoneNumber,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: otpController,
                keyboardType: TextInputType.number,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor:
                      userController.isDark ? Colors.grey[800]! : Colors.white,
                  selectedFillColor: Colors.blueGrey.withOpacity(0.2),
                  inactiveFillColor: Colors.white,
                  activeColor: Colors.blueGrey,
                  selectedColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: isLoading ? null : verifyOtp,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        userController.isDark ? Colors.white : primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    elevation: 0.0,
                    minimumSize: Size(Get.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    )),
                child: Text('Verify',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: userController.isDark
                            ? primaryColor
                            : Colors.white)),
              ),
              const SizedBox(height: 20),
              isResendAvailable
                  ? TextButton(
                      onPressed:
                          isLoading ? null : () => sendOtp(widget.phoneNumber),
                      child: Text(
                        "Resend Code",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    )
                  : Text(
                      "Resend in ${resendCountdown}s",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
