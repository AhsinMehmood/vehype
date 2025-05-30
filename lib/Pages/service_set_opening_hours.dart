import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/notification_controller.dart';
import 'package:vehype/Pages/tabs_page.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class ServiceSetOpeningHours extends StatefulWidget {
  final Map<String, dynamic> shopHours;
  final bool isFroPage;

  const ServiceSetOpeningHours(
      {super.key, required this.shopHours, this.isFroPage = false});

  @override
  // ignore: library_private_types_in_public_api
  _ServiceSetOpeningHoursState createState() => _ServiceSetOpeningHoursState();
}

class _ServiceSetOpeningHoursState extends State<ServiceSetOpeningHours> {
  Map<String, TimeOfDay?> openingTimes = {};
  Map<String, TimeOfDay?> closingTimes = {};
  Map<String, bool> is24Hours = {};

  final daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    shopHours = widget.shopHours;

    for (var day in daysOfWeek) {
      if (shopHours.containsKey(day)) {
        if (shopHours[day] == '24 Hours') {
          is24Hours[day] = true;
        } else {
          final times = shopHours[day].split(' - ');
          openingTimes[day] = _parseTime(times[0]);
          closingTimes[day] = _parseTime(times[1]);
          is24Hours[day] = false;
        }
      }
      // Ensure defaults if anything is missing
      openingTimes[day] ??= const TimeOfDay(hour: 9, minute: 0);
      closingTimes[day] ??= const TimeOfDay(hour: 18, minute: 0);
      is24Hours[day] ??= false;
    }
  }

// Helper method to parse "hh:mm AM/PM" to TimeOfDay
  TimeOfDay _parseTime(String timeString) {
    final format = RegExp(r'(\d+):(\d+)\s*(AM|PM)');
    final match = format.firstMatch(timeString);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      final period = match.group(3);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    }

    return const TimeOfDay(hour: 0, minute: 0); // Default in case of error
  }

  Future<void> _selectTime(
      BuildContext context, String day, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? openingTimes[day]! : closingTimes[day]!,
    );

    if (picked != null) {
      setState(() {
        if (isOpening) {
          openingTimes[day] = picked;
        } else {
          closingTimes[day] = picked;
        }
      });
    }
  }

  Map<String, dynamic> shopHours = {};
  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _saveHours() {
    for (var day in daysOfWeek) {
      if (is24Hours[day]!) {
        shopHours[day] = '24 Hours';
      } else {
        shopHours[day] =
            '${openingTimes[day]!.format(context)} - ${closingTimes[day]!.format(context)}';
      }
    }
    setState(() {});
    log(shopHours.toString());
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    Map<String, String> orderedShopHours = {};

    for (var day in daysOfWeek) {
      orderedShopHours[day] = (is24Hours[day] ?? false)
          ? '24 Hours'
          : '${_formatTime(openingTimes[day])} - ${_formatTime(closingTimes[day])}';
    }
    log(orderedShopHours.toString());

    FirebaseFirestore.instance
        .collection('users')
        .doc(userController.userModel!.userId)
        .update({
      'workingHours': orderedShopHours,
      'isSetOpeningHours': true,
    });
    // NotificationController().sendNotificationNewProvider(
    //     providerId: userController.userModel!.userId,
    //     requestId: '',
    //     title: 'New ',
    //     subtitle: subtitle,
    //     userIds: userIds);
    if (widget.isFroPage) {
      Get.back();
    } else {
      userController.changeTabIndex(0);
      Get.offAll(() => TabsPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isFroPage ? 'Update Working Hours' : 'Set Working Hours',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: widget.isFroPage
            ? IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: userController.isDark ? Colors.white : primaryColor,
                ))
            : null,
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
      ),
      body: ListView(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        children: daysOfWeek.map((day) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: userController.isDark ? primaryColor : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 25,
                          maxWidth: 35,
                        ),
                        child: Switch(
                          value: is24Hours[day]!,
                          onChanged: (value) {
                            setState(() {
                              is24Hours[day] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (!is24Hours[day]!) ...[
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _selectTime(context, day, true),
                          style: TextButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white.withOpacity(1.0)
                                : primaryColor.withOpacity(0.9),
                          ),
                          child: Text(
                            'Open: ${openingTimes[day]!.format(context)}',
                            style: TextStyle(
                              fontSize: 15,
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectTime(context, day, false),
                          style: TextButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white.withOpacity(1.0)
                                : primaryColor.withOpacity(0.9),
                          ),
                          child: Text(
                            'Close: ${closingTimes[day]!.format(context)}',
                            style: TextStyle(
                              fontSize: 15,
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      '24 Hours Service',
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          _saveHours();
        },
        child: SizedBox(
          height: 55,
          width: Get.width * 0.9,
          child: Card(
            color: userController.isDark ? Colors.white : primaryColor,
            child: Center(
              child: Text(
                widget.isFroPage ? 'Update' : 'Save & Continue',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: userController.isDark ? primaryColor : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
