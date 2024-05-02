// // ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

// import 'package:add_2_calendar/add_2_calendar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:vehype/Controllers/chat_controller.dart';
// import 'package:vehype/Controllers/garage_controller.dart';
// // import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:vehype/Controllers/user_controller.dart';
// import 'package:vehype/Models/chat_model.dart';
// import 'package:vehype/Models/offers_model.dart';
// import 'package:vehype/Models/user_model.dart';
// import 'package:vehype/Pages/message_page.dart';
// import 'package:vehype/Widgets/loading_dialog.dart';
// import 'package:vehype/Widgets/select_date_and_price.dart';
// import 'package:vehype/const.dart';

// import 'full_image_view_page.dart';
// import 'offers_received_details.dart';
// import 'received_offers_seeker.dart';

// class OrdersHistorySeeker extends StatefulWidget {
//   const OrdersHistorySeeker({super.key});

//   @override
//   State<OrdersHistorySeeker> createState() => _OrdersHistorySeekerState();
// }

// class _OrdersHistorySeekerState extends State<OrdersHistorySeeker> {
//   @override
//   void initState() {
//     super.initState();
//     getHistory();
//   }

//   getHistory() async {
//     final UserController userController =
//         Provider.of<UserController>(context, listen: false);
//     await userController.getRequestsHistorySeeker();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final UserController userController = Provider.of<UserController>(context);
//     UserModel userModel = userController.userModel!;
//     List<OffersReceivedModel> offersPending = userController.offersReceivedList
//         .where((element) => element.status == 'Pending')
//         .toList();
//     List<OffersReceivedModel> offersCompleted = userController
//         .offersReceivedList
//         .where((element) => element.status == 'Completed')
//         .toList();
//     List<OffersReceivedModel> offersCencelled = userController
//         .offersReceivedList
//         .where((element) => element.status == 'Cancelled')
//         .toList();
//     List<OffersReceivedModel> upcomingOffers = userController.offersReceivedList
//         .where((element) => element.status == 'Upcoming')
//         .toList();
//     return WillPopScope(
//       onWillPop: () async {
//         userController.cleanHistory();
//         return true;
//       },
//       child: DefaultTabController(
//         length: 4,
//         child: Scaffold(
//           backgroundColor: userController.isDark ? primaryColor : Colors.white,
//           appBar: AppBar(
//             elevation: 0.0,
//             backgroundColor:
//                 userController.isDark ? primaryColor : Colors.white,
//             centerTitle: true,
//             leading: IconButton(
//                 onPressed: () {
//                   userController.cleanHistory();

//                   Get.back();
//                 },
//                 icon: Icon(
//                   Icons.arrow_back_ios_new,
//                   color: userController.isDark ? Colors.white : primaryColor,
//                 )),
//             title: Text(
//               'Requests History',
//               style: TextStyle(
//                 color: userController.isDark ? Colors.white : primaryColor,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             bottom: TabBar(
//               isScrollable: true,
//               indicatorColor:
//                   userController.isDark ? Colors.white : primaryColor,
//               labelColor: userController.isDark ? Colors.white : primaryColor,
//               tabs: [
//                 Tab(
//                   text: 'Pending',
//                 ),
//                 Tab(
//                   text: 'Upcoming',
//                 ),
//                 Tab(
//                   text: 'Completed',
//                 ),
//                 Tab(
//                   text: 'Cancelled',
//                 ),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               Offers(
//                   userController: userController, offersPending: offersPending),
//               Offers(
//                   userController: userController,
//                   offersPending: upcomingOffers),
//               Offers(
//                   userController: userController,
//                   offersPending: offersCompleted),
//               Offers(
//                   userController: userController,
//                   offersPending: offersCencelled),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Offers extends StatelessWidget {
//   const Offers({
//     super.key,
//     required this.userController,
//     required this.offersPending,
//   });

//   final UserController userController;
//   final List<OffersReceivedModel> offersPending;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 0),
//       child: userController.historyLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 color: userController.isDark ? Colors.white : primaryColor,
//               ),
//             )
//           : offersPending.isEmpty
//               ? Center(
//                   child: Text(
//                     'No Offers Yet!',
//                     style: TextStyle(
//                       color:
//                           userController.isDark ? Colors.white : primaryColor,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: offersPending.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     OffersReceivedModel offersReceivedModel =
//                         offersPending[index];
//                     OffersModel offersModel = userController.historyOffers
//                         .firstWhere((element) =>
//                             element.offerId == offersReceivedModel.offerId);

