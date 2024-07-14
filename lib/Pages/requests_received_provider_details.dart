import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';

import '../Controllers/garage_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/chat_model.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import '../Widgets/request_vehicle_details.dart';
import '../const.dart';
import 'comments_page.dart';
import 'inactive_offers_seeker.dart';
import 'message_page.dart';
import 'repair_page.dart';

class RequestsReceivedProviderDetails extends StatelessWidget {
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;
  const RequestsReceivedProviderDetails(
      {super.key,
      required this.offersModel,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0];
    final String vehicleMake = vehicleInfo[1];
    final String vehicleYear = vehicleInfo[2];
    final String vehicleModle = vehicleInfo[3];
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
          'Request Details',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<UserModel>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(offersModel.ownerId)
                .snapshots()
                .map((event) => UserModel.fromJson(event)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    SizedBox(
                      height: Get.height * 0.4,
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                );
              }
              final UserModel ownerDetails = snapshot.data!;
              return StreamBuilder<OffersReceivedModel>(
                  initialData: offersReceivedModel,
                  stream: FirebaseFirestore.instance
                      .collection('offersReceived')
                      .doc(offersReceivedModel.id)
                      .snapshots()
                      .map((ss) => OffersReceivedModel.fromJson(ss)),
                  builder:
                      (context, AsyncSnapshot<OffersReceivedModel> snapshot) {
                    OffersReceivedModel offersReceivedModelStream =
                        snapshot.data ?? offersReceivedModel;
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(200),
                                child: ExtendedImage.network(
                                  ownerDetails.profileUrl,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.fill,
                                  cache: true,
                                  // border: Border.all(color: Colors.red, width: 1.0),
                                  shape: BoxShape.circle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(200.0)),
                                  //cancelToken: cancellationToken,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ownerDetails.name,
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
                                      Get.to(() =>
                                          CommentsPage(data: ownerDetails));
                                    },
                                    child: Row(
                                      children: [
                                        RatingBarIndicator(
                                          rating: ownerDetails.rating,
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          itemCount: 5,
                                          itemSize: 25.0,
                                          direction: Axis.horizontal,
                                        ),
                                        Text(
                                          ownerDetails.ratings.length
                                              .toString(),
                                          style: TextStyle(
                                            color: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                            fontWeight: FontWeight.bold,
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
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: VehicleDetailsRequest(
                                userController: userController,
                                vehicleType: vehicleType,
                                vehicleMake: vehicleMake,
                                vehicleYear: vehicleYear,
                                vehicleModle: vehicleModle,
                                offersModel: offersModel),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: OfferRequestDetails(
                              userController: userController,
                              offersReceivedModel: offersReceivedModelStream,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          if (offersReceivedModelStream.status == 'Pending')
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _getButton(Colors.white, () async {
                                  Get.dialog(LoadingDialog(),
                                      barrierDismissible: false);
                                  DocumentSnapshot<Map<String, dynamic>> snap =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(
                                              offersReceivedModelStream.ownerId)
                                          .get();
                                  UserModel ownerDetails =
                                      UserModel.fromJson(snap);
                                  ChatModel? chatModel = await ChatController()
                                      .getChat(
                                          userController.userModel!.userId,
                                          ownerDetails.userId,
                                          offersModel.offerId);
                                  if (chatModel == null) {
                                    await ChatController().createChat(
                                        userController.userModel!,
                                        ownerDetails,
                                        offersReceivedModel.id,
                                        offersModel,
                                        'New Message',
                                        '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                                        'chat');
                                    ChatModel? newchat = await ChatController()
                                        .getChat(
                                            userController.userModel!.userId,
                                            ownerDetails.userId,
                                            offersModel.offerId);
                                    Get.close(1);
                                    Get.to(() => MessagePage(
                                          chatModel: newchat!,
                                          secondUser: ownerDetails,
                                        ));
                                  } else {
                                    Get.close(1);

                                    Get.to(() => MessagePage(
                                          chatModel: chatModel,
                                          secondUser: ownerDetails,
                                        ));
                                  }
                                }, 'Chat', Colors.green, context),
                                const SizedBox(
                                  height: 10,
                                ),
                                _getButton(Colors.white, () async {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      context: context,
                                      backgroundColor: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      builder: (context) {
                                        return BottomSheet(
                                            onClosing: () {},
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            builder: (s) {
                                              return Container(
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                  color: userController.isDark
                                                      ? primaryColor
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        'Are you sure? You won\'t be able to revert this action.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: 'Avenir',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Get.close(1);
                                                          Get.dialog(
                                                              LoadingDialog(),
                                                              barrierDismissible:
                                                                  false);

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'offersReceived')
                                                              .doc(
                                                                  offersReceivedModel
                                                                      .id)
                                                              .update({
                                                            'status':
                                                                'Cancelled',
                                                            'cancelBy':
                                                                'provider',
                                                          });
                                                          UserController().addToNotifications(
                                                              userModel,
                                                              offersReceivedModel
                                                                  .ownerId,
                                                              'offer',
                                                              offersReceivedModel
                                                                  .id,
                                                              'Offer Update',
                                                              '${userModel.name} Cancelled the Offer.');

                                                          sendNotification(
                                                              offersReceivedModel
                                                                  .ownerId,
                                                              userModel.name,
                                                              'Offer Update',
                                                              '${userModel.name} Cancelled the Offer.',
                                                              offersReceivedModel
                                                                  .id,
                                                              'offer',
                                                              'messageId');
                                                          Get.close(1);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          elevation: 1.0,
                                                          maximumSize: Size(
                                                              Get.width * 0.6,
                                                              50),
                                                          minimumSize: Size(
                                                              Get.width * 0.6,
                                                              50),
                                                        ),
                                                        child: Text(
                                                          'Confirm',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Avenir',
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Avenir',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      });
                                }, 'Cancel', Colors.red, context),
                                const SizedBox(
                                  height: 8,
                                ),
                                _getButton(
                                    userController.isDark
                                        ? primaryColor
                                        : Colors.white, () async {
                                  Get.dialog(LoadingDialog(),
                                      barrierDismissible: false);

                                  final GarageController garageController =
                                      Provider.of<GarageController>(context,
                                          listen: false);
                                  garageController
                                      .init(offersReceivedModelStream);

                                  DocumentSnapshot<Map<String, dynamic>> snap =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(offersReceivedModel.ownerId)
                                          .get();
                                  Get.close(1);

                                  UserModel ownerDetails =
                                      UserModel.fromJson(snap);

                                  Get.to(
                                    () => SelectDateAndPrice(
                                      offersModel: offersModel,
                                      ownerModel: ownerDetails,
                                      offersReceivedModel:
                                          offersReceivedModelStream,
                                    ),
                                  );
                                }, 'Update', null, context),
                              ],
                            ),
                          if (offersReceivedModelStream.status == 'Upcoming')
                            Column(
                              children: [
                                _getButton(Colors.white, () async {
                                  Get.dialog(LoadingDialog(),
                                      barrierDismissible: false);
                                  DocumentSnapshot<Map<String, dynamic>> snap =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(offersReceivedModel.ownerId)
                                          .get();
                                  UserModel ownerDetails =
                                      UserModel.fromJson(snap);
                                  ChatModel? chatModel = await ChatController()
                                      .getChat(
                                          userController.userModel!.userId,
                                          ownerDetails.userId,
                                          offersModel.offerId);
                                  if (chatModel == null) {
                                    await ChatController().createChat(
                                        userController.userModel!,
                                        ownerDetails,
                                        offersReceivedModel.id,
                                        offersModel,
                                        'New Message',
                                        '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                                        'chat');
                                    ChatModel? newchat = await ChatController()
                                        .getChat(
                                            userController.userModel!.userId,
                                            ownerDetails.userId,
                                            offersModel.offerId);
                                    Get.close(1);
                                    Get.to(() => MessagePage(
                                          chatModel: newchat!,
                                          secondUser: ownerDetails,
                                        ));
                                  } else {
                                    Get.close(1);

                                    Get.to(() => MessagePage(
                                          chatModel: chatModel,
                                          secondUser: ownerDetails,
                                        ));
                                  }
                                }, 'Chat', Colors.green, context),
                                const SizedBox(
                                  height: 10,
                                ),
                                _getButton(
                                    userController.isDark
                                        ? primaryColor
                                        : Colors.white, () async {
                                  DocumentSnapshot<Map<String, dynamic>> snap =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(offersReceivedModel.ownerId)
                                          .get();
                                  UserModel userModel =
                                      UserModel.fromJson(snap);
                                  Event event = Event(
                                    title: userModel.name,
                                    description: offersModel.vehicleId,
                                    // location: 'Event location',
                                    startDate: DateTime.parse(
                                            offersReceivedModel.startDate)
                                        .toLocal(),
                                    endDate: DateTime.parse(
                                            offersReceivedModel.endDate)
                                        .toLocal(),
                                  );
                                  Add2Calendar.addEvent2Cal(event);
                                }, 'Add To Calendar', null, context),
                                const SizedBox(
                                  height: 10,
                                ),
                                _getButton(Colors.white, () async {
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      context: context,
                                      backgroundColor: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      builder: (context) {
                                        return BottomSheet(
                                            onClosing: () {},
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            builder: (s) {
                                              return Container(
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                  color: userController.isDark
                                                      ? primaryColor
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        'Are you sure? You won\'t be able to revert this action.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: 'Avenir',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Get.close(1);
                                                          Get.dialog(
                                                              LoadingDialog(),
                                                              barrierDismissible:
                                                                  false);

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'offersReceived')
                                                              .doc(
                                                                  offersReceivedModel
                                                                      .id)
                                                              .update({
                                                            'status':
                                                                'Cancelled',
                                                            'cancelBy':
                                                                'provider',
                                                          });
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'offers')
                                                              .doc(
                                                                  offersReceivedModel
                                                                      .offerId)
                                                              .update({
                                                            'status':
                                                                'inactive',
                                                          });
                                                          UserController().addToNotifications(
                                                              userModel,
                                                              offersReceivedModel
                                                                  .ownerId,
                                                              'offer',
                                                              offersReceivedModel
                                                                  .id,
                                                              'Offer Update',
                                                              '${userModel.name} Cancelled the Offer.');
                                                          sendNotification(
                                                              offersModel
                                                                  .ownerId,
                                                              userController
                                                                  .userModel!
                                                                  .name,
                                                              'Cancelled The Request',
                                                              'contents',
                                                              offersReceivedModel
                                                                  .id,
                                                              'offer',
                                                              '');
                                                          Get.close(2);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          elevation: 1.0,
                                                          maximumSize: Size(
                                                              Get.width * 0.6,
                                                              50),
                                                          minimumSize: Size(
                                                              Get.width * 0.6,
                                                              50),
                                                        ),
                                                        child: Text(
                                                          'Confirm',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Avenir',
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Avenir',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      });
                                }, 'Cancel', Colors.red, context),
                              ],
                            ),
                          if (offersReceivedModelStream.status == 'Completed' &&
                              offersReceivedModelStream.ratingTwo == 0.0)
                            _getButton(Colors.white, () {
                              showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints: BoxConstraints(
                                    maxHeight: Get.height * 0.9,
                                    minHeight: Get.height * 0.9,
                                    minWidth: Get.width,
                                  ),
                                  isScrollControlled: true,
                                  builder: (contex) {
                                    return FromProviderToOwnerRatingSheet(
                                        offersReceivedModel:
                                            offersReceivedModelStream,
                                        offersModel: offersModel,
                                        isDark: userController.isDark);
                                  });
                            }, 'Give Rating', primaryColor, context),
                          if (offersReceivedModelStream.status == 'Completed' &&
                              offersReceivedModelStream.ratingTwo != 0.0)
                            RatingBarIndicator(
                              rating: offersReceivedModelStream.ratingTwo,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }

  ElevatedButton _getButton(Color textColor, Function? onTap, String text,
      Color? backColor, BuildContext context) {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);

    return ElevatedButton(
      onPressed: onTap == null ? null : () => onTap(),
      style: ElevatedButton.styleFrom(
          backgroundColor: backColor ??
              (userController.isDark ? Colors.white : primaryColor),
          elevation: 0.0,
          fixedSize: Size(Get.width * 0.8, 40),
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
