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
import 'package:vehype/Pages/repair_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import 'full_image_view_page.dart';
import 'inactive_offers_seeker.dart';
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
            'Requests',
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
                child: Row(
                  children: [
                    Text('New'),
                    if (userModel.isActiveNew)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveNew)
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Text('Pending'),
                    if (userModel.isActivePending)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActivePending)
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Text('In Progress'),
                    if (userModel.isActiveInProgress)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveInProgress)
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Text('Completed'),
                    if (userModel.isActiveCompleted)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveCompleted)
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Text('Cancelled'),
                    if (userModel.isActiveCancelled)
                      const SizedBox(
                        width: 5,
                      ),
                    if (userModel.isActiveCancelled)
                      Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                          color: Colors.red,
                        ),
                      )
                  ],
                ),
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
                      emptyText: 'No Pending Offers Yet!',
                      id: 1,
                      offersPending: offersPending),
                  Offers(
                      userController: userController,
                      emptyText: 'No Accepted Offers Yet!',
                      id: 2,
                      offersPending: upcomingOffers),
                  Offers(
                      userController: userController,
                      id: 3,
                      emptyText: 'No Completed Offers Yet!',
                      offersPending: offersCompleted),
                  Offers(
                      userController: userController,
                      id: 4,
                      emptyText: 'No Cancelled Offers Yet!',
                      offersPending: offersCencelled),
                ],
              );
            }),
      ),
    );
  }
}

class Offers extends StatefulWidget {
  final int id;
  const Offers({
    super.key,
    required this.userController,
    required this.offersPending,
    required this.emptyText,
    required this.id,
  });

  final String emptyText;

  final UserController userController;
  final List<OffersReceivedModel> offersPending;

  @override
  State<Offers> createState() => _OffersState();
}

class _OffersState extends State<Offers> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = widget.userController.userModel!;

    return widget.offersPending.isEmpty
        ? Center(
            child: Text(
              widget.emptyText,
              style: TextStyle(
                color:
                    widget.userController.isDark ? Colors.white : primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.builder(
            itemCount: widget.offersPending.length,
            shrinkWrap: true,
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 0),
            itemBuilder: (context, index) {
              OffersReceivedModel offersReceivedModel =
                  widget.offersPending[index];
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
                      return SizedBox.shrink();
                    }
                    if (offerSnap.hasError) {
                      return Text(offerSnap.stackTrace.toString());
                    }
                    OffersModel offersModel =
                        OffersModel.fromJson(offerSnap.data);
                    Future.delayed(const Duration(seconds: 4)).then((e) {
                      if (widget.id == 1) {
                        // if (userModel.isActivePending) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                      }
                      // }
                      if (widget.id == 2) {
                        // if (userModel.isActiveInProgress) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                        // }
                      }
                      if (widget.id == 3) {
                        // if (userModel.isActiveCompleted) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                        // }
                      }
                      if (widget.id == 4) {
                        // if (userModel.isActiveCancelled) {
                        UserController().changeNotiOffers(
                            widget.id,
                            false,
                            widget.userController.userModel!.userId,
                            offersModel.offerId,
                            userModel.accountType);
                        // }
                      }
                    });

                    return Stack(
                      children: [
                        OffersHistoryWidget(
                            userController: widget.userController,
                            offersModel: offersModel,
                            id: widget.id,
                            offersReceivedModel: offersReceivedModel),
                        if (widget.userController.userModel!.offerIdsToCheck
                            .contains(offersModel.offerId))
                          Positioned(
                              right: 5,
                              top: -1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Icon(
                                  Icons.notifications_on_sharp,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ))
                      ],
                    );
                  });
            });
  }
}

class OffersHistoryWidget extends StatelessWidget {
  const OffersHistoryWidget({
    super.key,
    required this.userController,
    required this.offersModel,
    required this.offersReceivedModel,
    required this.id,
  });

  final UserController userController;

  final OffersModel offersModel;
  final int id;
  final OffersReceivedModel offersReceivedModel;

  @override
  Widget build(BuildContext context) {
    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0].trim();
    final String vehicleMake = vehicleInfo[1].trim();
    final String vehicleYear = vehicleInfo[2].trim();
    final String vehicleModle = vehicleInfo[3].trim();
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
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

                                              sendNotification(
                                                  offersReceivedModel.ownerId,
                                                  userModel.name,
                                                  'Offer Update',
                                                  '${userModel.name} Cancelled the Request.',
                                                  'chatId',
                                                  'offer',
                                                  'messageId');
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
                                              sendNotification(
                                                  offersModel.ownerId,
                                                  userController
                                                      .userModel!.name,
                                                  'Cancelled The Request',
                                                  'contents',
                                                  '',
                                                  'offer',
                                                  '');
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
                  offersReceivedModel.ratingTwo == 0.0)
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
                        return RatingSheet(
                            offersReceivedModel: offersReceivedModel,
                            offersModel: offersModel,
                            isDark: userController.isDark);
                      });
                }, 'Give Rating', primaryColor),
              if (offersReceivedModel.status == 'Completed' &&
                  offersReceivedModel.ratingTwo != 0.0)
                RatingBarIndicator(
                  rating: offersReceivedModel.ratingTwo,
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
            borderRadius: BorderRadius.circular(20),
          )),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
