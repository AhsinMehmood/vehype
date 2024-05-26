import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/garage_controller.dart';
import '../Controllers/user_controller.dart';
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
              fontSize: 20,
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
                  return ActiveOffers(
                      offersPosted: offersPosted,
                      userController: userController);
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
                  return InActiveOffers(
                      title: 'Check Progress',
                      offersPosted: offersPosted,
                      userController: userController);
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
                  return InActiveOffers(
                      title: 'Rated',
                      offersPosted: offersPosted,
                      userController: userController);
                }),
          ),
        ]),
      ),
    );
  }
}
