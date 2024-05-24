// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/const.dart';

import '../Models/user_model.dart';
import 'loading_dialog.dart';

class SelectDateAndPrice extends StatefulWidget {
  final OffersModel offersModel;
  final UserModel ownerModel;
  final OffersReceivedModel? offersReceivedModel;
  const SelectDateAndPrice(
      {super.key,
      required this.offersModel,
      required this.ownerModel,
      required this.offersReceivedModel});

  @override
  State<SelectDateAndPrice> createState() => _SelectDateAndPriceState();
}

class _SelectDateAndPriceState extends State<SelectDateAndPrice> {
  @override
  Widget build(BuildContext context) {
    TextEditingController comment = TextEditingController();

    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);

    return BottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      onClosing: () {},
      builder: (context) {
        return Container(
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: userController.isDark ? primaryColor : Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Offer Details',
                  style: TextStyle(
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Avenir',
                  ),
                ),
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

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixText: '\$ ',
                          hintText: '0.0'
                          // counter: const SizedBox.shrink(),
                          ),
                      initialValue: garageController.price == 0.0
                          ? null
                          : garageController.price.toString(),

                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.number,
                      // maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      onChanged: (String value) =>
                          garageController.selectPrcie(double.parse(value)),
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
                        onTap: () {
                          showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year,
                                      DateTime.now().month + 2))
                              .then((value) {
                            if (value != null) {
                              showTimePicker(
                                      context: context,
                                      initialTime:
                                          TimeOfDay.fromDateTime(value))
                                  .then((time) {
                                if (time != null) {
                                  DateTime newDate = DateTime(
                                      value.year,
                                      value.month,
                                      value.day,
                                      time.hour,
                                      time.minute);
                                  garageController.selectStartDate(newDate);
                                }
                              });
                            }
                          });
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
                        onTap: () {
                          showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(DateTime.now().year,
                                      DateTime.now().month + 2))
                              .then((value) {
                            if (value != null) {
                              showTimePicker(
                                      context: context,
                                      initialTime:
                                          TimeOfDay.fromDateTime(value))
                                  .then((time) {
                                if (time != null) {
                                  DateTime newDate = DateTime(
                                      value.year,
                                      value.month,
                                      value.day,
                                      time.hour,
                                      time.minute);
                                  garageController.selectEndDate(newDate);
                                }
                              });
                            }
                          });
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
                      Row(
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
                  onPressed: garageController.startDate == null ||
                          garageController.endDate == null ||
                          garageController.price == 0.0 ||
                          !garageController.agreement
                      ? null
                      : () {
                          Get.close(1);

                          applyToJob(userModel, garageController, comment);
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0.0,
                      fixedSize: Size(Get.width * 0.8, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      )),
                  child: Text(
                    widget.offersReceivedModel == null ? 'Apply' : 'Update',
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
        );
      },
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
        'price': garageController.price,
        'startDate': garageController.startDate!.toUtc().toIso8601String(),
        'endDate': garageController.endDate!.toUtc().toIso8601String(),
        'comment': comment.text,
      });
      userController.getRequestsHistoryProvider();

      Get.close(1);
      garageController.closeOfferSubmit();
    } else {
      await FirebaseFirestore.instance
          .collection('offers')
          .doc(widget.offersModel.offerId)
          .update({
        'offersReceived': FieldValue.arrayUnion([userModel.userId]),
      });
      await FirebaseFirestore.instance.collection('offersReceived').add({
        'offerBy': userModel.userId,
        'offerId': widget.offersModel.offerId,
        'ownerId': widget.ownerModel.userId,
        'offerAt': DateTime.now().toUtc().toIso8601String(),
        'status': 'Pending',
        'price': garageController.price,
        'startDate': garageController.startDate!.toUtc().toIso8601String(),
        'endDate': garageController.endDate!.toUtc().toIso8601String(),
        'comment': comment.text,
      });
      garageController.closeOfferSubmit();
      userController.getRequestsHistoryProvider();

      Get.close(2);
      Get.showSnackbar(
        GetSnackBar(
          message: 'Submitted successfully. Check Orders history for status',
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

String formatDateTime(DateTime dateTime) {
  DateFormat format = DateFormat(dateTimePattern);

  String dateString = format.format(dateTime);

  return dateString;
}
