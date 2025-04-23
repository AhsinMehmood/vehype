// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Pages/service_repair_info_fill.dart';

import 'package:vehype/Widgets/owner_active_offers.dart';
import 'package:vehype/Widgets/owner_inactive_offers_page_widget.dart';
import 'package:vehype/Widgets/owner_inprogress_page_widget.dart';
import 'package:vehype/const.dart';
import 'package:vehype/providers/assistance_guide_ai_service.dart';
import 'package:vehype/providers/copy_vehicle_data.dart';

import '../Controllers/mix_panel_controller.dart';
import 'Personal Assistance /assistance_guide_ui.dart';
import 'Personal Assistance /assitance_chat_ui.dart';
// import 'choose_account_type.dart';

import 'owner_notifications_page.dart';
import 'service_set_opening_hours.dart';

final mixPanelController = Get.find<MixPanelController>();

class RepairPage extends StatelessWidget {
  const RepairPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);
    UserModel userModel = userController.userModel!;

    final List<OffersModel> ownerOffersNeedsToCheck = offersProvider.ownerOffers
        .where((offer) => offer.checkByList
            .any((check) => check.checkById == userModel.userId))
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        floatingActionButton: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: userController.isDark ? Colors.white : primaryColor,
          ),
          child: InkWell(
            onTap: () async {
              // bool dd = await OneSignal.Notifications.requestPermission(true);
              // OneSignal.login(userModel.userId);
              // await sendNotification(userModel.userId, userModel.name);
              // print(dd);
              mixPanelController.trackEvent(
                  eventName: 'Opened Create New Request Page', data: {});
              Get.to(() => CreateRequestPage(
                    offersModel: null,
                  ));
            },
            child: Center(
              child: Icon(
                Icons.add,
                color: userController.isDark ? primaryColor : Colors.white,
              ),
            ),
          ),
        ),
        appBar: AppBar(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Requests',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    // NotificationController().sendNotification(
                    //     offerId: 'offers',
                    //     requestId: 'requestId',
                    //     title: 'title',
                    //     subtitle: 'subtitle',
                    //     userTokens: [userModel.pushToken]);
                    // log(userModel.pushToken);
                    mixPanelController.trackEvent(
                        eventName: 'Opened Owner Notifications Page', data: {});
                    Get.to(() => OwnerNotificationsPage(
                          offers: ownerOffersNeedsToCheck,
                        ));
                  },
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        size: 28,
                      ),
                      if (ownerOffersNeedsToCheck.isNotEmpty)
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            color: Colors.red,
                          ),
                          // padding: const EdgeInsets.all(1),
                          child: Center(
                            child: Text(
                              ownerOffersNeedsToCheck.length.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ))
          ],
          bottom: TabBar(
            // isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Active'),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'active'))
                      const SizedBox(
                        width: 5,
                      ),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'active'))
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('In Progress'),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inProgress'))
                      const SizedBox(
                        width: 3,
                      ),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inProgress'))
                      Container(
                        height: 10,
                        width: 10,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('History'),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inactive'))
                      const SizedBox(
                        width: 3,
                      ),
                    if (ownerOffersNeedsToCheck
                        .any((offer) => offer.status == 'inactive'))
                      Container(
                        height: 10,
                        width: 10,
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
        body: TabBarView(
          children: [
            OwnerActiveOffers(),
            OwnerInprogressPageWidget(),
            OwnerInactiveOffersPageWidget(),
          ],
        ),
      ),
    );
  }
}
