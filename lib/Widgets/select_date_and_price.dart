// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/repair_page.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/bad_words.dart';
import 'package:vehype/const.dart';

import '../Models/user_model.dart';
import 'loading_dialog.dart';
import 'request_vehicle_details.dart';

class SelectDateAndPrice extends StatefulWidget {
  final OffersModel offersModel;
  final String? chatId;
  final UserModel ownerModel;
  final OffersReceivedModel? offersReceivedModel;
  const SelectDateAndPrice(
      {super.key,
      required this.offersModel,
      this.chatId,
      required this.ownerModel,
      required this.offersReceivedModel});

  @override
  State<SelectDateAndPrice> createState() => _SelectDateAndPriceState();
}

class _SelectDateAndPriceState extends State<SelectDateAndPrice> {
  TextEditingController comment = TextEditingController();
  TextEditingController priceController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.offersReceivedModel != null) {
      final GarageController garageController =
          Provider.of<GarageController>(context, listen: false);
      garageController.agreement = true;
      garageController.startDate =
          DateTime.parse(widget.offersReceivedModel!.startDate);
      garageController.endDate =
          DateTime.parse(widget.offersReceivedModel!.endDate);
      comment =
          TextEditingController(text: widget.offersReceivedModel!.comment);

      priceController = TextEditingController(
          text: widget.offersReceivedModel!.price.toString());
      setState(() {});
    }
  }

  bool showPriceWarning = false;
  bool showDateWarning = false;
  bool showEndDateWarning = false;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    List<String> vehicleInfo = widget.offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0];
    final String vehicleMake = vehicleInfo[1];
    final String vehicleYear = vehicleInfo[2];
    final String vehicleModle = vehicleInfo[3];
    return WillPopScope(
      onWillPop: () async {
        garageController.disposeController();
        await Future.delayed(Duration(milliseconds: 100));

        return true;
      },
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
              onPressed: () async {
                garageController.disposeController();
                await Future.delayed(Duration(milliseconds: 100));
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          title: Text(
            'Send Offer',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Avenir',
            ),
          ),
          centerTitle: true,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Offer Details',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w700,
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                VehicleDetailsRequest(
                    userController: userController,
                    vehicleType: vehicleType,
                    vehicleMake: vehicleMake,
                    vehicleYear: vehicleYear,
                    vehicleModle: vehicleModle,
                    offersModel: widget.offersModel),
                const SizedBox(
                  height: 25,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      controller: priceController,
                      maxLength: 6,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixText: '\$ ',
                          hintStyle: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w600,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 28,
                          ),
                          hintText: '0.0'
                          // counter: const SizedBox.shrink(),
                          ),

                      // textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.number,

                      // maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w800,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 28,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) =>
                      //     garageController.selectPrcie(double.parse(value)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (showPriceWarning)
                      Text(
                        'Price is required.*',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          color: Colors.red,
                          // color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 1,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offer Details',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      controller: comment,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Explain the details. e.g. Service, Parts'
                          // counter: const SizedBox.shrink(),
                          ),
                      // initialValue: '',

                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) => editProfileProvider
                      //     .updateTexts(userModel, 'name', value),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 1,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Start Date',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          // color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          DateTime? dateTime = await showOmniDateTimePicker(
                            context: context,
                            initialDate: garageController.startDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                            is24HourMode: false,
                            isShowSeconds: false,
                            minutesInterval: 15,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            barrierDismissible: false,
                            selectableDayPredicate: (dateTime) {
                              // Disable 25th Feb 2023
                              if (dateTime == DateTime(2023, 2, 25)) {
                                return false;
                              } else {
                                return true;
                              }
                            },
                            padding: const EdgeInsets.all(10),
                          );
                          if (dateTime != null) {
                            garageController.selectStartDate(dateTime);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: userController.isDark
                                ? Colors.white54
                                : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            garageController.startDate == null
                                ? 'Tap To Select'
                                : formatDateTime(garageController.startDate!),
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              // color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (showDateWarning)
                        Text(
                          'Job starting date is required.*',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                            // color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select End Date',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          // color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          if (garageController.startDate == null) {
                            toastification.show(
                              context: context,
                              title: Text('Please select start date firts'),
                              autoCloseDuration: Duration(
                                seconds: 3,
                              ),
                            );
                            return;
                          }
                          DateTime? dateTime = await showOmniDateTimePicker(
                            context: context,
                            initialDate: garageController.endDate ??
                                garageController.startDate!
                                    .add(Duration(minutes: 30)),
                            firstDate: garageController.startDate!
                                .add(Duration(minutes: 30)),
                            lastDate: garageController.startDate!.add(
                              const Duration(days: 30),
                            ),
                            is24HourMode: false,
                            isShowSeconds: false,
                            minutesInterval: 15,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            barrierDismissible: false,
                            selectableDayPredicate: (dateTime) {
                              // Disable 25th Feb 2023
                              if (dateTime == garageController.startDate) {
                                return false;
                              } else {
                                return true;
                              }
                            },
                            padding: const EdgeInsets.all(10),
                          );
                          if (dateTime != null) {
                            DateTime startDateTime = DateTime(
                              garageController.startDate!.year,
                              garageController.startDate!.month,
                              garageController.startDate!.day,
                              garageController.startDate!.hour,
                              garageController.startDate!.minute,
                            );
                            DateTime endDateTime = DateTime(
                              dateTime.year,
                              dateTime.month,
                              dateTime.day,
                              dateTime.hour,
                              dateTime.minute,
                            );
                            bool areDateTimesEqual =
                                startDateTime == endDateTime;

                            bool isStartAfterEnd =
                                startDateTime.isAfter(dateTime);
                            if (isStartAfterEnd || areDateTimesEqual) {
                              toastification.show(
                                  context: context,
                                  autoCloseDuration: Duration(seconds: 4),
                                  title: Text(
                                      'End date and time cannot be same or after start date and time'));
                            } else {
                              garageController.selectEndDate(dateTime);
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: userController.isDark
                                ? Colors.white54
                                : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            garageController.endDate == null
                                ? 'Tap To Select'
                                : formatDateTime(garageController.endDate!),
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              // color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (showEndDateWarning)
                        Text(
                          'Estimated job finishing date is required.*',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                            // color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    garageController.changeAgree();
                  },
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                            activeColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            checkColor: userController.isDark
                                ? Colors.green
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            value: garageController.agreement,
                            onChanged: (s) {
                              garageController.changeAgree();
                              // appProvider.selectPrefs(pref);
                            }),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I agree to VEHYPE ratings policy.',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              // color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          InkWell(
                            onTap: () async {
                              await launchUrl(
                                  Uri.parse('https://vehype.com/help#'));
                            },
                            child: Text(
                              ' See how rating works.',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.red,
                                fontFamily: 'Avenir',
                                color: Colors.red,
                                fontWeight: FontWeight.w400,
                                // color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (priceController.text.isEmpty) {
                      showPriceWarning = true;
                      setState(() {});
                      return;
                    } else {
                      showPriceWarning = false;
                      setState(() {});
                    }
                    if (garageController.startDate == null ||
                        garageController.endDate == null ||
                        !garageController.agreement) {
                      setState(() {
                        if (garageController.startDate == null) {
                          showDateWarning = true;
                        }
                        if (garageController.endDate == null) {
                          showEndDateWarning = true;
                        }
                      });
                    } else {
                      setState(() {
                        showDateWarning = false;
                        showEndDateWarning = false;
                        showPriceWarning = false;
                      });
                      if (DateTime(
                              garageController.startDate!.year,
                              garageController.startDate!.month,
                              garageController.startDate!.day,
                              garageController.startDate!.hour,
                              garageController.startDate!.minute) ==
                          DateTime(
                              garageController.endDate!.year,
                              garageController.endDate!.month,
                              garageController.endDate!.day,
                              garageController.endDate!.hour,
                              garageController.endDate!.minute)) {
                        toastification.show(
                          // closeButtonShowType: CloseButtonShowType.none,
                          title: Text('Start and End date cannot be the same.'),
                          style: ToastificationStyle.minimal,
                          context: context,
                          type: ToastificationType.error,
                          showProgressBar: true,
                          autoCloseDuration: Duration(
                            seconds: 3,
                          ),
                        );
                      } else {
                        applyToJob(userModel, garageController, comment);
                      }

                      // Get.close(1);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0.0,
                      fixedSize: Size(Get.width * 0.8, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      )),
                  child: Text(
                    widget.offersReceivedModel == null ? 'Send Offer' : 'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  applyToJob(
      UserModel userModel, GarageController garageController, comment) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    if (widget.offersReceivedModel != null) {
      await FirebaseFirestore.instance
          .collection('offersReceived')
          .doc(widget.offersReceivedModel!.id)
          .update({
        'price': double.parse(priceController.text.toString()),
        'startDate': garageController.startDate!.toUtc().toIso8601String(),
        'endDate': garageController.endDate!.toUtc().toIso8601String(),
        'comment': comment.text,
      });
      // userController.getRequestsHistoryProvider();
      UserController().addToNotifications(
          userModel,
          widget.ownerModel.userId,
          'offer',
          widget.offersReceivedModel!.id,
          'Offer Update',
          '${userModel.name} updated his offer.');
      sendNotification(
          widget.ownerModel.userId,
          userModel.name,
          'Offer Update',
          '${userModel.name} updated his offer.',
          widget.offersReceivedModel!.id,
          'offer',
          'messageId');
      UserController().changeNotiOffers(5, true, widget.ownerModel.userId,
          widget.offersModel.offerId, userModel.accountType);
      Get.close(2);

      garageController.closeOfferSubmit();
    } else {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(widget.offersModel.offerId)
          .update({
        'offersReceived': FieldValue.arrayUnion([userModel.userId]),
      });
      DocumentReference<Map<String, dynamic>> reference =
          await FirebaseFirestore.instance.collection('offersReceived').add({
        'offerBy': userModel.userId,
        'offerId': widget.offersModel.offerId,
        'ownerId': widget.ownerModel.userId,
        'offerAt': DateTime.now().toUtc().toIso8601String(),
        'status': 'Pending',
        'price': double.parse(priceController.text.toString()),
        'startDate': garageController.startDate!.toUtc().toIso8601String(),
        'endDate': garageController.endDate!.toUtc().toIso8601String(),
        'comment': comment.text,
      });
      UserController().addToNotifications(
          userModel,
          widget.ownerModel.userId,
          'offer',
          reference.id,
          'Offer Update',
          '${userModel.name} Sent you an offer.');
      garageController.closeOfferSubmit();
      sendNotification(
          widget.ownerModel.userId,
          userModel.name,
          'Offer Update',
          '${userModel.name} Sent you an offer.',
          reference.id,
          'offer',
          'messageId');
      UserController().changeNotiOffers(5, true, widget.ownerModel.userId,
          widget.offersModel.offerId, userModel.accountType);
      if (widget.chatId != null) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .update({
          'offerRequestId': reference.id,
        });
      }
      if (widget.chatId != null) {
        Get.close(2);
      } else {
        Get.close(3);
      }

      // Get.showSnackbar(
      //   GetSnackBar(
      //     message: 'Submitted successfully. Check Orders history for status',
      //     duration: Duration(seconds: 3),
      //   ),
      // );
    }
  }
}

String formatDateTime(DateTime dateTime) {
  DateFormat format = DateFormat.yMMMMd('en_US').add_jm();
//  -> July 10, 2024 5:08 PM
  String dateString = format.format(dateTime);

  return dateString;
}
