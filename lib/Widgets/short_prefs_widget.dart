import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/manage_prefs.dart';
import 'package:vehype/const.dart';

class ShortPrefsWidget extends StatelessWidget {
  final Function() onPressed;
  const ShortPrefsWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: 150,
        width: 220,
        decoration: BoxDecoration(
            color: userController.isDark ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: userController.isDark
                  ? Colors.white.withOpacity(.2)
                  : primaryColor.withOpacity(0.2),
            )),
        child: Column(
          // mainAxisSize: MainAxisSize.,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                userController.changeTimeSort();
                onPressed();
              },
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 28,
                    child: Row(
                      children: [
                        if (userController.sortByTime == 0)
                          Icon(
                            Icons.arrow_downward_outlined,
                            color: userController.sortByTime == 0
                                ? userController.isDark
                                    ? Colors.white
                                    : primaryColor
                                : userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                          )
                        else
                          Icon(
                            Icons.arrow_upward_outlined,
                            color: userController.sortByTime == 1
                                ? userController.isDark
                                    ? Colors.white
                                    : primaryColor
                                : userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Time posted',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
            InkWell(
              onTap: () {
                userController.changeDistanceSort();
                onPressed();
              },
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 28,
                    child: Row(
                      children: [
                        if (userController.sortByDistance == 0)
                          Icon(
                            Icons.arrow_downward_outlined,
                            color: userController.sortByDistance == 0
                                ? userController.isDark
                                    ? Colors.white
                                    : primaryColor
                                : userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                          )
                        else
                          Icon(
                            Icons.arrow_upward_outlined,
                            color: userController.sortByDistance == 1
                                ? userController.isDark
                                    ? Colors.white
                                    : primaryColor
                                : userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'Distance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                      color:
                          userController.isDark ? Colors.white : primaryColor),
                  child: IconButton(
                      onPressed: () {
                        userController.resetSort();
                        onPressed();
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 28,
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                      )),
                ),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                  child: IconButton(
                      onPressed: () {
                        onPressed();
                        Get.to(() => ManagePrefs());
                      },
                      icon: SvgPicture.asset(
                        'assets/service_icon_2.svg',
                        height: 30,
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        width: 30,
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
