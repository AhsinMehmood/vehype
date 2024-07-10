// import 'package:add_2_calendar/add_2_calendar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:vehype/Controllers/garage_controller.dart';
// import 'package:vehype/Controllers/user_controller.dart';
// import 'package:vehype/Models/offers_model.dart';
// import 'package:vehype/Models/user_model.dart';
// import 'package:vehype/Pages/full_image_view_page.dart';
// import 'package:vehype/Pages/orders_history_provider.dart';
// import 'package:vehype/Widgets/loading_dialog.dart';
// import 'package:vehype/Widgets/offer_request_details.dart';
// import 'package:vehype/Widgets/select_date_and_price.dart';
// import 'package:vehype/const.dart';

// import '../Controllers/vehicle_data.dart';
// import 'inactive_offers_seeker.dart';
// import 'offers_received_details.dart';

// class RequestDetailsChatPage extends StatelessWidget {
//   final String offerId;
//   const RequestDetailsChatPage({super.key, required this.offerId});

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
//       body: StreamBuilder<OffersModel>(
//           stream: FirebaseFirestore.instance
//               .collection('offers')
//               .doc(offerId)
//               .snapshots()
//               .map((event) => OffersModel.fromJson(event)),
//           builder: (context, AsyncSnapshot<OffersModel> snap) {
//             if (snap.data != null) {
//               return StreamBuilder<OffersReceivedModel>(
//                   stream: FirebaseFirestore.instance
//                       .collection('offersReceived')
//                       .where('offerBy', isEqualTo: userModel.userId)
//                       .where('offerId', isEqualTo: offerId)
//                       .snapshots()
//                       .map((event) =>
//                           OffersReceivedModel.fromJson(event.docs.first)),
//                   builder: (context, snapshot) {
//                     if (snapshot.data != null) {
//                       return OffersHistoryWidgetChat(
//                           userController: userController,
//                           offersModel: snap.data!,
//                           offersReceivedModel: snapshot.data!);
//                     }
//                     if (snapshot.hasError) {
//                       OffersModel offersModel = snap.data!;

//                       return OfferReceivedDetails(
//                         offersModel: offersModel,
//                         isChat: true,
//                       );
//                     }
//                     OffersModel offersModel = snap.data!;

//                     return OfferReceivedDetails(
//                       offersModel: offersModel,
//                       isChat: true,
//                     );
//                   });
//             }
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }),
//     );
//   }
// }

