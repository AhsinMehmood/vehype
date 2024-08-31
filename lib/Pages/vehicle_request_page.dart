import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/owner_active_offers.dart';
import 'package:vehype/const.dart';

import '../Controllers/garage_controller.dart';
import '../Controllers/user_controller.dart';
import '../Widgets/owner_request_widget.dart';
import 'choose_account_type.dart';
import 'create_request_page.dart';
import 'repair_page.dart';

class VehicleRequestsPage extends StatelessWidget {
  final GarageModel garageModel;
  const VehicleRequestsPage({super.key, required this.garageModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;

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
              if (userModel.email == 'No email set') {
                Get.showSnackbar(GetSnackBar(
                  message: 'Login to continue',
                  duration: const Duration(
                    seconds: 3,
                  ),
                  backgroundColor:
                      userController.isDark ? Colors.white : primaryColor,
                  mainButton: TextButton(
                    onPressed: () {
                      Get.to(() => ChooseAccountTypePage());
                      Get.closeCurrentSnackbar();
                    },
                    child: Text(
                      'Login Page',
                      style: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                      ),
                    ),
                  ),
                ));
              } else {
                Get.to(() => CreateRequestPage(
                      offersModel: null,
                      garageModel: garageModel,
                    ));
              }
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
          leading: IconButton(
              onPressed: () {
                Get.close(1);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            'Vehicle Requests',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          bottom: TabBar(
            // isScrollable: true,
            indicatorColor: userController.isDark ? Colors.white : primaryColor,
            labelColor: userController.isDark ? Colors.white : primaryColor,
            tabs: [
              Tab(
                text: 'Active',
              ),
              Tab(
                text: 'In Progress',
              ),
              Tab(
                text: 'History',
              ),
            ],
          ),
        ),
        body: TabBarView(children: [
          SafeArea(
            child: StreamBuilder<List<OffersModel>>(
                stream: GarageController().getRepairOffersPostedByVehicle(
                    userModel.userId, garageModel.garageId),
                builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(snap.error.toString()),
                    );
                  }
                  List<OffersModel> offersPosted = snap.data ?? [];
                  List<OffersModel> filterOffers = [];
                  if (offersPosted.isEmpty) {
                    return Center(
                      child: Text(
                        'Create a Request to Hire a Proffesional',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                      itemCount: offersPosted.length,
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, bottom: 80, top: 15),
                      itemBuilder: (context, index) {
                        return OwnerRequestWidget(
                          offersModel: offersPosted[index],
                          garageModel: garageModel,
                        );
                      });
                }),
          ),
          SafeArea(
            child: StreamBuilder<List<OffersModel>>(
                stream: GarageController()
                    .getRepairOffersPostedInProgressByVehicle(
                        garageModel.garageId),
                builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(snap.error.toString()),
                    );
                  }
                  List<OffersModel> offersPosted = snap.data ?? [];
                  List<OffersModel> filterOffers = [];
                  if (offersPosted.isEmpty) {
                    return Center(
                      child: Text(
                        'Nothing Yet!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                      itemCount: offersPosted.length,
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, bottom: 80, top: 15),
                      itemBuilder: (context, index) {
                        return StreamBuilder<OffersReceivedModel>(
                            stream: FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(offersPosted[index].offerReceivedIdJob)
                                .snapshots()
                                .map((convert) =>
                                    OffersReceivedModel.fromJson(convert)),
                            builder: (context,
                                AsyncSnapshot<OffersReceivedModel> snapshot) {
                              OffersReceivedModel? offersReceivedModel =
                                  snapshot.data;
                              return OwnerRequestWidget(
                                offersModel: offersPosted[index],
                                offersReceivedModel: offersReceivedModel,
                                garageModel: garageModel,
                              );
                            });
                      });
                }),
          ),
          SafeArea(
            child: StreamBuilder<List<OffersModel>>(
                stream: GarageController()
                    .getRepairOffersPostedInactiveByVehicle(
                        userModel.userId, garageModel.garageId),
                builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(snap.error.toString()),
                    );
                  }
                  List<OffersModel> offersPosted = snap.data ?? [];
                  List<OffersModel> filterOffers = [];
                  if (offersPosted.isEmpty) {
                    return Center(
                      child: Text(
                        'No History Yet!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                      itemCount: offersPosted.length,
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, bottom: 80, top: 15),
                      itemBuilder: (context, index) {
                        return StreamBuilder<OffersReceivedModel>(
                            stream: FirebaseFirestore.instance
                                .collection('offersReceived')
                                .doc(offersPosted[index].offerReceivedIdJob)
                                .snapshots()
                                .map((convert) =>
                                    OffersReceivedModel.fromJson(convert)),
                            builder: (context,
                                AsyncSnapshot<OffersReceivedModel> snapshot) {
                              OffersReceivedModel? offersReceivedModel =
                                  snapshot.data;
                              return OwnerRequestWidget(
                                offersModel: offersPosted[index],
                                offersReceivedModel: offersReceivedModel,
                                garageModel: garageModel,
                              );
                            });
                      });
                }),
          ),
        ]),
      ),
    );
  }
}
