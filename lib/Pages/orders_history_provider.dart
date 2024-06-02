// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/garage_controller.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/message_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import 'full_image_view_page.dart';
import 'offers_received_details.dart';
import 'offers_tab_page.dart';
import 'received_offers_seeker.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrdersHistoryProvider extends StatefulWidget {
  const OrdersHistoryProvider({super.key});

  @override
  State<OrdersHistoryProvider> createState() => _OrdersHistoryProviderState();
}

class _OrdersHistoryProviderState extends State<OrdersHistoryProvider> {
  @override
  void initState() {
    super.initState();
    getHistory();
  }

  getHistory() async {
    final UserController userController =
        Provider.of<UserController>(context, listen: false);
    await userController.getRequestsHistoryProvider();
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          centerTitle: true,
          title: Text(
            'Offers',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabs: [
              Tab(
                text: 'New',
              ),
              Tab(
                text: 'Pending',
              ),
              Tab(
                text: 'Upcoming',
              ),
              Tab(
                text: 'Completed',
              ),
              Tab(
                text: 'Cancelled',
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<OffersReceivedModel>>(
            stream: FirebaseFirestore.instance
                .collection('offersReceived')
                .where('offerBy', isEqualTo: userModel.userId)
                .orderBy('createdAt', descending: true)
                .snapshots()
                .map((event) => event.docs
                    .map((e) => OffersReceivedModel.fromJson(e))
                    .toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              List<OffersReceivedModel> offersReceivedList =
                  snapshot.data ?? [];
              List<OffersReceivedModel> offersPending = offersReceivedList
                  .where((element) => element.status == 'Pending')
                  .toList();
              List<OffersReceivedModel> offersCompleted = offersReceivedList
                  .where((element) => element.status == 'Completed')
                  .toList();
              List<OffersReceivedModel> offersCencelled = offersReceivedList
                  .where((element) => element.status == 'Cancelled')
                  .toList();
              List<OffersReceivedModel> upcomingOffers = offersReceivedList
                  .where((element) => element.status == 'Upcoming')
                  .toList();
              return TabBarView(
                children: [
                  NewOffers(
                      userController: userController, userModel: userModel),
                  Offers(
                      userController: userController,
                      emptyText: 'No Pending Offers',
                      offersPending: offersPending),
                  Offers(
                      userController: userController,
                      emptyText: 'No Upcoming Offers',
                      offersPending: upcomingOffers),
                  Offers(
                      userController: userController,
                      emptyText: 'No Completed Offers',
                      offersPending: offersCompleted),
                  Offers(
                      userController: userController,
                      emptyText: 'No Cancelled Offers',
                      offersPending: offersCencelled),
                ],
              );
            }),
      ),
    );
  }
}

class Offers extends StatelessWidget {
  const Offers({
    super.key,
    required this.userController,
    required this.offersPending,
    required this.emptyText,
  });

  final String emptyText;

  final UserController userController;
  final List<OffersReceivedModel> offersPending;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 0),
      child: userController.historyLoading
          ? Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            )
          : offersPending.isEmpty
              ? Center(
                  child: Text(
                    'No Offers Yet!',
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: offersPending.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    OffersReceivedModel offersReceivedModel =
                        offersPending[index];
                    // OffersModel offersModel = userController.historyOffers
                    //     .firstWhere((element) =>
                    //         element.offerId == offersReceivedModel.offerId);
                    // print(offersReceivedModel.id);

                    return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('offers')
                            .doc(offersReceivedModel.offerId)
                            .snapshots(),
                        builder: (context, AsyncSnapshot offerSnap) {
                          if (!offerSnap.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            );
                          }
                          if (offerSnap.hasError) {
                            return Text(offerSnap.stackTrace.toString());
                          }
                          OffersModel offersModel =
                              OffersModel.fromJson(offerSnap.data);

                          return OffersHistoryWidget(
                              userController: userController,
                              offersModel: offersModel,
                              offersReceivedModel: offersReceivedModel);
                        });
                  }),
    );
  }
}

class OffersHistoryWidget extends StatelessWidget {
  const OffersHistoryWidget({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.offersReceivedModel,
  });

  final UserController userController;

  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;

