import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
// import 'package:manage_calendar_events/manage_calendar_events.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/calenders_list.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/owner_complete_offer_confirmation_sheet.dart';
import 'package:vehype/Widgets/owner_to_service_rating_sheet.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/offers_controller.dart';
import '../Controllers/pdf_generator.dart';
import '../Models/product_service_model.dart';
import '../Models/user_model.dart';
import '../Pages/Invoice/review_share_invoice.dart';
import '../Pages/full_image_view_page.dart';
import '../Pages/second_user_profile.dart';
import '../const.dart';
import 'owner_cancel_offer_confirmation_sheet.dart';
import 'owner_ignore_offer_confirmation_widget.dart';
import 'owner_offer_received_new_widget.dart';
import 'select_date_and_price.dart';
import 'user_rating_short_widget.dart';

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
                      UserRatingShortWidget(secondUser: secondUser),

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
                      if (offersReceivedModel.products.isNotEmpty)
                        ExpansionTile(
                          tilePadding: const EdgeInsets.all(0),
                          childrenPadding: const EdgeInsets.all(0),
                          iconColor: userController.isDark
                              ? Colors.white
                              : primaryColor,

                          initiallyExpanded:
                              false, // You can set this to false if you want it collapsed by default
                          title: Text(
                            'Product or Service (${offersReceivedModel.products.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            if (offersReceivedModel.products.isNotEmpty)
                              ListView.builder(
                                itemCount: offersReceivedModel.products.length,
                                physics: NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final ProductServiceModel product =
                                      offersReceivedModel.products[index];

                                  return Stack(
                                    children: [
                                      ListTile(
                                        dense: true,
                                        title: Text(
                                          product.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (product.desc.isNotEmpty)
                                              Text(
                                                product
                                                    .desc, // Show description
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              getServiceDetail(
                                                  product), // Show service details
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                        trailing: Text(
                                            '\$${product.totalPrice}',
                                            style: TextStyle(
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text('\$${offersReceivedModel.price}',
                                style: TextStyle(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'Start At',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w400,
                      //           ),
                      //         ),
                      //         const SizedBox(
                      //           height: 5,
                      //         ),
                      //         Text(
                      //           formatDateTime(DateTime.parse(
                      //               offersReceivedModel.startDate)),
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.w800,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     if (offersReceivedModel.status == 'Upcoming')
                      //       InkWell(
                      //         onTap: () async {
                      //           final CalendarPlugin myPlugin =
                      //               CalendarPlugin();

                      //           if (offersReceivedModel.ownerEventId == '') {
                      //             bool? hasPermissions =
                      //                 await myPlugin.hasPermissions();

                      //             if (!hasPermissions!) {
                      //               // Request permissions
                      //               await myPlugin.requestPermissions();

                      //               // Recheck permissions after request
                      //               hasPermissions =
                      //                   await myPlugin.hasPermissions();

                      //               if (!hasPermissions!) {
                      //                 toastification.show(
                      //                   context: context,
                      //                   autoCloseDuration: Duration(seconds: 3),
                      //                   title: Text(
                      //                       'Permissions are required to access calendars.'),
                      //                 );
                      //                 return; // Exit early if permissions are not granted
                      //               }
                      //             }

                      //             // Fetch calendars after ensuring permissions are granted
                      //             List<Calendar> calendar =
                      //                 await myPlugin.getCalendars() ?? [];

                      //             if (calendar.isEmpty) {
                      //               toastification.show(
                      //                 context: context,
                      //                 autoCloseDuration: Duration(seconds: 3),
                      //                 title: Text('No calendar found.'),
                      //               );
                      //             } else {
                      //               Get.bottomSheet(
                      //                 CalendersList(
                      //                   calenders: calendar,
                      //                   offersModel: offersModel,
                      //                   offersReceivedModel:
                      //                       offersReceivedModel,
                      //                 ),
                      //               );
                      //             }
                      //           } else {
                      //             myPlugin
                      //                 .deleteEvent(
                      //                     calendarId: offersReceivedModel
                      //                         .ownerCalendarId,
                      //                     eventId:
                      //                         offersReceivedModel.ownerEventId)
                      //                 .then((isDeleted) async {
                      //               await FirebaseFirestore.instance
                      //                   .collection('offersReceived')
                      //                   .doc(offersReceivedModel.id)
                      //                   .update({
                      //                 'ownerEventId': '',
                      //                 'ownerCalendarId': '',
                      //               });
                      //               debugPrint('Is Event deleted: $isDeleted');
                      //             });
                      //           }
                      //         },
                      //         child: Container(
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(6),
                      //               color: userController.isDark
                      //                   ? primaryColor
                      //                   : Colors.white,
                      //               border: Border.all(
                      //                 color: userController.isDark
                      //                     ? Colors.white
                      //                     : primaryColor,
                      //               )),
                      //           padding: const EdgeInsets.all(6),
                      //           child: Text(
                      //             offersReceivedModel.ownerEventId == ''
                      //                 ? 'Add to Calendar'
                      //                 : 'Remove Event',
                      //             style: TextStyle(
                      //               fontSize: 14,
                      //               fontWeight: FontWeight.w700,
                      //             ),
                      //           ),
                      //         ),
                      //       )
                      //   ],
                      // ),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                      // if (offersReceivedModel.endDate != null)
                      //   Row(
                      //     children: [
                      //       Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text(
                      //             'End At',
                      //             style: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.w400,
                      //             ),
                      //           ),
                      //           const SizedBox(
                      //             height: 5,
                      //           ),
                      //           Text(
                      //             formatDateTime(DateTime.parse(
                      //                 offersReceivedModel.endDate!)),
                      //             style: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.w800,
                      //             ),
                      //           ),
                      //         ],
                      //       )
                      //     ],
                      //   ),
                      // if (offersReceivedModel.endDate != null)
                      //   const SizedBox(
                      //     height: 15,
                      //   ),
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           InkWell(
                      //             child: Text(
                      //               'Description',
                      //               style: TextStyle(
                      //                 fontSize: 16,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),
                      //           ),
                      //           const SizedBox(
                      //             height: 5,
                      //           ),
                      //           Text(
                      //             offersReceivedModel.comment == ''
                      //                 ? 'No details provided'
                      //                 : offersReceivedModel.comment,
                      //             style: TextStyle(
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.w600,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     )
                      //   ],
                      // ),
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
                            Expanded(
                              child: Column(
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorWidget: (context, url, error) =>
                                        const SizedBox.shrink(),
                                    imageUrl:
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
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorWidget: (context, url, error) =>
                                        const SizedBox.shrink(),
                                    imageUrl:
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
                      if (offersReceivedModel.status == 'ignore')
                        Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Text(
                              'This offer was ignored by ${userModel.name}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      if (offersReceivedModel.status == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                Get.bottomSheet(
                                    OwnerIgnoreOfferConfirmationWidget(
                                        userController: userController,
                                        offersModel: offersModel,
                                        offersReceivedModel:
                                            offersReceivedModel));
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
                                    'Reject',
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/messenger.png',
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        height: 24,
                                        width: 24,
                                      ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        'Chat',
                                        style: TextStyle(
                                          // color: userController.isDark ? Colors.white : Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: () async {
                                Get.dialog(LoadingDialog(),
                                    barrierDismissible: false);

                                DocumentSnapshot<Map<String, dynamic>>
                                    offerByQuery = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(offersReceivedModel.offerBy)
                                        .get();
                                OffersController().acceptOffer(
                                    offersReceivedModel,
                                    offersModel,
                                    userModel,
                                    UserModel.fromJson(offerByQuery),
                                    chatId,
                                    garageModel);

                                NotificationController().sendNotification(
                                    userIds: [
                                      UserModel.fromJson(offerByQuery).userId
                                    ],
                                    offerId: offersModel.offerId,
                                    requestId: offersReceivedModel.id,
                                    title: 'Good News: Offer Accepted',
                                    subtitle:
                                        '${userController.userModel!.name} has accepted your offer. Tap here to review.');

                                OffersController().updateNotificationForOffers(
                                    offerId: offersModel.offerId,
                                    userId:
                                        UserModel.fromJson(offerByQuery).userId,
                                    isAdd: true,
                                    offersReceived: offersReceivedModel.id,
                                    senderId: userController.userModel!.userId,
                                    checkByList: offersModel.checkByList,
                                    notificationTitle:
                                        '${userController.userModel!.name} has accepted your offer',
                                    notificationSubtitle:
                                        '${userController.userModel!.name} has accepted your offer. Tap here to review.');
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
                                    'Accept',
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
                        ),
                      if (offersReceivedModel.status == 'Upcoming')
                        Column(
                          children: [
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
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/messenger.png',
                                            color: userController.isDark
                                                ? Colors.white
                                                : primaryColor,
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            'Chat',
                                            style: TextStyle(
                                              // color: userController.isDark ? Colors.white : Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                InkWell(
                                  onTap: () async {
                                    // Get.dialog(LoadingDialog(),
                                    //     barrierDismissible: false);
                                    // DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                                    //                                 await FirebaseFirestore.instance
                                    //                                     .collection('users')
                                    //                                     .doc(offersReceivedModel.offerBy)
                                    //                                     .get();
                                    //                                  Get.to(() => ReviewShareInvoice(
                                    //                       secondUser: UserModel.fromJson(offerByQuery),
                                    //                       offersModel: offersModel,
                                    //                       offersReceivedId: offersReceivedModel.id));
                                    // DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                                    //     await FirebaseFirestore.instance
                                    //         .collection('users')
                                    //         .doc(offersReceivedModel.offerBy)
                                    //         .get();
                                    Get.bottomSheet(
                                        OwnerCompleteOfferConfirmationSheet(
                                            offersReceivedModel:
                                                offersReceivedModel,
                                            offersModel: offersModel,
                                            userModel: userModel,
                                            chatId: chatId,
                                            garageModel: garageModel,
                                            userController: userController));
                                  },
                                  child: Container(
                                    height: 50,
                                    width: chatId != null
                                        ? Get.width * 0.43
                                        : Get.width * 0.29,
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () async {
                                Get.dialog(LoadingDialog(),
                                    barrierDismissible: false);

                                DocumentSnapshot<Map<String, dynamic>>
                                    serviceSnap = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(offersReceivedModel.offerBy)
                                        .get();
                                DocumentSnapshot<Map<String, dynamic>>
                                    ownerSnap = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(offersReceivedModel.ownerId)
                                        .get();
                                File? file =
                                    await PDFGenerator.createInvoicePDF(
                                        offersReceivedModel:
                                            offersReceivedModel,
                                        offersModel: offersModel,
                                        onwerModel:
                                            UserModel.fromJson(ownerSnap),
                                        isEmail: true,
                                        currentUserEmail: userModel.email,
                                        serviceModel:
                                            UserModel.fromJson(serviceSnap));
                                Get.close(1);

                                Get.to(() => ReviewShareInvoice(
                                      pdfFile: file!,
                                      invoiceNumber:
                                          offersReceivedModel.randomId,
                                    ));
                              },
                              child: Container(
                                height: 50,
                                width: Get.width * 0.9,
                                decoration: BoxDecoration(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'View Invoice',
                                    style: TextStyle(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (offersReceivedModel.status == 'Completed')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (offersReceivedModel.ratingOne == 0.0)
                              InkWell(
                                onTap: () async {
                                  Get.to(() => OwnerToServiceRatingSheet(
                                      offersReceivedModel: offersReceivedModel,
                                      offersModel: offersModel,
                                      isDark: userController.isDark));
                                },
                                child: Container(
                                  height: 50,
                                  width: Get.width * 0.42,
                                  decoration: BoxDecoration(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Feedback',
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
                            InkWell(
                              onTap: () async {
                                Get.dialog(LoadingDialog(),
                                    barrierDismissible: false);

                                DocumentSnapshot<Map<String, dynamic>>
                                    serviceSnap = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(offersReceivedModel.offerBy)
                                        .get();
                                DocumentSnapshot<Map<String, dynamic>>
                                    ownerSnap = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(offersReceivedModel.ownerId)
                                        .get();
                                File? file =
                                    await PDFGenerator.createInvoicePDF(
                                        offersReceivedModel:
                                            offersReceivedModel,
                                        offersModel: offersModel,
                                        onwerModel:
                                            UserModel.fromJson(ownerSnap),
                                        isEmail: true,
                                        currentUserEmail: userModel.email,
                                        serviceModel:
                                            UserModel.fromJson(serviceSnap));
                                Get.close(1);

                                Get.to(() => ReviewShareInvoice(
                                      pdfFile: file!,
                                      invoiceNumber:
                                          offersReceivedModel.randomId,
                                    ));
                              },
                              child: Container(
                                height: 50,
                                width: offersReceivedModel.ratingOne != 0.0
                                    ? Get.width * 0.9
                                    : Get.width * 0.42,
                                decoration: BoxDecoration(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    'View Invoice',
                                    style: TextStyle(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        fontSize: 15,
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
