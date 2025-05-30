// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/Invoice/all_product_and_services.dart';
import 'package:vehype/Pages/Provider%20Verification/become_a_provider.dart';
import 'package:vehype/Pages/edit_profile_page.dart';
import 'package:vehype/Pages/theme_page.dart';
import 'package:vehype/Widgets/login_sheet.dart';
import 'package:vehype/const.dart';

import '../Controllers/offers_provider.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import 'admin_home_page.dart';
import 'blocked_users.dart';
import 'comments_page.dart';
import 'delete_account_page.dart';
import 'my_fav_page.dart';
import 'splash_page.dart';
// import 'orders_history_seeker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      //   title: Text(
      //     'VEHYPE',
      //     style: TextStyle(
      //       color: userController.isDark ? Colors.white : primaryColor,
      //       fontSize: 20,
      //       fontWeight: FontWeight.w800,
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 0,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (userModel.isGuest) {
                        Get.bottomSheet(LoginSheet(
                          onSuccess: () {
                            Get.to(() => EditProfilePage());
                          },
                        ));
                      } else {
                        Get.to(() => EditProfilePage());
                      }
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: CachedNetworkImage(
                            placeholder: (context, url) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorWidget: (context, url, error) =>
                                const SizedBox.shrink(),
                            imageUrl: userModel.profileUrl,

                            width: 75,
                            height: 75,
                            fit: BoxFit.fill,

                            //cancelToken: cancellationToken,
                          ),
                        ),
                        if (userModel.accountType == 'provider')
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: userModel.isVerified ? 30 : null,
                              // width: 30,
                              decoration: BoxDecoration(
                                  color: userModel.isVerified
                                      ? Colors.green.withOpacity(0.9)
                                      : Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Center(
                                child: Text(
                                  userModel.isVerified
                                      ? 'VERIFIED'
                                      : 'NON\nVERIFIED',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: userModel.isVerified ? 12 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userModel.name,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () {
                          if (userModel.isGuest) {
                            Get.bottomSheet(LoginSheet(
                              onSuccess: () {
                                Get.to(() => CommentsPage(data: userModel));
                              },
                            ));
                          } else {
                            Get.to(() => CommentsPage(data: userModel));
                          }
                        },
                        child: Row(
                          children: [
                            RatingBarIndicator(
                              rating: userModel.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 24.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              userModel.ratings.length.toString(),
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        userModel.email,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (userModel.accountType == 'seeker')
                        InkWell(
                          onTap: () {
                            // FlutterClipboard.copy(userModel.id)
                            //     .then((value) => Get.showSnackbar(GetSnackBar(
                            //           message: 'User id copied',
                            //           duration: const Duration(seconds: 2),
                            //         )));
                          },
                          child: Text(
                            'Plan : ${userModel.plan.toUpperCase()}',
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      if (userController.isHaveProvider)
                        Container(
                          width: Get.width,
                          padding: const EdgeInsets.all(12),
                          height: 55,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2),
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    userModel.accountType == 'provider'
                                        ? Icons.garage
                                        : Icons.car_repair,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    userModel.accountType == 'provider'
                                        ? 'Switch to Vehicle Owner'
                                        : 'Switch to Service Provider',
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                  value: userModel.accountType == 'provider',
                                  onChanged: (s) async {
                                    if (userModel.accountType == 'provider') {
                                      try {
                                        Get.dialog(const LoadingDialog(),
                                            barrierDismissible: false);
                                        // User user = FirebaseAuth.instance.currentUser;
                                        SharedPreferences sharedPreferences =
                                            await SharedPreferences
                                                .getInstance();
                                        String realUserId = sharedPreferences
                                                .getString('userId') ??
                                            '';

                                        OneSignal.logout();
                                        OffersProvider offersProvider =
                                            Provider.of<OffersProvider>(context,
                                                listen: false);
                                        offersProvider.stopListening();
                                        // offersProvider.stopListening();
                                        // offersProvider.stopListening();

                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(realUserId)
                                            .update({
                                          'accountType': 'seeker',
                                        });
                                        userController.closeStream();
                                        // userController.getUserStream(userId)/
                                        Get.close(1);
                                        Get.offAll(() => SplashPage());
                                        userController.changeTabIndex(0);
                                      } catch (e) {
                                        Get.close(1);
                                      }
                                    } else {
                                      try {
                                        Get.dialog(const LoadingDialog(),
                                            barrierDismissible: false);
                                        // User user = FirebaseAuth.instance.currentUser;
                                        SharedPreferences sharedPreferences =
                                            await SharedPreferences
                                                .getInstance();
                                        String realUserId = sharedPreferences
                                                .getString('userId') ??
                                            '';
                                        OffersProvider offersProvider =
                                            Provider.of<OffersProvider>(context,
                                                listen: false);
                                        offersProvider.stopListening();
                                        OneSignal.logout();
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(realUserId)
                                            .update({
                                          'accountType': 'provider',
                                        });
                                        userController.closeStream();

                                        Get.close(1);
                                        Get.offAll(() => SplashPage());
                                        userController.changeTabIndex(0);
                                      } catch (e) {
                                        Get.close(1);
                                      }
                                    }
                                  }),
                            ],
                          ),
                        ),

                      if (userController.isHaveProvider)
                        const SizedBox(
                          height: 10,
                        ),

                      if (!userController.isHaveProvider &&
                          userModel.accountType == 'seeker')
                        MenuCard(
                          secondTitle: '',
                          userController: userController,
                          title: 'Got Skills? Earn with Vehype',
                          icon: Icons.attach_money_outlined,
                          color: Colors.green,
                          onTap: () async {
                            if (userModel.isGuest) {
                              Get.bottomSheet(LoginSheet(
                                onSuccess: () {
                                  Get.to(() => BecomeAProvider());
                                },
                              ));
                            } else {
                              Get.to(() => BecomeAProvider());
                            }
                          },
                        ),
                      if (!userController.isHaveProvider &&
                          userModel.accountType == 'seeker')
                        const SizedBox(
                          height: 10,
                        ),
                      MenuCard(
                        secondTitle: userController.sameAsSystem
                            ? 'Same as System'
                            : userController.isDark
                                ? 'Dark Theme'
                                : 'Light Theme',
                        userController: userController,
                        title: 'Appearance',
                        icon: Icons.style_outlined,
                        onTap: () async {
                          // userController.changeTheme(!userController.isDark);
                          Get.to(() => ThemePage());
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Manage Profile',
                        icon: Icons.person,
                        onTap: () async {
                          if (userModel.isGuest) {
                            Get.bottomSheet(LoginSheet(
                              onSuccess: () {
                                Get.to(() => EditProfilePage());
                              },
                            ));
                          } else {
                            Get.to(() => EditProfilePage());
                          }
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      // if (userModel.accountType == 'provider')
                      //   MenuCard(
                      //     secondTitle: '',
                      //     userController: userController,
                      //     title: 'Manage Prefrences',
                      //     icon: CupertinoIcons.slider_horizontal_3,
                      //     onTap: () async {
                      //       // if (userModel.isGuest) {
                      //       //   Get.bottomSheet(LoginSheet());
                      //       // } else {
                      //       Get.to(() => ManagePrefs());
                      //       // }
                      //     },
                      //   ),
                      // if (userModel.accountType == 'provider')
                      //   const SizedBox(
                      //     height: 10,
                      //   ),
                      if (userController.isAdmin)
                        MenuCard(
                          secondTitle: '',
                          userController: userController,
                          title: 'Manage Users',
                          icon: Icons.admin_panel_settings,
                          onTap: () async {
                            Get.to(() => AdminHomePage());
                          },
                        ),
                      // InkWell(
                      //   onTap: () {},
                      //   child: Text(
                      //     'Manage Users',
                      //     style: TextStyle(
                      //       color: userController.isDark
                      //           ? Colors.white
                      //           : primaryColor,
                      //       fontWeight: FontWeight.w700,
                      //       fontSize: 17,
                      //     ),
                      //   ),
                      // ),
                      if (userController.isAdmin)
                        const SizedBox(
                          height: 10,
                        ),

                      // const SizedBox(
                      //   height: 10,
                      // ),
                      if (userModel.accountType == 'provider')
                        MenuCard(
                          secondTitle: '',
                          userController: userController,
                          title: 'Manage Products & Services',
                          icon: Icons.business,
                          onTap: () async {
                            Get.to(() => AllProductAndServices(
                                  isFromMyProfile: true,
                                ));
                          },
                        ),
                      if (userModel.accountType == 'provider')
                        const SizedBox(
                          height: 10,
                        ),
                      if (userModel.accountType == 'seeker')
                        MenuCard(
                          secondTitle: '',
                          userController: userController,
                          title: 'My Favourites',
                          icon: Icons.favorite,
                          onTap: () async {
                            Get.to(() => MyFavPage());
                          },
                        ),
                      if (userModel.accountType == 'seeker')
                        const SizedBox(
                          height: 10,
                        ),
                      // Container(
                      //   height: 1,
                      //   width: Get.width,
                      //   color: changeColor(color: 'D9D9D9'),
                      // ),

                      // // Container(
                      // //   height: 1,
                      // //   width: Get.width * 0.8,
                      // //   color: changeColor(color: 'D9D9D9'),
                      // // ),
                      // // if (userModel.status != 'approved')
                      // const SizedBox(
                      //   height: 20,
                      // ),

                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Share VEHYPE',
                        icon: Icons.share,
                        onTap: () async {
                          Share.share(
                              'Spread the Word: VEHYPE Connects Vehicle Owners with Top Service Owners! https://vehype.com/');
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Blocked Users',
                        icon: Icons.block_rounded,
                        onTap: () async {
                          if (userModel.isGuest) {
                            Get.bottomSheet(LoginSheet(
                              onSuccess: () {
                                Get.to(() => BlockedUsers());
                              },
                            ));
                          } else {
                            Get.to(() => BlockedUsers());
                          }
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Contact Us',
                        icon: Icons.contact_support,
                        onTap: () async {
                          launchUrlString('mailto:support@vehype.com');
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Report a Bug',
                        icon: Icons.bug_report,
                        onTap: () async {
                          launchUrlString('mailto:support@vehype.com');
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Privacy Policy',
                        icon: Icons.privacy_tip,
                        onTap: () async {
                          launchUrl(Uri.parse(
                              'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                          // Get.offAll(() => SplashPage());
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Terms of Service',
                        icon: Icons.security,
                        onTap: () async {
                          launchUrl(Uri.parse(
                              'https://www.freeprivacypolicy.com/live/d0f1eec9-aea1-45e3-b40d-52f205295d4e'));
                          // Get.offAll(() => SplashPage());
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (!userModel.isGuest)
                        MenuCard(
                          secondTitle: '',
                          userController: userController,
                          title: 'Delete Account',
                          icon: Icons.delete,
                          onTap: () async {
                            if (userModel.isGuest) {
                              Get.bottomSheet(LoginSheet(
                                onSuccess: () {
                                  Get.to(() => DeleteAccountPage());
                                },
                              ));
                            } else {
                              Get.to(() => DeleteAccountPage());
                            }
                          },
                        ),
                      if (!userModel.isGuest)
                        const SizedBox(
                          height: 10,
                        ),
                      MenuCard(
                        secondTitle: '',
                        userController: userController,
                        title: 'Log Out',
                        icon: Icons.logout,
                        onTap: () async {
                          Get.bottomSheet(LogoutConfirmation());
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FutureBuilder<PackageInfo>(
                              future: PackageManager.getPackageInfo(),
                              builder: (context,
                                  AsyncSnapshot<PackageInfo> snapshot) {
                                if (snapshot.data == null) {
                                  return SizedBox.shrink();
                                }
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        // await FirebaseFirestore.instance
                                        //     .collection('users')
                                        //     .doc(userModel.userId)

                                        //     .update({
                                        //   'contactInfo': '',
                                        //   'isBusinessSetup': false,
                                        // });
                                      },
                                      child: Text(
                                        'App Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class LogoutConfirmation extends StatelessWidget {
  const LogoutConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: userController.isDark ? primaryColor : Colors.white),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () async {
                Get.close(1);

                userController.logout(userController.userModel!, context);
              },
              style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  minimumSize: Size(Get.width * 0.6, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  )),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: userController.isDark ? primaryColor : Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Get.close(1);
              },
              child: Container(
                height: 50,
                width: Get.width * 0.6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: Center(
                  child: Text(
                    'Stay Login',
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String secondTitle;
  final Function onTap;
  final Color? color;
  final IconData icon;
  final UserController userController;
  const MenuCard(
      {super.key,
      required this.secondTitle,
      required this.userController,
      required this.title,
      this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(12),
      height: 55,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: userController.isDark
                ? Colors.white.withOpacity(0.2)
                : primaryColor.withOpacity(0.2),
          )),
      child: InkWell(
        onTap: () => onTap(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color == null ? null : Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: color == null
                        ? (userController.isDark ? Colors.white : primaryColor)
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  secondTitle,
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 18,
                  color: color == null
                      ? (userController.isDark ? Colors.white : primaryColor)
                      : Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
