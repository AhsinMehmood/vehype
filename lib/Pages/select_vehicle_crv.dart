// ignore_for_file: prefer_const_constructors

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import '../Widgets/loading_dialog.dart';
import 'add_vehicle.dart';
import 'create_request_page.dart';
import 'full_image_view_page.dart';

class SelectVehicleCreateRequest extends StatefulWidget {
  final OffersModel? offersModel;
  const SelectVehicleCreateRequest({super.key, required this.offersModel});

  @override
  State<SelectVehicleCreateRequest> createState() =>
      _SelectVehicleCreateRequestState();
}

class _SelectVehicleCreateRequestState
    extends State<SelectVehicleCreateRequest> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((value) {
      final GarageController garageController =
          Provider.of<GarageController>(context, listen: false);
      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      UserModel userModel = userController.userModel!;
      garageController.getVehciles(userModel.userId);

      if (widget.offersModel != null) {
        garageController.selectedVehicle = widget.offersModel!.vehicleId;
        garageController.selectedIssue = widget.offersModel!.issue;
        garageController.imageOneUrl = widget.offersModel!.imageOne;
        // garageController.requestImages = widget.offersModel!.images;
        garageController.additionalService =
            widget.offersModel!.additionalService;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        title: Text(
          'Select Vehicle',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Get.to(() => AddVehicle(
                garageModel: null,
                addService: true,
              ));
        },
        child: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: userController.isDark ? Colors.white : primaryColor,
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: userController.isDark ? primaryColor : Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<GarageModel>>(
                stream: GarageController().myVehicles(userModel.userId),
                builder: (context, AsyncSnapshot<List<GarageModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        SizedBox(
                          height: Get.height * 0.4,
                        ),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }
                  List<GarageModel> vehicles = snapshot.data ?? [];
                  if (vehicles.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: Get.height * 0.4,
                        ),
                        Center(
                          child: Text(
                            'No Vehicle Added',
                            style: TextStyle(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                      itemCount: vehicles.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        GarageModel garageModel = vehicles[index];
                        final PageController imagePageController =
                            PageController();

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              garageController.selectVehicle(
                                  '${garageModel.bodyStyle}, ${garageModel.make}, ${garageModel.year}, ${garageModel.model}',
                                  garageModel.imageOne,
                                  garageModel.garageId);
                              Get.to(() => CreateRequestPage(
                                    offersModel: widget.offersModel,
                                  ));
                            },
                            child: Card(
                              color: userController.isDark
                                  ? Colors.blueGrey.shade700
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (garageModel.imageOne != '')
                                    SizedBox(
                                      width: Get.width * 0.9,
                                      height: Get.width * 0.35,
                                      child: InkWell(
                                        onTap: () {
                                          Get.to(() => FullImagePageView(
                                                url: garageModel.imageOne,
                                              ));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: ExtendedImage.network(
                                            garageModel.imageOne,
                                            width: Get.width * 0.9,
                                            height: Get.width * 0.35,
                                            fit: BoxFit.cover,
                                            cache: true,
                                            // border: Border.all(color: Colors.red, width: 1.0),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            //cancelToken: cancellationToken,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              garageModel.bodyStyle,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              garageModel.make,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              garageModel.year,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              garageModel.model,
                                              style: TextStyle(
                                                fontFamily: 'Avenir',
                                                fontWeight: FontWeight.w400,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
