import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/owner_to_service_rating_sheet.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/notification_controller.dart';
import '../Controllers/offers_controller.dart';
import '../Models/chat_model.dart';
import '../Models/user_model.dart';
import '../Pages/full_image_view_page.dart';
import '../Pages/second_user_profile.dart';
import '../const.dart';
import 'owner_cancel_offer_confirmation_sheet.dart';
import 'select_date_and_price.dart';

class OwnerInactiveInprogressOfferWidget extends StatelessWidget {
  final OffersModel offersModels;
  final OffersReceivedModel offersReceivedModels;
  final String? chatId;
  final GarageModel garageModel;
  const OwnerInactiveInprogressOfferWidget(
      {super.key,
      required this.offersModels,
      required this.garageModel,
      this.chatId,
      required this.offersReceivedModels});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    final OffersModel offersModel = Provider.of<OffersProvider>(context)
        .ownerOffers
        .firstWhere((offer) => offer.offerId == offersModels.offerId);
    return StreamBuilder<OffersReceivedModel>(
        stream: FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(offersReceivedModels.id)
            .snapshots()
            .map((convert) => OffersReceivedModel.fromJson(convert)),
        initialData: offersReceivedModels,
        builder: (context, snapshot) {
          final OffersReceivedModel offersReceivedModel =
              snapshot.data ?? offersReceivedModels;
          return StreamBuilder<UserModel>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(offersReceivedModel.offerBy)
                  .snapshots()
                  .map((ss) => UserModel.fromJson(ss)),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                UserModel secondUser = snapshot.data!;

                return Container(
                  decoration: BoxDecoration(
                    color: userController.isDark ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    // border: Border.all(
                    //   color: userController.isDark
                    //       ? Colors.white.withOpacity(0.2)
                    //       : primaryColor.withOpacity(0.2),
                    // ),
                  ),
                  margin:
                      EdgeInsets.only(left: 5, right: 5, bottom: 15, top: 0),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Offer by',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(() =>
                              SecondUserProfile(userId: secondUser.userId));
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: ExtendedImage.network(
                                secondUser.profileUrl,
                                height: 65,
                                width: 65,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  secondUser.name,
                                  style: TextStyle(
                                    // color: Colors.black,

                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                RatingBarIndicator(
                                  rating: secondUser.rating,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'See Profile ',
                                      style: TextStyle(
                                        // color: Colors.black,

                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      size: 16,
                                      weight: 900.0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 0.5,
                        width: Get.width,
                        color: userController.isDark
                            ? Colors.white.withOpacity(0.2)
                            : primaryColor.withOpacity(0.2),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Offer Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '\$${offersReceivedModel.price}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start At',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                formatDateTime(DateTime.parse(
                                    offersReceivedModel.startDate)),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End At',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                formatDateTime(DateTime.parse(
                                    offersReceivedModel.endDate)),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  offersReceivedModel.comment == ''
                                      ? 'No details provided'
                                      : offersReceivedModel.comment,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      if (offersReceivedModel.status == 'Cancelled')
                        const SizedBox(
                          height: 15,
                        ),
                      if (offersReceivedModel.status == 'Cancelled')
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    child: Text(
                                      'Cancellation Reason',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    offersReceivedModel.cancelReason == ''
                                        ? 'No reason provided'
                                        : offersReceivedModel.cancelReason,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      if (offersReceivedModel.status == 'Cancelled')
                        const SizedBox(
                          height: 15,
                        ),
                      if (offersReceivedModel.status == 'Cancelled')
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  child: Text(
                                    'Cancelled By',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  offersReceivedModel.cancelBy == 'owner'
                                      ? 'This offer was cancelled by You.'
                                      : 'This offer was cancelled by ${secondUser.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      if (offersReceivedModel.ratingOne != 0.0)
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  'Your Feedback',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: offersReceivedModel.ratingOne,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 25,
                                  ),
                                  itemSize: 25,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ReadMoreText(
                                  offersReceivedModel.commentOne,
                                  trimMode: TrimMode.Line,
                                  trimLines: 2,
                                  colorClickableText: Colors.pink,
                                  trimCollapsedText: ' Show more',
                                  trimExpandedText: ' Show less',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  moreStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            if (offersReceivedModel.ratingOneImage != '')
                              const SizedBox(
                                height: 20,
                              ),
                            if (offersReceivedModel.ratingOneImage != '')
                              InkWell(
                                onTap: () {
                                  Get.to(() => FullImagePageView(
                                        urls: [
                                          offersReceivedModel.ratingOneImage
                                        ],
                                        currentIndex: 0,
                                      ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ExtendedImage.network(
                                    offersReceivedModel.ratingOneImage,

                                    height: 220,
                                    // shape: BoxShape.rectangle,
                                    fit: BoxFit.cover,
                                    // borderRadius: BorderRadius.only(
                                    //   bottomLeft: Radius.circular(6),
                                    //   bottomRight: Radius.circular(6),
                                    // ),
                                    width: Get.width * 0.95,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      if (offersReceivedModel.ratingTwo != 0.0)
                        Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  '${secondUser.name}\'s Feedback',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: offersReceivedModel.ratingTwo,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 25,
                                  ),
                                  itemSize: 25,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ReadMoreText(
                                  offersReceivedModel.commentTwo,
                                  trimMode: TrimMode.Line,
                                  trimLines: 2,
                                  colorClickableText: Colors.pink,
                                  trimCollapsedText: ' Show more',
                                  trimExpandedText: ' Show less',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  moreStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            if (offersReceivedModel.ratingTwoImage != '')
                              const SizedBox(
                                height: 20,
                              ),
                            if (offersReceivedModel.ratingTwoImage != '')
                              InkWell(
                                onTap: () {
                                  Get.to(() => FullImagePageView(
                                        urls: [garageModel.imageUrl],
                                        currentIndex: 0,
                                      ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ExtendedImage.network(
                                    offersReceivedModel.ratingTwoImage,

                                    height: 220,
                                    // shape: BoxShape.rectangle,
                                    fit: BoxFit.cover,
                                    // borderRadius: BorderRadius.only(
                                    //   bottomLeft: Radius.circular(6),
                                    //   bottomRight: Radius.circular(6),
                                    // ),
                                    width: Get.width * 0.95,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      // Text(offersReceivedModel.status),
                      const SizedBox(
                        height: 20,
                      ),
                      if (offersReceivedModel.status == 'Upcoming')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                Get.bottomSheet(
                                    OwnerCancelOfferConfirmationSheet(
                                        userController: userController,
                                        offersModel: offersModel,
                                        offersReceivedModel:
                                            offersReceivedModel),
                                    isScrollControlled: true);
                              },
                              child: Container(
                                height: 50,
                                width: chatId != null
                                    ? Get.width * 0.43
                                    : Get.width * 0.28,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                            if (chatId == null)
                              InkWell(
                                onTap: () async {
                                  DocumentSnapshot<Map<String, dynamic>>
                                      offerByQuery = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .doc(offersReceivedModel.offerBy)
                                          .get();
                                  // Get.close(1);

                                  await OffersController().chatWithOffer(
                                      userModel,
                                      UserModel.fromJson(offerByQuery),
                                      offersModel,
                                      offersReceivedModel,
                                      garageModel);
                                },
                                child: Container(
                                  height: 50,
                                  width: Get.width * 0.28,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Chat',
                                      style: TextStyle(
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () async {
                                // Get.dialog(LoadingDialog(),
                                //     barrierDismissible: false);

                                // DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                                //     await FirebaseFirestore.instance
                                //         .collection('users')
                                //         .doc(offersReceivedModel.offerBy)
                                //         .get();
                                OffersController().completeOffer(
                                  offersReceivedModel,
                                );
                                DocumentSnapshot<Map<String, dynamic>>
                                    offerByQuery = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(offersReceivedModel.offerBy)
                                        .get();
                                NotificationController().sendNotification(
                                    senderUser: userController.userModel!,
                                    receiverUser:
                                        UserModel.fromJson(offerByQuery),
                                    offerId: offersModel.offerId,
                                    requestId: offersReceivedModel.id,
                                    title: 'Request Completed Successfully',
                                    subtitle:
                                        '${userController.userModel!.name} has marked the request as complete. Tap to review.');
                                OffersController().updateNotificationForOffers(
                                    offerId: offersModel.offerId,
                                    userId: offersReceivedModel.offerBy,
                                    isAdd: true,
                                    offersReceived: offersReceivedModel.id,
                                    checkByList: offersModel.checkByList,
                                    notificationTitle:
                                        'Request Completed Successfully',
                                    notificationSubtitle:
                                        '${userController.userModel!.name} has marked the request as complete. Tap to review.');
                                ChatModel? chatModel = await ChatController()
                                    .getChat(
                                        userController.userModel!.userId,
                                        offersModel.ownerId,
                                        offersModel.offerId);
                                if (chatModel != null) {
                                  ChatController().updateChatToClose(
                                      chatModel.id,
                                      '${userController.userModel!.name} has marked the request as complete.');
                                }
                              },
                              child: Container(
                                height: 50,
                                width: chatId != null
                                    ? Get.width * 0.43
                                    : Get.width * 0.28,
                                decoration: BoxDecoration(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'Complete',
                                    style: TextStyle(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (offersReceivedModel.status == 'Completed')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (offersReceivedModel.ratingOne == 0.0)
                              InkWell(
                                onTap: () async {
                                  showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      // constraints: BoxConstraints(
                                      //   maxHeight: Get.height * 0.95,
                                      //   minHeight: Get.height * 0.95,
                                      //   minWidth: Get.width,
                                      // ),
                                      isScrollControlled: true,
                                      // showDragHandle: true,
                                      // enableDrag: true,
                                      builder: (contex) {
                                        return OwnerToServiceRatingSheet(
                                            offersReceivedModel:
                                                offersReceivedModel,
                                            offersModel: offersModel,
                                            isDark: userController.isDark);
                                      });
                                },
                                child: Container(
                                  height: 50,
                                  width: Get.width * 0.8,
                                  decoration: BoxDecoration(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Submit Feedback',
                                      style: TextStyle(
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      else if (offersReceivedModel.status == 'Cancelled')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (offersReceivedModel.ratingOne == 0.0 &&
                                offersReceivedModel.cancelBy != 'owner')
                              InkWell(
                                onTap: () async {
                                  showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      // constraints: BoxConstraints(
                                      //   maxHeight: Get.height * 0.95,
                                      //   minHeight: Get.height * 0.95,
                                      //   minWidth: Get.width,
                                      // ),
                                      isScrollControlled: true,
                                      // showDragHandle: true,
                                      // enableDrag: true,
                                      builder: (contex) {
                                        return OwnerToServiceRatingSheet(
                                            offersReceivedModel:
                                                offersReceivedModel,
                                            offersModel: offersModel,
                                            isDark: userController.isDark);
                                      });
                                },
                                child: Container(
                                  height: 50,
                                  width: Get.width * 0.8,
                                  decoration: BoxDecoration(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Submit Feedback',
                                      style: TextStyle(
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                    ],
                  ),
                );
              });
        });
  }
}
