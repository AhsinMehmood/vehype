// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/comments_page.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';

import '../Controllers/garage_controller.dart';
import '../Models/user_model.dart';
import '../Widgets/request_vehicle_details.dart';
import '../const.dart';
import 'repair_page.dart';

class ReceivedOffersSeeker extends StatefulWidget {
  final OffersModel offersModel;
  final bool isFromNotification;
  final OffersReceivedModel? offersReceivedModel;
  const ReceivedOffersSeeker(
      {super.key,
      required this.offersModel,
      this.offersReceivedModel,
      this.isFromNotification = false});

  @override
  State<ReceivedOffersSeeker> createState() => _ReceivedOffersSeekerState();
}

class _ReceivedOffersSeekerState extends State<ReceivedOffersSeeker> {
  ScrollController scrollController = ScrollController();

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
      body: StreamBuilder<List<OffersReceivedModel>>(
          stream: FirebaseFirestore.instance
              .collection('offersReceived')
              .where('ownerId', isEqualTo: userModel.userId)
              .where('offerId', isEqualTo: widget.offersModel.offerId)
              .where('status', isNotEqualTo: 'ignore')
              .snapshots()
              .map((event) => event.docs
                  .map((e) => OffersReceivedModel.fromJson(e))
                  .toList()),
          builder:
              (context, AsyncSnapshot<List<OffersReceivedModel>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              );
            }
            List<OffersReceivedModel> offers = snapshot.data ?? [];
            if (offers.isEmpty) {
              return Center(
                child: Text(
                  'Its Empty Here!',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: offers.length,
                      controller: scrollController,
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        OffersReceivedModel offersReceivedModel = offers[index];
                        return StreamBuilder<UserModel>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(offersReceivedModel.offerBy)
                                .snapshots()
                                .map(
                                    (newEvent) => UserModel.fromJson(newEvent)),
                            builder:
                                (context, AsyncSnapshot<UserModel> snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                  ),
                                );
                              }
                              UserModel postedByDetails = snapshot.data!;
                              return Card(
                                color: widget.offersReceivedModel != null
                                    ? Colors.red
                                    : userController.isDark
                                        ? Colors.blueGrey.shade700
                                        : Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: SwipeableTile(
                                  color: Colors.black,
                                  swipeThreshold: 0.2,
                                  direction: SwipeDirection.horizontal,
                                  onSwiped: (direction) async {
                                    if (direction ==
                                        SwipeDirection.startToEnd) {
                                      Get.dialog(LoadingDialog(),
                                          barrierDismissible: false);
                                      await FirebaseFirestore.instance
                                          .collection('offersReceived')
                                          .doc(offersReceivedModel.id)
                                          .update({
                                        'status': 'Upcoming',
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('offers')
                                          .doc(widget.offersModel.offerId)
                                          .update({
                                        'status': 'inProgress',
                                      });
                                      UserController().addToNotifications(
                                          userModel,
                                          postedByDetails.userId,
                                          'offer',
                                          offersReceivedModel.id,
                                          'Offer Update',
                                          '${userModel.name}, Accepted your offer');
                                      sendNotification(
                                          offersReceivedModel.offerBy,
                                          userModel.name,
                                          'Offer Update',
                                          '${userModel.name}, Accepted your offer',
                                          offersReceivedModel.id,
                                          'offer',
                                          '');

                                      ChatModel? chatModel =
                                          await ChatController().getChat(
                                              userModel.userId,
                                              postedByDetails.userId,
                                              widget.offersModel.offerId);
                                      if (chatModel == null) {
                                        await ChatController().createChat(
                                            userModel,
                                            postedByDetails,
                                            offersReceivedModel.id,
                                            widget.offersModel,
                                            'Offer Accepted',
                                            '${userModel.name} accepted your offer for ${widget.offersModel.vehicleId}',
                                            'Message');
                                        chatModel = await ChatController()
                                            .getChat(
                                                userModel.userId,
                                                postedByDetails.userId,
                                                widget.offersModel.offerId);
                                        Get.close(2);
                                        Get.to(() => MessagePage(
                                              chatModel: chatModel!,
                                              secondUser: postedByDetails,
                                            ));
                                      } else {
                                        Get.close(2);

                                        Get.to(() => MessagePage(
                                              chatModel: chatModel!,
                                              secondUser: postedByDetails,
                                            ));
                                      }
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('offersReceived')
                                          .doc(offersReceivedModel.id)
                                          .update({
                                        'status': 'ignore',
                                      });
                                      Get.showSnackbar(GetSnackBar(
                                        // title: 'Undo',
                                        // message: ,
                                        messageText: Text(
                                          'Offer marked as ignore.',
                                          style: TextStyle(
                                            color: userController.isDark
                                                ? primaryColor
                                                : Colors.white,
                                          ),
                                        ),
                                        backgroundColor: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        mainButton: TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('offersReceived')
                                                  .doc(offersReceivedModel.id)
                                                  .update({
                                                'status': 'Pending',
                                              });
                                              Get.closeCurrentSnackbar();
                                            },
                                            child: Text(
                                              'Undo',
                                              style: TextStyle(
                                                color: userController.isDark
                                                    ? primaryColor
                                                    : Colors.white,
                                              ),
                                            )),
                                        duration: const Duration(seconds: 3),
                                      ));
                                    }
                                  },
                                  backgroundBuilder:
                                      (context, direction, progress) {
                                    if (direction ==
                                        SwipeDirection.endToStart) {
                                      return Container(
                                        color: Colors.red,
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Ignore',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      // return your widget
                                    } else if (direction ==
                                        SwipeDirection.startToEnd) {
                                      // return your widget
                                      return Container(
                                        color: Colors.green,
                                        padding: const EdgeInsets.all(15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Accept',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return Container(
                                      color: Colors.green,
                                      padding: const EdgeInsets.all(15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Ignore',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  key: UniqueKey(),
                                  child: Container(
                                    color: userController.isDark
                                        ? primaryColor
                                        : Colors.white,
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
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              OfferRequestDetails(
                                                  userController:
                                                      userController,
                                                  offersReceivedModel:
                                                      offersReceivedModel),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                OffersController()
                                                    .chatWithOffer(
                                                        userModel,
                                                        postedByDetails,
                                                        widget.offersModel,
                                                        offersReceivedModel);
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          300),
                                                ),
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: SvgPicture.asset(
                                                    'assets/messages.svg',
                                                    height: 34,
                                                    width: 34,
                                                    color: userController.isDark
                                                        ? primaryColor
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            _getButton(Colors.white, () async {
                                              Get.dialog(LoadingDialog(),
                                                  barrierDismissible: false);

                                              await UserController()
                                                  .addToNotifications(
                                                      userModel,
                                                      postedByDetails.userId,
                                                      'offer',
                                                      offersReceivedModel.id,
                                                      'Offer Update',
                                                      '${userModel.name}, Accepted your offer');
                                              await UserController()
                                                  .changeNotiOffers(
                                                      2,
                                                      true,
                                                      offersReceivedModel
                                                          .offerBy,
                                                      widget
                                                          .offersModel.offerId,
                                                      userModel.accountType);
                                              OffersController().acceptOffer(
                                                  offersReceivedModel,
                                                  widget.offersModel,
                                                  userModel,
                                                  postedByDetails);
                                            }, 'Accept'),

                                            // else
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      }),
                ),
              ],
            );
          }),
    );
  }

  ElevatedButton _getButton(Color textColor, Function? onTap, String text) {
    final UserController userController = Provider.of<UserController>(context);

    return ElevatedButton(
      onPressed: onTap == null ? null : () => onTap(),
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          elevation: 0.0,
          fixedSize: Size(Get.width * 0.7, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          )),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
