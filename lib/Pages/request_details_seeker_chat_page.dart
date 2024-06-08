// // ignore_for_file: prefer_const_constructors

// import 'package:add_2_calendar/add_2_calendar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:swipeable_tile/swipeable_tile.dart';
// import 'package:vehype/Models/offers_model.dart';
// import 'package:vehype/Widgets/select_date_and_price.dart';
// import 'package:vehype/const.dart';

// import '../Controllers/user_controller.dart';
// import '../Models/user_model.dart';
// import '../Widgets/loading_dialog.dart';
// import 'comments_page.dart';
// import 'inactive_offers_seeker.dart';
// import 'repair_page.dart';

// class RequestDetailsSeekerChatPage extends StatelessWidget {
//   final OffersModel offersModel;
//   final String offerReceivedId;
//   const RequestDetailsSeekerChatPage(
//       {super.key, required this.offersModel, required this.offerReceivedId});

//   @override
//   Widget build(BuildContext context) {
//     final UserController userController = Provider.of<UserController>(context);
//     UserModel userModel = userController.userModel!;

//     return Scaffold(
//       backgroundColor: userController.isDark ? primaryColor : Colors.white,
//       appBar: AppBar(
//         backgroundColor: userController.isDark ? primaryColor : Colors.white,
//         elevation: 0.0,
//         title: Text(
//           'Request Details',
//           style: TextStyle(
//             fontFamily: 'Avenir',
//             fontWeight: FontWeight.w800,
//             color: userController.isDark ? Colors.white : primaryColor,
//             fontSize: 17,
//           ),
//         ),
//         leading: IconButton(
//             onPressed: () {
//               // chatController.cleanController();
//               // FirebaseFirestore.instance
//               //     .collection('users')
//               //     .doc(userModel.userId)
//               //     .update({
//               //   'unread': false,
//               // });
//               Get.back();
//             },
//             icon: Icon(
//               Icons.arrow_back_ios_new,
//               size: 24,
//               color: userController.isDark ? Colors.white : primaryColor,
//             )),
//       ),
//       body: StreamBuilder<OffersReceivedModel>(
//           stream: FirebaseFirestore.instance
//               .collection('offersReceived')
//               .doc(offerReceivedId)
//               .snapshots()
//               .map((event) => OffersReceivedModel.fromJson(event)),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               OffersReceivedModel offersReceivedModel = snapshot.data!;
//               return offersModel.status == 'inactive'
//                   ? StreamBuilder<UserModel>(
//                       stream: FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(offersReceivedModel.offerBy)
//                           .snapshots()
//                           .map((newEvent) => UserModel.fromJson(newEvent)),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator(
//                               color: userController.isDark
//                                   ? Colors.white
//                                   : primaryColor,
//                             ),
//                           );
//                         }
//                         UserModel postedByDetails = snapshot.data!;
//                         return Container(
//                           // color: Colors.white,
//                           padding: const EdgeInsets.all(15),
//                           child: Column(
//                             children: [
//                               Row(
//                                 // mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(200),
//                                     child: ExtendedImage.network(
//                                       postedByDetails.profileUrl,
//                                       width: 75,
//                                       height: 75,
//                                       fit: BoxFit.fill,
//                                       cache: true,
//                                       // border: Border.all(color: Colors.red, width: 1.0),
//                                       shape: BoxShape.circle,
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(200.0)),
//                                       //cancelToken: cancellationToken,
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         postedByDetails.name,
//                                         style: TextStyle(
//                                           color: userController.isDark
//                                               ? Colors.white
//                                               : primaryColor,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w800,
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 8,
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           Get.to(() => CommentsPage(
//                                               data: postedByDetails));
//                                         },
//                                         child: Row(
//                                           children: [
//                                             RatingBarIndicator(
//                                               rating: postedByDetails.rating,
//                                               itemBuilder: (context, index) =>
//                                                   const Icon(
//                                                 Icons.star,
//                                                 color: Colors.amber,
//                                               ),
//                                               itemCount: 5,
//                                               itemSize: 25.0,
//                                               direction: Axis.horizontal,
//                                             ),
//                                             const SizedBox(
//                                               width: 10,
//                                             ),
//                                             Text(
//                                               postedByDetails.ratings.length
//                                                   .toString(),
//                                               style: TextStyle(
//                                                 color: userController.isDark
//                                                     ? Colors.white
//                                                     : primaryColor,
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.w800,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 20,
//                               ),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Price: \$${offersReceivedModel.price}',
//                                     style: const TextStyle(
//                                       fontFamily: 'Avenir',
//                                       fontWeight: FontWeight.w400,
//                                       // color: Colors.black,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'Start At: ${formatDateTime(DateTime.parse(offersReceivedModel.startDate).toLocal())}',
//                                     style: const TextStyle(
//                                       fontFamily: 'Avenir',
//                                       fontWeight: FontWeight.w400,
//                                       // color: Colors.black,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 10,
//                               ),
//                               Row(
//                                 children: [
//                                   Text(
//                                     'End At: ${formatDateTime(DateTime.parse(offersReceivedModel.endDate).toLocal())}',
//                                     style: const TextStyle(
//                                       fontFamily: 'Avenir',
//                                       fontWeight: FontWeight.w400,
//                                       // color: Colors.black,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 40,
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   if (offersReceivedModel.status == 'Upcoming')
//                                     if (offersReceivedModel.status ==
//                                         'Upcoming')
//                                       _getButton(Colors.white, () async {
//                                         showModalBottomSheet(
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                             ),
//                                             context: context,
//                                             backgroundColor:
//                                                 userController.isDark
//                                                     ? primaryColor
//                                                     : Colors.white,
//                                             builder: (context) {
//                                               return BottomSheet(
//                                                   onClosing: () {},
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             10),
//                                                   ),
//                                                   builder: (s) {
//                                                     return Container(
//                                                       width: Get.width,
//                                                       decoration: BoxDecoration(
//                                                         color: userController
//                                                                 .isDark
//                                                             ? primaryColor
//                                                             : Colors.white,
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(10),
//                                                       ),
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               14),
//                                                       child:
//                                                           SingleChildScrollView(
//                                                         child: Column(
//                                                           children: [
//                                                             const SizedBox(
//                                                               height: 10,
//                                                             ),
//                                                             Text(
//                                                               'Are you sure? You won\'t be able to revert this action.',
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               style: TextStyle(
//                                                                 fontSize: 20,
//                                                                 fontFamily:
//                                                                     'Avenir',
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                               height: 20,
//                                                             ),
//                                                             ElevatedButton(
//                                                               onPressed:
//                                                                   () async {
//                                                                 Get.dialog(
//                                                                     LoadingDialog(),
//                                                                     barrierDismissible:
//                                                                         false);

//                                                                 await FirebaseFirestore
//                                                                     .instance
//                                                                     .collection(
//                                                                         'offersReceived')
//                                                                     .doc(
//                                                                         offersReceivedModel
//                                                                             .id)
//                                                                     .update({
//                                                                   'status':
//                                                                       'Cancelled',
//                                                                   'cancelBy':
//                                                                       'owner',
//                                                                 });
//                                                                 sendNotification(
//                                                                     offersReceivedModel
//                                                                         .offerBy,
//                                                                     userModel
//                                                                         .name,
//                                                                     'Offer Update',
//                                                                     '${userModel.name}, Cancelled the offer',
//                                                                     offersReceivedModel
//                                                                         .id,
//                                                                     'Offer',
//                                                                     '');

//                                                                 Get.close(2);
//                                                               },
//                                                               style:
//                                                                   ElevatedButton
//                                                                       .styleFrom(
//                                                                 backgroundColor:
//                                                                     Colors.red,
//                                                                 elevation: 1.0,
//                                                                 maximumSize: Size(
//                                                                     Get.width *
//                                                                         0.6,
//                                                                     50),
//                                                                 minimumSize: Size(
//                                                                     Get.width *
//                                                                         0.6,
//                                                                     50),
//                                                               ),
//                                                               child: Text(
//                                                                 'Confirm',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 20,
//                                                                   fontFamily:
//                                                                       'Avenir',
//                                                                   color: Colors
//                                                                       .white,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                               height: 20,
//                                                             ),
//                                                             InkWell(
//                                                               onTap: () {
//                                                                 Get.close(1);
//                                                               },
//                                                               child: Text(
//                                                                 'Cancel',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 20,
//                                                                   fontFamily:
//                                                                       'Avenir',
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             const SizedBox(
//                                                                 height: 20),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     );
//                                                   });
//                                             });
//                                       }, 'Cancel', context, Colors.red),

//                                   if (offersReceivedModel.status ==
//                                           'Cancelled' &&
//                                       offersReceivedModel.cancelBy ==
//                                           'provider' &&
//                                       offersReceivedModel.ratingTwo == 0.0)
//                                     _getButton(Colors.white, () {
//                                       showModalBottomSheet(
//                                           context: context,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           constraints: BoxConstraints(
//                                             maxHeight: Get.height * 0.8,
//                                             minHeight: Get.height * 0.8,
//                                             minWidth: Get.width,
//                                           ),
//                                           isScrollControlled: true,
//                                           builder: (contex) {
//                                             return RatingSheet2(
//                                                 offersReceivedModel:
//                                                     offersReceivedModel,
//                                                 offersModel: offersModel,
//                                                 isDark: userController.isDark);
//                                           });
//                                     }, 'Give Rating', context, primaryColor),
//                                   if (offersReceivedModel.status ==
//                                           'Completed' &&
//                                       offersReceivedModel.ratingTwo == 0.0)
//                                     _getButton(Colors.white, () {
//                                       showModalBottomSheet(
//                                           context: context,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           constraints: BoxConstraints(
//                                             maxHeight: Get.height * 0.8,
//                                             minHeight: Get.height * 0.8,
//                                             minWidth: Get.width,
//                                           ),
//                                           isScrollControlled: true,
//                                           builder: (contex) {
//                                             return RatingSheet2(
//                                                 offersReceivedModel:
//                                                     offersReceivedModel,
//                                                 offersModel: offersModel,
//                                                 isDark: userController.isDark);
//                                           });
//                                     }, 'Give Rating', context, primaryColor),

//                                   // else
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 15,
//                               ),
//                               if (offersReceivedModel.status == 'Upcoming')
//                                 _getButton(Colors.white, () async {
//                                   DocumentSnapshot<Map<String, dynamic>> snap =
//                                       await FirebaseFirestore.instance
//                                           .collection('users')
//                                           .doc(offersReceivedModel.ownerId)
//                                           .get();
//                                   UserModel userModel =
//                                       UserModel.fromJson(snap);
//                                   Event event = Event(
//                                     title: userModel.name,
//                                     description: offersModel.vehicleId,
//                                     // location: 'Event location',
//                                     startDate: DateTime.parse(
//                                             offersReceivedModel.startDate)
//                                         .toLocal(),
//                                     endDate: DateTime.parse(
//                                             offersReceivedModel.endDate)
//                                         .toLocal(),
//                                   );
//                                   Add2Calendar.addEvent2Cal(event);
//                                 }, 'Add To Calendar', context, primaryColor),
//                               if (offersReceivedModel.status == 'Upcoming')
//                                 Column(
//                                   children: [
//                                     const SizedBox(
//                                       height: 15,
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () async {
//                                         Get.dialog(LoadingDialog(),
//                                             barrierDismissible: false);

//                                         await FirebaseFirestore.instance
//                                             .collection('offersReceived')
//                                             .doc(offersReceivedModel.id)
//                                             .update({
//                                           'status': 'Completed',
//                                           // 'cancelBy': 'owner',
//                                         });

//                                         Get.close(2);
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.green,
//                                         elevation: 1.0,
//                                         maximumSize: Size(Get.width * 0.85, 50),
//                                         minimumSize: Size(Get.width * 0.85, 50),
//                                       ),
//                                       child: Text(
//                                         'Complete',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontFamily: 'Avenir',
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               const SizedBox(
//                                 height: 20,
//                               ),
//                             ],
//                           ),
//                         );
//                       })
//                   : StreamBuilder<UserModel>(
//                       stream: FirebaseFirestore.instance
//                           .collection('users')
//                           .doc(offersReceivedModel.offerBy)
//                           .snapshots()
//                           .map((newEvent) => UserModel.fromJson(newEvent)),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return Center(
//                             child: CircularProgressIndicator(
//                               color: userController.isDark
//                                   ? Colors.white
//                                   : primaryColor,
//                             ),
//                           );
//                         }
//                         UserModel postedByDetails = snapshot.data!;
//                         return SwipeableTile(
//                           color: Colors.black,
//                           swipeThreshold: 0.2,
//                           direction: SwipeDirection.horizontal,
//                           onSwiped: (direction) async {
//                             if (direction == SwipeDirection.startToEnd) {
//                               Get.dialog(const LoadingDialog(),
//                                   barrierDismissible: false);
//                               await FirebaseFirestore.instance
//                                   .collection('offersReceived')
//                                   .doc(offersReceivedModel.id)
//                                   .update({
//                                 'status': 'Upcoming',
//                               });
//                               await FirebaseFirestore.instance
//                                   .collection('offers')
//                                   .doc(offersModel.offerId)
//                                   .update({
//                                 'status': 'inactive',
//                               });
//                               sendNotification(
//                                   offersReceivedModel.offerBy,
//                                   userModel.name,
//                                   'Offer Update',
//                                   '${userModel.name}, Accepted the offer',
//                                   offersReceivedModel.id,
//                                   'Offer',
//                                   '');

//                               // ChatModel? chatModel =
//                               //     await ChatController().getChat(
//                               //         userModel.userId,
//                               //         postedByDetails.userId,
//                               //         widget.offersModel.offerId);
//                             } else {
//                               await FirebaseFirestore.instance
//                                   .collection('offersReceived')
//                                   .doc(offersReceivedModel.id)
//                                   .update({
//                                 'status': 'ignore',
//                               });
//                             }
//                           },
//                           backgroundBuilder: (context, direction, progress) {
//                             if (direction == SwipeDirection.endToStart) {
//                               return Container(
//                                 color: Colors.red,
//                                 padding: const EdgeInsets.all(15),
//                                 child: const Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       'Ignore',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                               // return your widget
//                             } else if (direction == SwipeDirection.startToEnd) {
//                               // return your widget
//                               return Container(
//                                 color: Colors.green,
//                                 padding: const EdgeInsets.all(15),
//                                 child: const Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Accept',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }
//                             return Container(
//                               color: Colors.green,
//                               padding: const EdgeInsets.all(15),
//                               child: const Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Ignore',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                           key: UniqueKey(),
//                           child: Container(
//                             color: userController.isDark
//                                 ? Colors.blueGrey
//                                 : Colors.white,
//                             padding: const EdgeInsets.all(15),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   // mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius: BorderRadius.circular(200),
//                                       child: ExtendedImage.network(
//                                         postedByDetails.profileUrl,
//                                         width: 75,
//                                         height: 75,
//                                         fit: BoxFit.fill,
//                                         cache: true,
//                                         // border: Border.all(color: Colors.red, width: 1.0),
//                                         shape: BoxShape.circle,
//                                         borderRadius: const BorderRadius.all(
//                                             Radius.circular(200.0)),
//                                         //cancelToken: cancellationToken,
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 10,
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           postedByDetails.name,
//                                           style: TextStyle(
//                                             color: userController.isDark
//                                                 ? Colors.white
//                                                 : primaryColor,
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.w800,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 8,
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             Get.to(() => CommentsPage(
//                                                 data: postedByDetails));
//                                           },
//                                           child: Row(
//                                             children: [
//                                               RatingBarIndicator(
//                                                 rating: postedByDetails.rating,
//                                                 itemBuilder: (context, index) =>
//                                                     const Icon(
//                                                   Icons.star,
//                                                   color: Colors.amber,
//                                                 ),
//                                                 itemCount: 5,
//                                                 itemSize: 25.0,
//                                                 direction: Axis.horizontal,
//                                               ),
//                                               const SizedBox(
//                                                 width: 10,
//                                               ),
//                                               Text(
//                                                 postedByDetails.ratings.length
//                                                     .toString(),
//                                                 style: TextStyle(
//                                                   color: userController.isDark
//                                                       ? Colors.white
//                                                       : primaryColor,
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.w800,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'Price: \$${offersReceivedModel.price}',
//                                       style: const TextStyle(
//                                         fontFamily: 'Avenir',
//                                         fontWeight: FontWeight.w400,
//                                         // color: Colors.black,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'Start At: ${formatDateTime(DateTime.parse(offersReceivedModel.startDate).toLocal())}',
//                                       style: const TextStyle(
//                                         fontFamily: 'Avenir',
//                                         fontWeight: FontWeight.w400,
//                                         // color: Colors.black,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'End At: ${formatDateTime(DateTime.parse(offersReceivedModel.endDate).toLocal())}',
//                                       style: const TextStyle(
//                                         fontFamily: 'Avenir',
//                                         fontWeight: FontWeight.w400,
//                                         // color: Colors.black,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 40,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceAround,
//                                   children: [
//                                     _getButton(Colors.white, () async {
//                                       Get.dialog(const LoadingDialog(),
//                                           barrierDismissible: false);
//                                       await FirebaseFirestore.instance
//                                           .collection('offersReceived')
//                                           .doc(offersReceivedModel.id)
//                                           .update({
//                                         'status': 'Upcoming',
//                                       });
//                                       await FirebaseFirestore.instance
//                                           .collection('offers')
//                                           .doc(offersModel.offerId)
//                                           .update({
//                                         'status': 'inactive',
//                                       });
//                                       sendNotification(
//                                           offersReceivedModel.offerBy,
//                                           userModel.name,
//                                           'Offer Update',
//                                           '${userModel.name}, Accepted the offer',
//                                           offersReceivedModel.id,
//                                           'Offer',
//                                           '');
//                                       Get.close(2);
//                                     }, 'Accept', context, Colors.green),

//                                     // else
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       });
//             }
//             return Center();
//           }),
//     );
//   }

//   ElevatedButton _getButton(Color textColor, Function? onTap, String text,
//       BuildContext context, Color back) {
//     final UserController userController = Provider.of<UserController>(context);

//     return ElevatedButton(
//       onPressed: onTap == null ? null : () => onTap(),
//       style: ElevatedButton.styleFrom(
//           backgroundColor: back,
//           elevation: 0.0,
//           fixedSize: Size(Get.width * 0.8, 40),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(3),
//           )),
//       child: Text(
//         text,
//         style: TextStyle(color: textColor),
//       ),
//     );
//   }
// }
