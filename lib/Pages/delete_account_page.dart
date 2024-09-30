import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/splash_page.dart';
import 'package:vehype/const.dart';

import '../Widgets/loading_dialog.dart';

String removeSuffix(String userId) {
  if (userId.endsWith('provider')) {
    return userId.substring(0, userId.length - 'provider'.length);
  } else if (userId.endsWith('seeker')) {
    return userId.substring(0, userId.length - 'seeker'.length);
  }
  return userId; // Return the original ID if no suffix is found
}

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool isAgree = false;
  bool deleteBoth = false;
  UserModel? secondAccount;
  TextEditingController reason = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((onValue) {
      getSecondAccount();
    });
  }

  getSecondAccount() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    String secondAccountType =
        userModel.accountType == 'provider' ? 'seeker' : 'provider';

    // Construct the ID of the second account
    String secondAccountId =
        userModel.userId.replaceAll(userModel.accountType, secondAccountType);

    // Fetch the second account from Firestore
    DocumentSnapshot<Map<String, dynamic>> secondAccountSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(secondAccountId)
            .get();

    // Check if the second account exists
    if (secondAccountSnapshot.exists) {
      secondAccount = UserModel.fromJson(
          secondAccountSnapshot); // Assuming UserModel has a fromDocument method
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);
    String accountName =
        userModel.accountType == 'provider' ? 'Vehicle Owner' : 'Service Owner';
    String accountNames = userModel.accountType == 'provider'
        ? 'Vehicle Owners'
        : 'Service Owners';

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            // size: 29,
            color: userController.isDark ? Colors.white : primaryColor,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Delete Account',
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: userController.isDark ? Colors.white : primaryColor
              // color: Colors.black,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(
                height: 0,
              ),
              Text(
                'Thank you for trying our app!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              // const SizedBox(
              //   height: 10,
              // ),
              Text(
                'All active and in-progress requests will be canceled, and $accountNames will be notified.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    isAgree = !isAgree;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                          activeColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          checkColor: userController.isDark
                              ? Colors.green
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          value: isAgree,
                          onChanged: (s) {
                            setState(() {
                              isAgree = !isAgree;
                            });
                          }),
                    ),
                    const SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'I acknowledge VEHYPE\'s ratings policy. ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor
                                      //  color: Colors.black,
                                      ),
                                ),
                                TextSpan(
                                  text: 'See how rating works',
                                  style: TextStyle(
                                    decorationColor: Colors.blueAccent,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await launchUrl(Uri.parse(
                                          'https://vehype.com/help#'));
                                    },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (secondAccount != null)
                Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    if (!deleteBoth)
                      Text(
                        'Please note that your $accountName account will remain active. You will still be able to log in to the $accountName account using your current email address. This ensures that your services and associated data are preserved, and you can continue to manage them without interruption.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          deleteBoth = !deleteBoth;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 2,
                            child: Checkbox(
                                activeColor: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                checkColor: userController.isDark
                                    ? Colors.green
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                value: deleteBoth,
                                onChanged: (s) {
                                  setState(() {
                                    deleteBoth = !deleteBoth;
                                  });
                                }),
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'I would like to delete both accounts.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor
                                      //  color: Colors.black,
                                      ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),

              SizedBox(
                height: secondAccount == null ? 140 : 30,
              ),
              ElevatedButton(
                  onPressed: !isAgree
                      ? null
                      : () async {
                          Get.dialog(LoadingDialog(),
                              barrierDismissible: false);

                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          final String userId =
                              sharedPreferences.getString('userId')!;
                          await userController
                              .handleUserAccountActions(userModel);
                          if (deleteBoth) {
                            await updateAndDeleteAccount(defaultImage);
                          } else {
                            await deleteOneAccount();
                          }

                          // Check if we need to delete the user account
                          if (deleteBoth || secondAccount == null) {
                            await userController.deleteUserAccount(userId);
                          }
                          try {
                            await GoogleSignIn().disconnect();
                          } catch (e) {}

                          OffersProvider offersProvider =
                              Provider.of<OffersProvider>(context,
                                  listen: false);
                          OneSignal.logout();

                          userController.closeStream();

                          offersProvider.stopListening();
                          sharedPreferences.clear();
                          userController.changeTabIndex(0);
                          Get.close(1); // Close the loading dialog

                          await FirebaseAuth.instance.signOut();
                          toastification.show(
                              context: context,
                              title: Text(
                                  'The account has been deleted successfully!'),
                              autoCloseDuration: Duration(seconds: 4),
                              type: ToastificationType.success,
                              style: ToastificationStyle.flatColored);

                          // Get.offAll(() => SplashPage());
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      maximumSize: Size(Get.width * 0.9, 50),
                      minimumSize: Size(Get.width * 0.9, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      )),
                  child: const Text(
                    'Delete account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  )),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteOneAccount() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String userId = sharedPreferences.getString('userId')!;

    // Get.dialog(LoadingDialog(), barrierDismissible: false);
    // userController.streamSubscription?.cancel();
    // Reference to the user's document (Primary Account)
    DocumentReference primaryAccountRef =
        FirebaseFirestore.instance.collection('users').doc(userModel.userId);

    WriteBatch batch = FirebaseFirestore.instance.batch();
    // Reference to the Firebase Auth user document
    DocumentReference authUserRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await OneSignal.logout();

    // Update primary account
    batch.update(primaryAccountRef, {
      'name': 'Private User',
      'imageUrl': '',
      'isDelete': true,
    });
    batch.update(authUserRef, {
      'accountType': '',
    });
    // batch.delete(authUserRef);
    // sharedPreferences.clear();

    try {
      // Commit the batch
      await batch.commit();
      // print("Both accounts updated and the user account deleted successfully");
    } catch (e) {
      // print("Failed to update accounts or delete the user account: $e");/
    }
  }

  Future<void> updateAndDeleteAccount(String newImageUrl) async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    final UserModel userModel = userController.userModel!;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String userId = sharedPreferences.getString('userId')!;

    // Get.dialog(LoadingDialog(), barrierDismissible: false);
    userController.streamSubscription?.cancel();
    String secondAccountType =
        userModel.accountType == 'provider' ? 'seeker' : 'provider';

    // Construct the second account ID
    String secondAccountId =
        userModel.userId.replaceAll(userModel.accountType, secondAccountType);

    // Reference to the user's document (Primary Account)
    DocumentReference primaryAccountRef =
        FirebaseFirestore.instance.collection('users').doc(userModel.userId);

    // Reference to the second account's document
    DocumentReference secondAccountRef =
        FirebaseFirestore.instance.collection('users').doc(secondAccountId);

    // Reference to the Firebase Auth user document
    DocumentReference authUserRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    // Batch to update both documents atomically
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Update primary account
    batch.update(primaryAccountRef, {
      'name': 'Private User',
      'imageUrl': newImageUrl,
      'isDelete': true,
    });

    // Update second account
    batch.update(secondAccountRef, {
      'name': 'Private User',
      'imageUrl': newImageUrl,
      'isDelete': true,
    });

    // Delete the Firebase Auth user document
    batch.delete(authUserRef);
    // sharedPreferences.clear();

    try {
      // Commit the batch
      await batch.commit();
    } catch (e) {}
  }
}
