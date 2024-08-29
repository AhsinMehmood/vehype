// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Pages/repair_page.dart';
// import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/bad_words.dart';
import 'package:vehype/const.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import 'loading_dialog.dart';
// import 'request_vehicle_details.dart';

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
            widget.offersReceivedModel != null ? 'Update Offer' : 'Send Offer',
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
        body: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              margin: const EdgeInsets.all(0),
              color: userController.isDark ? primaryColor : Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.offersModel.imageOne != '')
                          ExtendedImage.network(
                            widget.offersModel.imageOne,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            cache: true,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'widget.offersModel.title',
                                maxLines: 2,
                                style: TextStyle(
                                  // color: Colors.black,
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                      getServices()
                                          .firstWhere((element) =>
                                              element.name ==
                                              widget.offersModel.issue)
                                          .image,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      height: 25,
                                      width: 25),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    ' ',
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    widget.offersModel.issue,
                                    style: TextStyle(
                                      // color: Colors.black,
                                      fontFamily: 'Avenir',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Price *',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
                            // color: Colors.black,
                            fontSize: 16,
                          ),
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
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*')),
                        ],
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            counter: const SizedBox.shrink(),
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
                        onChanged: (String value) {
                          if (value.isEmpty) {
                            setState(() {
                              // showDateWarning = false;
                              // showEndDateWarning = false;
                              showPriceWarning = true;
                            });
                          } else {
                            setState(() {
                              // showDateWarning = false;
                              // showEndDateWarning = false;
                              showPriceWarning = false;
                            });
                          }
                        },
                        // onChanged: (String value) =>
                        //     garageController.selectPrcie(double.parse(value)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (showPriceWarning)
                        Row(
                          children: [
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
                                hintStyle: TextStyle(
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w400,
                                  color: changeColor(color: '7B7B7B'),
                                  fontSize: 14,
                                ),
                                hintText:
                                    'Explain the details. e.g. Service, Parts'
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
                              'Select Start Date *',
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
                                DateTime? dateTime =
                                    await showOmniDateTimePicker(
                                  context: context,
                                  initialDate: garageController.startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 30),
                                  ),
                                  is24HourMode: false,
                                  isShowSeconds: false,
                                  minutesInterval: 15,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
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
                                  setState(() {
                                    showDateWarning = false;
                                    // showEndDateWarning = false;
                                    // showPriceWarning = false;
                                  });
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
                                      : formatDateTime(
                                          garageController.startDate!),
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
                              'Select End Date *',
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
                                    title:
                                        Text('Please select start date firts'),
                                    autoCloseDuration: Duration(
                                      seconds: 3,
                                    ),
                                  );
                                  return;
                                }
                                DateTime? dateTime =
                                    await showOmniDateTimePicker(
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(16)),
                                  barrierDismissible: false,
                                  selectableDayPredicate: (dateTime) {
                                    // Disable 25th Feb 2023
                                    if (dateTime ==
                                        garageController.startDate) {
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
                                    setState(() {
                                      // showDateWarning = false;
                                      showEndDateWarning = false;
                                      // showPriceWarning = false;
                                    });
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
                                      : formatDateTime(
                                          garageController.endDate!),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.8,
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
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w400,
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
                                            fontFamily: 'Avenir',
                                            decorationColor: Colors.blueAccent,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.blueAccent,
                                            decoration:
                                                TextDecoration.underline,
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
                      const SizedBox(
                        height: 35,
                      ),
                      const SizedBox(
                        height: 15,
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
                              garageController.endDate == null) {
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
                                title: Text(
                                    'Start and End date cannot be the same.'),
                                style: ToastificationStyle.minimal,
                                context: context,
                                type: ToastificationType.error,
                                showProgressBar: true,
                                autoCloseDuration: Duration(
                                  seconds: 3,
                                ),
                              );
                            } else {
                              if (garageController.agreement) {
                                if (priceController.text == '.' ||
                                    priceController.text == '.0') {
                                  toastification.show(
                                    title: Text('Price is invalid'),
                                    style: ToastificationStyle.minimal,
                                    context: context,
                                    type: ToastificationType.error,
                                    showProgressBar: true,
                                    autoCloseDuration: Duration(
                                      seconds: 3,
                                    ),
                                  );
                                } else {
                                  applyToJob(
                                      userModel, garageController, comment);
                                }
                              } else {
                                toastification.show(
                                  title: Text(
                                      'To continue sending offers, please review and acknowledge our VEHYPE ratings policy. Your acceptance is required to ensure a smooth experience and to comply with our guidelines.'),
                                  style: ToastificationStyle.minimal,
                                  context: context,
                                  type: ToastificationType.error,
                                  showProgressBar: true,
                                  autoCloseDuration: Duration(
                                    seconds: 7,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            elevation: 0.0,
                            fixedSize: Size(Get.width * 0.9, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            )),
                        child: Text(
                          widget.offersReceivedModel == null
                              ? 'Send Offer'
                              : 'Apply',
                          style: TextStyle(
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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

  applyToJob(
      UserModel userModel, GarageController garageController, comment) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    UserController userController =
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

      NotificationController().sendNotification(
          senderUser: userModel,
          receiverUser: widget.ownerModel,
          offerId: widget.offersModel.offerId,
          requestId: widget.offersReceivedModel!.id,
          title: 'Service Offer Updated',
          subtitle:
              '${userModel.name} has updated their offer for your request. Review the new details to see the changes made just for you.');

      OffersController().updateNotificationForOffers(
          offerId: widget.offersModel.offerId,
          userId: widget.ownerModel.userId,
          isAdd: true,
          offersReceived: widget.offersReceivedModel!.id,
          checkByList: widget.offersModel.checkByList,
          notificationTitle: '${userModel.name} updated his offer.',
          notificationSubtitle:
              '${userModel.name} has updated their offer for your request. Review the new details to see the changes made just for you.');

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

      garageController.closeOfferSubmit();
      await NotificationController().sendNotification(
          senderUser: userModel,
          receiverUser: widget.ownerModel,
          offerId: widget.offersModel.offerId,
          requestId: reference.id,
          title: 'New Offer for Your Request',
          subtitle:
              '${userModel.name} has submitted an offer in response to your request. Click here to review and respond.');
      OffersController().updateNotificationForOffers(
          offerId: widget.offersModel.offerId,
          userId: widget.ownerModel.userId,
          isAdd: true,
          offersReceived: reference.id,
          checkByList: widget.offersModel.checkByList,
          notificationTitle: '${userModel.name} has submitted an offer.',
          notificationSubtitle:
              'Tap here to review and respond.');

      // ChatController().updateChatRequestId(widget.chatId!, reference.id);
      // if (widget.chatId != null) {
      Get.close(3);
      // } else {

      // }

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

String formatDate(DateTime dateTime) {
  DateFormat format = DateFormat.yMMMMd('en_US');
//  -> July 10, 2024 5:08 PM
  String dateString = format.format(dateTime);

  return dateString;
}