  @override
  Widget build(BuildContext context) {
    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0].trim();
    final String vehicleMake = vehicleInfo[1].trim();
    final String vehicleYear = vehicleInfo[2].trim();
    final String vehicleModle = vehicleInfo[3].trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 15),
      child: InkWell(
        onTap: () async {},
        child: Card(
          color:
              userController.isDark ? Colors.blueGrey.shade700 : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VehicleDetailsRequest(
                        userController: userController,
                        vehicleType: vehicleType,
                        vehicleMake: vehicleMake,
                        vehicleYear: vehicleYear,
                        vehicleModle: vehicleModle,
                        offersModel: offersModel),
                  ],
                ),
              ),

              // OfferReceivedDetails(offersModel: offersModel),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OfferRequestDetails(
                      userController: userController,
                      offersReceivedModel: offersReceivedModel),
                ),
              ),
              if (offersReceivedModel.status == 'Pending')
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _getButton(Colors.white, () async {
                      Get.dialog(LoadingDialog(), barrierDismissible: false);
                      DocumentSnapshot<Map<String, dynamic>> snap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(offersReceivedModel.ownerId)
                              .get();
                      UserModel ownerDetails = UserModel.fromJson(snap);
                      ChatModel? chatModel = await ChatController().getChat(
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
                        ChatModel? newchat = await ChatController().getChat(
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
                    }, 'Chat', Colors.green),
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                builder: (s) {
                                  return Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Are you sure? You won\'t be able to revert this action.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.close(1);
                                              Get.dialog(LoadingDialog(),
                                                  barrierDismissible: false);

                                              await FirebaseFirestore.instance
                                                  .collection('offersReceived')
                                                  .doc(offersReceivedModel.id)
                                                  .update({
                                                'status': 'Cancelled',
                                                'cancelBy': 'provider',
                                              });
                                              await userController
                                                  .getRequestsHistoryProvider();
                                              Get.close(1);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              elevation: 1.0,
                                              maximumSize:
                                                  Size(Get.width * 0.6, 50),
                                              minimumSize:
                                                  Size(Get.width * 0.6, 50),
                                            ),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Avenir',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
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
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          });
                    }, 'Cancel', Colors.red),
                    const SizedBox(
                      height: 8,
                    ),
                    _getButton(
                        userController.isDark ? primaryColor : Colors.white,
                        () async {
                      Get.dialog(LoadingDialog(), barrierDismissible: false);

                      final GarageController garageController =
                          Provider.of<GarageController>(context, listen: false);
                      garageController.init(offersReceivedModel);

                      DocumentSnapshot<Map<String, dynamic>> snap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(offersReceivedModel.ownerId)
                              .get();
                      Get.close(1);

                      UserModel ownerDetails = UserModel.fromJson(snap);

                      Get.to(
                        () => SelectDateAndPrice(
                          offersModel: offersModel,
                          ownerModel: ownerDetails,
                          offersReceivedModel: offersReceivedModel,
                        ),
                      );
                    }, 'Update', null),
                  ],
                ),
              if (offersReceivedModel.status == 'Upcoming')
                Column(
                  children: [
                    _getButton(
                        userController.isDark ? primaryColor : Colors.white,
                        () async {
                      DocumentSnapshot<Map<String, dynamic>> snap =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(offersReceivedModel.ownerId)
                              .get();
                      UserModel userModel = UserModel.fromJson(snap);
                      Event event = Event(
                        title: userModel.name,
                        description: offersModel.vehicleId,
                        // location: 'Event location',
                        startDate: DateTime.parse(offersReceivedModel.startDate)
                            .toLocal(),
                        endDate: DateTime.parse(offersReceivedModel.endDate)
                            .toLocal(),
                      );
                      Add2Calendar.addEvent2Cal(event);
                    }, 'Add To Calendar', null),
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                builder: (s) {
                                  return Container(
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'Are you sure? You won\'t be able to revert this action.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Avenir',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.close(1);
                                              Get.dialog(LoadingDialog(),
                                                  barrierDismissible: false);

                                              await FirebaseFirestore.instance
                                                  .collection('offersReceived')
                                                  .doc(offersReceivedModel.id)
                                                  .update({
                                                'status': 'Cancelled',
                                                'cancelBy': 'provider',
                                              });
                                              await userController
                                                  .getRequestsHistoryProvider();
                                              Get.close(1);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              elevation: 1.0,
                                              maximumSize:
                                                  Size(Get.width * 0.6, 50),
                                              minimumSize:
                                                  Size(Get.width * 0.6, 50),
                                            ),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'Avenir',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
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
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          });
                    }, 'Cancel', Colors.red),
                  ],
                ),
              if (offersReceivedModel.status == 'Completed' &&
                  offersReceivedModel.ratingOne == 0.0)
                _getButton(Colors.white, () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: BoxConstraints(
                        maxHeight: Get.height * 0.8,
                        minHeight: Get.height * 0.8,
                        minWidth: Get.width,
                      ),
                      isScrollControlled: true,
                      builder: (contex) {
                        return RatingSheet(
                            offersReceivedModel: offersReceivedModel,
                            offersModel: offersModel,
                            isDark: userController.isDark);
                      });
                }, 'Give Rating', primaryColor),
              if (offersReceivedModel.status == 'Completed' &&
                  offersReceivedModel.ratingOne != 0.0)
                RatingBarIndicator(
                  rating: offersReceivedModel.ratingOne,
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
        ),
      ),
    );
  }

  ElevatedButton _getButton(
      Color textColor, Function? onTap, String text, Color? backColor) {
    return ElevatedButton(
      onPressed: onTap == null ? null : () => onTap(),
      style: ElevatedButton.styleFrom(
          backgroundColor: backColor ??
              (userController.isDark ? Colors.white : primaryColor),
          elevation: 0.0,
          fixedSize: Size(Get.width * 0.8, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          )),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
