import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Pages/service_set_opening_hours.dart';

import '../Controllers/user_controller.dart';
import '../const.dart';

class WorkingHoursWidget extends StatelessWidget {
  final bool isOwner;
  final Map<String, dynamic> workingHours;

  const WorkingHoursWidget({
    super.key,
    required this.workingHours,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final orderedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return Card(
      margin: const EdgeInsets.all(12),
      color: userController.isDark ? primaryColor : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Working Hours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                !isOwner
                    ? IconButton(
                        onPressed: () {
                          Get.to(() => ServiceSetOpeningHours(
                                shopHours:
                                    userController.userModel!.workingHours,
                                isFroPage: true,
                              ));
                        },
                        icon: Icon(
                          Icons.edit,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ))
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: orderedDays
                  .where((day) => workingHours.containsKey(
                      day)) // Ensure only existing days are displayed
                  .map((day) {
                final value = workingHours[day];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          color: value == '24 Hours'
                              ? Colors.green
                              : userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