// class OffersHistoryWidgetChat extends StatelessWidget {
//   const OffersHistoryWidgetChat({
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
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: Get.width,
//               height: Get.width * 0.35,
//               child: Stack(
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Get.to(() => FullImagePageView(
//                             urls: [offersModel.imageOne],
//                           ));
//                     },
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(4),
//                       child: ExtendedImage.network(
//                         offersModel.imageOne,
//                         width: Get.width,
//                         height: Get.width * 0.35,
//                         fit: BoxFit.cover,
//                         cache: true,
//                         // border: Border.all(color: Colors.red, width: 1.0),
//                         shape: BoxShape.rectangle,
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(10.0)),
//                         //cancelToken: cancellationToken,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Body Style',
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         vehicleType,
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         'Vehicle Make',
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         vehicleMake,
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         'Vehicle Year',
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         vehicleYear,
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         'Vehicle Model',
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Text(
//                         vehicleModle,
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         'Issue',
//                         style: TextStyle(
//                           fontFamily: 'Avenir',
//                           fontWeight: FontWeight.w400,
//                           color: userController.isDark
//                               ? Colors.white
//                               : primaryColor,
//                           fontSize: 13,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           SvgPicture.asset(
//                               getServices()
//                                   .firstWhere((element) =>
//                                       element.name == offersModel.issue)
//                                   .image,
//                               color: userController.isDark
//                                   ? Colors.white
//                                   : primaryColor,
//                               height: 15,
//                               width: 15),
//                           const SizedBox(
//                             width: 8,
//                           ),
//                           Text(
//                             offersModel.issue,
//                             style: TextStyle(
//                               fontFamily: 'Avenir',
//                               fontWeight: FontWeight.w400,
//                               color: userController.isDark
//                                   ? Colors.white
//                                   : primaryColor,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       OfferRequestDetails(
//                           userController: userController,
//                           offersReceivedModel: offersReceivedModel)
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (offersReceivedModel.status == 'Pending')
//               Column(
//                 children: [
//                   const SizedBox(
//                     height: 8,
//                   ),
//                   _getButton(
//                       userController.isDark ? primaryColor : Colors.white,
//                       () async {
//                     Get.dialog(LoadingDialog(), barrierDismissible: false);

//                     final GarageController garageController =
//                         Provider.of<GarageController>(context, listen: false);
//                     garageController.init(offersReceivedModel);

//                     DocumentSnapshot<Map<String, dynamic>> snap =
//                         await FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(offersReceivedModel.ownerId)
//                             .get();
//                     Get.close(1);

//                     UserModel ownerDetails = UserModel.fromJson(snap);

//                     Get.to(
//                       () => SelectDateAndPrice(
//                         offersModel: offersModel,
//                         ownerModel: ownerDetails,
//                         offersReceivedModel: offersReceivedModel,
//                       ),
//                     );
//                   }, 'Update', null),
//                 ],
//               ),
//             if (offersReceivedModel.status == 'Upcoming')
//               Column(
//                 children: [
//                   _getButton(
//                       userController.isDark ? primaryColor : Colors.white,
//                       () async {
//                     DocumentSnapshot<Map<String, dynamic>> snap =
//                         await FirebaseFirestore.instance
//                             .collection('users')
//                             .doc(offersReceivedModel.ownerId)
//                             .get();
//                     UserModel userModel = UserModel.fromJson(snap);
//                     Event event = Event(
//                       title: userModel.name,
//                       description: offersModel.vehicleId,
//                       // location: 'Event location',
//                       startDate: DateTime.parse(offersReceivedModel.startDate)
//                           .toLocal(),
//                       endDate:
//                           DateTime.parse(offersReceivedModel.endDate).toLocal(),
//                     );
//                     Add2Calendar.addEvent2Cal(event);
//                   }, 'Add To Calendar', null),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   _getButton(Colors.white, () async {
//                     showModalBottomSheet(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         context: context,
//                         backgroundColor:
//                             userController.isDark ? primaryColor : Colors.white,
//                         builder: (context) {
//                           return BottomSheet(
//                               onClosing: () {},
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               builder: (s) {
//                                 return Container(
//                                   width: Get.width,
//                                   decoration: BoxDecoration(
//                                     color: userController.isDark
//                                         ? primaryColor
//                                         : Colors.white,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   padding: const EdgeInsets.all(14),
//                                   child: SingleChildScrollView(
//                                     child: Column(
//                                       children: [
//                                         const SizedBox(
//                                           height: 10,
//                                         ),
//                                         Text(
//                                           'Are you sure? You won\'t be able to revert this action.',
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                             fontSize: 20,
//                                             fontFamily: 'Avenir',
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 20,
//                                         ),
//                                         ElevatedButton(
//                                           onPressed: () async {
//                                             Get.close(1);
//                                             Get.dialog(LoadingDialog(),
//                                                 barrierDismissible: false);

//                                             await FirebaseFirestore.instance
//                                                 .collection('offersReceived')
//                                                 .doc(offersReceivedModel.id)
//                                                 .update({
//                                               'status': 'Cancelled',
//                                               'cancelBy': 'provider',
//                                             });
//                                             await userController
//                                                 .getRequestsHistoryProvider();
//                                             Get.close(1);
//                                           },
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.red,
//                                             elevation: 1.0,
//                                             maximumSize:
//                                                 Size(Get.width * 0.6, 50),
//                                             minimumSize:
//                                                 Size(Get.width * 0.6, 50),
//                                           ),
//                                           child: Text(
//                                             'Confirm',
//                                             style: TextStyle(
//                                               fontSize: 20,
//                                               fontFamily: 'Avenir',
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 20,
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             Get.close(1);
//                                           },
//                                           child: Text(
//                                             'Cancel',
//                                             style: TextStyle(
//                                               fontSize: 20,
//                                               fontFamily: 'Avenir',
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(height: 20),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               });
//                         });
//                   }, 'Cancel', Colors.red),
//                 ],
//               ),
//             if (offersReceivedModel.status == 'Completed' &&
//                 offersReceivedModel.ratingOne == 0.0)
//               _getButton(Colors.white, () {
//                 showModalBottomSheet(
//                     context: context,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     constraints: BoxConstraints(
//                       maxHeight: Get.height * 0.9,
//                       minHeight: Get.height * 0.9,
//                       minWidth: Get.width,
//                     ),
//                     isScrollControlled: true,
//                     builder: (contex) {
//                       return RatingSheet(
//                           offersReceivedModel: offersReceivedModel,
//                           offersModel: offersModel,
//                           isDark: userController.isDark);
//                     });
//               }, 'Give Rating', null),
//             if (offersReceivedModel.status == 'Completed' &&
//                 offersReceivedModel.ratingOne != 0.0)
//               RatingBarIndicator(
//                 rating: offersReceivedModel.ratingOne,
//                 itemBuilder: (context, _) => Icon(
//                   Icons.star,
//                   color: Colors.amber,
//                 ),
//               ),
//             const SizedBox(
//               height: 10,
//             ),
//           ],
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
