// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/comments_page.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/offer_details_button_widget.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/bad_words.dart';

import '../Controllers/garage_controller.dart';
import '../Models/user_model.dart';
import '../const.dart';
import 'repair_page.dart';

class InActiveOffersSeeker extends StatefulWidget {
  final OffersModel offersModel;
  const InActiveOffersSeeker({super.key, required this.offersModel});

  @override
  State<InActiveOffersSeeker> createState() => _InActiveOffersSeekerState();
}

class _InActiveOffersSeekerState extends State<InActiveOffersSeeker> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    List<String> vehicleInfo = widget.offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0].trim();
    final String vehicleMake = vehicleInfo[1].trim();
    final String vehicleYear = vehicleInfo[2].trim();
    final String vehicleModle = vehicleInfo[3].trim();
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              // garageController.disposeController();

              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'Offers Received',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: VehicleDetailsRequest(
                  userController: userController,
                  isShowImage: false,
                  vehicleType: vehicleType,
                  vehicleMake: vehicleMake,
                  vehicleYear: vehicleYear,
                  vehicleModle: vehicleModle,
                  offersModel: widget.offersModel),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: StreamBuilder<List<OffersReceivedModel>>(
                  stream: FirebaseFirestore.instance
                      .collection('offersReceived')
                      .where('ownerId', isEqualTo: userModel.userId)
                      .where('offerId', isEqualTo: widget.offersModel.offerId)
                      // .where('status', isNotEqualTo: 'ignore')
                      .snapshots()
                      .map((event) => event.docs
                          .map((e) => OffersReceivedModel.fromJson(e))
                          .toList()),
                  builder: (context,
                      AsyncSnapshot<List<OffersReceivedModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: Get.height * 0.5,
                          ),
                          Center(
                            child: CircularProgressIndicator(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                          ),
                        ],
                      );
                    }
                    List<OffersReceivedModel> offers = snapshot.data ?? [];

                    return ListView.builder(
                        itemCount: offers.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          OffersReceivedModel offersReceivedModel =
                              offers[index];
                          return StreamBuilder<UserModel>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(offersReceivedModel.offerBy)
                                  .snapshots()
                                  .map((newEvent) =>
                                      UserModel.fromJson(newEvent)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                  );
                                }
                                UserModel postedByDetails = snapshot.data!;
                                return Container(
                                  // color: Colors.white,
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            child: ExtendedImage.network(
                                              postedByDetails.profileUrl,
                                              width: 75,
                                              height: 75,
                                              fit: BoxFit.fill,
                                              cache: true,
                                              // border: Border.all(color: Colors.red, width: 1.0),
                                              shape: BoxShape.circle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(200.0)),
                                              //cancelToken: cancellationToken,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                postedByDetails.name,
                                                style: TextStyle(
                                                  color: userController.isDark
                                                      ? Colors.white
                                                      : primaryColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Get.to(() => CommentsPage(
                                                      data: postedByDetails));
                                                },
                                                child: Row(
                                                  children: [
                                                    RatingBarIndicator(
                                                      rating: postedByDetails
                                                          .rating,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              const Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 25.0,
                                                      direction:
                                                          Axis.horizontal,
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      postedByDetails
                                                          .ratings.length
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: OfferRequestDetails(
                                            userController: userController,
                                            offersReceivedModel:
                                                offersReceivedModel),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      OfferDetailsButtonWidget(
                                        offersReceivedModel:
                                            offersReceivedModel,
                                        userModel: userModel,
                                        postedByDetails: postedByDetails,
                                        offersModel: widget.offersModel,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                );
                              });
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class RatingSheet extends StatefulWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;
  const RatingSheet({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  double rating = 1.0;
  final commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return BottomSheet(
        backgroundColor: widget.isDark ? primaryColor : Colors.white,
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        builder: (cc) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isDark ? primaryColor : Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Please rate your experience and provide any comments to help others.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (ratings) {
                          // Update the rating value
                          setState(() {
                            rating = ratings;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: commentController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          onTapOutside: (s) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          onChanged: (u) {
                            // setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Share your experience and any feedback...',
                            hintStyle: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: commentController.text.isEmpty
                        ? null
                        : () async {
                            if (checkBadWords(commentController.text)
                                .isNotEmpty) {
                              Get.showSnackbar(GetSnackBar(
                                message:
                                    'Vulgar language detected in your input. Please refrain from using inappropriate language.',
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              ));
                              return;
                            }
                            Get.dialog(LoadingDialog(),
                                barrierDismissible: false);
                            await FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(widget.offersReceivedModel.id)
                                .update({
                              // 'status': 'finish',
                              'ratingOne': rating,
                              'comment': commentController.text.trim(),
                            });
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.offersReceivedModel.offerBy)
                                .update({
                              'ratings': FieldValue.arrayUnion([
                                {
                                  'id': userModel.userId,
                                  'rating': rating,
                                  'comment': commentController.text.trim(),
                                  'at':
                                      DateTime.now().toUtc().toIso8601String(),
                                }
                              ])
                            });
                            sendNotification(
                                widget.offersReceivedModel.offerBy,
                                userModel.name,
                                'Offer Update',
                                '${userModel.name}, Rated the offer',
                                widget.offersReceivedModel.id,
                                'Offer',
                                '');

                            await userController.getRequestsHistoryProvider();

                            Get.close(2);
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0.0,
                        fixedSize: Size(Get.width * 0.8, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        )),
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class RatingSheet2 extends StatefulWidget {
  final OffersReceivedModel offersReceivedModel;
  final OffersModel offersModel;
  const RatingSheet2({
    super.key,
    required this.offersReceivedModel,
    required this.offersModel,
    required this.isDark,
  });

  final bool isDark;

  @override
  State<RatingSheet2> createState() => _RatingSheet2State();
}

class _RatingSheet2State extends State<RatingSheet2> {
  double rating = 1.0;
  final commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return BottomSheet(
        backgroundColor: widget.isDark ? primaryColor : Colors.white,
        onClosing: () {},
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        builder: (cc) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isDark ? primaryColor : Colors.white,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'Please rate your experience and provide any comments to help others.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      RatingBar.builder(
                        initialRating: rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (ratings) {
                          // Update the rating value
                          setState(() {
                            rating = ratings;
                          });
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: commentController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          onTapOutside: (s) {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          onChanged: (u) {
                            // setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText:
                                'Share your experience and any feedback...',
                            hintStyle: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                    onPressed: commentController.text.isEmpty
                        ? null
                        : () async {
                            if (checkBadWords(commentController.text)
                                .isNotEmpty) {
                              Get.showSnackbar(GetSnackBar(
                                message:
                                    'Vulgar language detected in your input. Please refrain from using inappropriate language.',
                                duration: const Duration(seconds: 3),
                                snackPosition: SnackPosition.TOP,
                              ));
                              return;
                            }
                            Get.dialog(LoadingDialog(),
                                barrierDismissible: false);
                            await FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(widget.offersReceivedModel.id)
                                .update({
                              // 'status': 'finish',
                              'ratingTwo': rating,
                              'comment': commentController.text.trim(),
                            });
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.offersReceivedModel.offerBy)
                                .update({
                              'ratings': FieldValue.arrayUnion([
                                {
                                  'id': userModel.userId,
                                  'rating': rating,
                                  'comment': commentController.text.trim(),
                                  'at':
                                      DateTime.now().toUtc().toIso8601String(),
                                }
                              ])
                            });
                            sendNotification(
                                widget.offersReceivedModel.offerBy,
                                userModel.name,
                                'Offer Update',
                                '${userModel.name}, Rated the offer',
                                widget.offersReceivedModel.id,
                                'Offer',
                                '');

                            // await userController.getRequestsHistoryProvider();

                            Get.close(2);
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0.0,
                        fixedSize: Size(Get.width * 0.8, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        )),
                    child: Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