//                     return OffersHistoryWidget(
//                         userController: userController,
//                         offersModel: offersModel,
//                         offersReceivedModel: offersReceivedModel);
//                   }),
//     );
//   }
// }

// class OffersHistoryWidget extends StatelessWidget {
//   const OffersHistoryWidget({
//     super.key,
//     required this.userController,
//     required this.offersModel,
//     required this.offersReceivedModel,
//   });

//   final UserController userController;

//   final OffersModel offersModel;
//   final OffersReceivedModel offersReceivedModel;

//   @override
//   Widget build(BuildContext context) {
//     List<String> vehicleInfo = offersModel.vehicleId.split(',');
//     final String vehicleType = vehicleInfo[0];
//     final String vehicleMake = vehicleInfo[1];
//     final String vehicleYear = vehicleInfo[2];
//     final String vehicleModle = vehicleInfo[3];
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 0, top: 15),
//       child: InkWell(
//         onTap: () async {},
//         child: Card(
//           color:
//               userController.isDark ? Colors.blueGrey.shade700 : Colors.white,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: Get.width * 0.9,
//                 height: Get.width * 0.35,
//                 child: Stack(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Get.to(() => FullImagePageView(
//                               url: offersModel.imageOne,
//                             ));
//                       },
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(4),
//                         child: ExtendedImage.network(
//                           offersModel.imageOne,
//                           width: Get.width * 0.9,
//                           height: Get.width * 0.35,
//                           fit: BoxFit.cover,
//                           cache: true,
//                           // border: Border.all(color: Colors.red, width: 1.0),
//                           shape: BoxShape.rectangle,
//                           borderRadius:
//                               const BorderRadius.all(Radius.circular(10.0)),
//                           //cancelToken: cancellationToken,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Body Style',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           vehicleType,
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Vehicle Make',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           vehicleMake,
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Vehicle Year',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           vehicleYear,
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Vehicle Model',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           vehicleModle,
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Issue',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           offersModel.issue,
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Start At:',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           formatDateTime(
//                               DateTime.parse(offersReceivedModel.startDate)
//                                   .toLocal()),
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'End At:',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           formatDateTime(
//                               DateTime.parse(offersReceivedModel.endDate)
//                                   .toLocal()),
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Price',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 13,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 5,
//                         ),
//                         Text(
//                           '\$${offersReceivedModel.price}',
//                           style: TextStyle(
//                             fontFamily: 'Avenir',
//                             fontWeight: FontWeight.w400,
//                             color: userController.isDark
//                                 ? Colors.white
//                                 : primaryColor,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               if (offersReceivedModel.status == 'Pending')
//                 Column(
//                   children: [
//                     _getButton(Colors.white, () async {
//                       Get.dialog(LoadingDialog(), barrierDismissible: false);
//                       DocumentSnapshot<Map<String, dynamic>> snap =
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(offersReceivedModel.ownerId)
//                               .get();
//                       UserModel ownerDetails = UserModel.fromJson(snap);
//                       ChatModel? chatModel = await ChatController().getChat(
//                           userController.userModel!.userId,
//                           ownerDetails.userId);
//                       if (chatModel == null) {
//                         await ChatController().createChat(
//                             userController.userModel!,
//                             ownerDetails,
//                             // offersReceivedModel,
//                             offersModel,
//                             'New Message',
//                             '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
//                             'chat');
//                         ChatModel? newchat = await ChatController().getChat(
//                             userController.userModel!.userId,
//                             ownerDetails.userId);
//                         Get.close(1);
//                         Get.to(() => MessagePage(
//                               chatModel: newchat!,
//                               secondUser: ownerDetails,
//                             ));
//                       } else {
//                         Get.close(1);

//                         Get.to(() => MessagePage(
//                               chatModel: chatModel,
//                               secondUser: ownerDetails,
//                             ));
//                       }
//                     }, 'Chat', Colors.green),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                     _getButton(
//                         userController.isDark ? primaryColor : Colors.white,
//                         () async {
//                       Get.dialog(LoadingDialog(), barrierDismissible: false);

//                       final GarageController garageController =
//                           Provider.of<GarageController>(context, listen: false);
//                       garageController.init(offersReceivedModel);

//                       DocumentSnapshot<Map<String, dynamic>> snap =
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(offersReceivedModel.ownerId)
//                               .get();
//                       Get.close(1);

//                       UserModel ownerDetails = UserModel.fromJson(snap);

//                       Get.bottomSheet(
//                         SelectDateAndPrice(
//                           offersModel: offersModel,
//                           ownerModel: ownerDetails,
//                           offersReceivedModel: offersReceivedModel,
//                         ),
//                       );
//                     }, 'Update', null),
//                   ],
//                 ),
//               if (offersReceivedModel.status == 'Upcoming')
//                 Column(
//                   children: [
//                     _getButton(Colors.white, () async {
//                       DocumentSnapshot<Map<String, dynamic>> snap =
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(offersReceivedModel.ownerId)
//                               .get();
//                       UserModel userModel = UserModel.fromJson(snap);
//                       Event event = Event(
//                         title: userModel.name,
//                         description: offersModel.vehicleId,
//                         // location: 'Event location',
//                         startDate: DateTime.parse(offersReceivedModel.startDate)
//                             .toLocal(),
//                         endDate: DateTime.parse(offersReceivedModel.endDate)
//                             .toLocal(),
//                       );
//                       Add2Calendar.addEvent2Cal(event);
//                     }, 'Add To Calendar', null),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     _getButton(Colors.white, () async {
//                       showModalBottomSheet(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           context: context,
//                           backgroundColor: userController.isDark
//                               ? primaryColor
//                               : Colors.white,
//                           builder: (context) {
//                             return BottomSheet(
//                                 onClosing: () {},
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 builder: (s) {
//                                   return Container(
//                                     width: Get.width,
//                                     decoration: BoxDecoration(
//                                       color: userController.isDark
//                                           ? primaryColor
//                                           : Colors.white,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     padding: const EdgeInsets.all(14),
//                                     child: SingleChildScrollView(
//                                       child: Column(
//                                         children: [
//                                           const SizedBox(
//                                             height: 10,
//                                           ),
//                                           Text(
//                                             'Are you sure? You won\'t be able to revert this action.',
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                               fontSize: 20,
//                                               fontFamily: 'Avenir',
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             height: 20,
//                                           ),
//                                           ElevatedButton(
//                                             onPressed: () async {
//                                               Get.close(1);
//                                               Get.dialog(LoadingDialog(),
//                                                   barrierDismissible: false);

//                                               await FirebaseFirestore.instance
//                                                   .collection('offersReceived')
//                                                   .doc(offersReceivedModel.id)
//                                                   .update({
//                                                 'status': 'Cancelled',
//                                               });
//                                               await userController
//                                                   .getRequestsHistoryProvider();
//                                               Get.close(1);
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: Colors.red,
//                                               elevation: 1.0,
//                                               maximumSize:
//                                                   Size(Get.width * 0.6, 50),
//                                               minimumSize:
//                                                   Size(Get.width * 0.6, 50),
//                                             ),
//                                             child: Text(
//                                               'Confirm',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontFamily: 'Avenir',
//                                                 color: Colors.white,
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             height: 20,
//                                           ),
//                                           InkWell(
//                                             onTap: () {
//                                               Get.close(1);
//                                             },
//                                             child: Text(
//                                               'Cancel',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontFamily: 'Avenir',
//                                                 fontWeight: FontWeight.w500,
//                                               ),
//                                             ),
//                                           ),
//                                           const SizedBox(height: 20),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 });
//                           });
//                     }, 'Cancel', Colors.red),
//                   ],
//                 ),
//               if (offersReceivedModel.status == 'Completed' &&
//                   offersReceivedModel.ratingOne == 0.0)
//                 _getButton(Colors.white, () {
//                   showModalBottomSheet(
//                       context: context,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       constraints: BoxConstraints(
//                         maxHeight: Get.height * 0.8,
//                         minHeight: Get.height * 0.8,
//                         minWidth: Get.width,
//                       ),
//                       isScrollControlled: true,
//                       builder: (contex) {
//                         return RatingSheet(
//                             offersReceivedModel: offersReceivedModel,
//                             offersModel: offersModel,
//                             isDark: userController.isDark);
//                       });
//                 }, 'Give Rating', null),
//               if (offersReceivedModel.status == 'Completed' &&
//                   offersReceivedModel.ratingOne != 0.0)
//                 RatingBarIndicator(
//                   rating: offersReceivedModel.ratingOne,
//                   itemBuilder: (context, _) => Icon(
//                     Icons.star,
//                     color: Colors.amber,
//                   ),
//                 ),
//               const SizedBox(
//                 height: 10,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   ElevatedButton _getButton(
//       Color textColor, Function? onTap, String text, Color? backColor) {
//     return ElevatedButton(
//       onPressed: onTap == null ? null : () => onTap(),
//       style: ElevatedButton.styleFrom(
//           backgroundColor: backColor ??
//               (userController.isDark ? Colors.white : primaryColor),
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
