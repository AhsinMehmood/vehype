import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/Widgets/service_cancelled_request_button_widget.dart';
import 'package:vehype/Widgets/service_completed_request_button_widget.dart';
import 'package:vehype/Widgets/service_inprogress_request_button_widget.dart';
import 'package:vehype/Widgets/service_new_request_button_widget.dart';
import 'package:vehype/Widgets/service_pending_request_button_widget.dart';
import 'package:vehype/const.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'undo_ignore_provider.dart';

class ServiceRequestWidget extends StatelessWidget {
  final OffersModel offersModel;
  final OffersReceivedModel? offersReceivedModel;
  const ServiceRequestWidget(
      {super.key, required this.offersModel, this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    DateTime createdAt = DateTime.parse(offersModel.createdAt);
    return StreamBuilder<GarageModel>(
        stream: FirebaseFirestore.instance
            .collection('garages')
            .doc(offersModel.garageId)
            .snapshots()
            .map((cc) => GarageModel.fromJson(cc)),
        builder: (context, snapshot) {
          GarageModel garageModel = snapshot.data ??
              GarageModel(
                  ownerId: 'ownerId',
                  submodel: '',
                  title: offersModel.vehicleId,
                  imageUrl: offersModel.imageOne,
                  bodyStyle: 'Passenger vehicle',
                  make: '',
                  year: '',
                  model: '',
                  vin: '',
                  garageId: offersModel.garageId);
          return Stack(
            children: [
              if (offersModel.checkByList.any(
                  (test) => test.checkById == userController.userModel!.userId))
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: Get.width * 0.97,
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6)),
                    ),
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Text(
                      offersModel.checkByList
                          .firstWhere((check) =>
                              check.checkById ==
                              userController.userModel!.userId)
                          .title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: userController.isDark ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: userController.isDark
                        ? Colors.white.withOpacity(0.2)
                        : primaryColor.withOpacity(0.2),
                  ),
                ),
                margin: EdgeInsets.only(
                    left: 5,
                    right: 5,
                    bottom: 15,
                    top: offersModel.checkByList.any((test) =>
                            test.checkById == userController.userModel!.userId)
                        ? 22
                        : 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 230,
                      width: Get.width,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: garageModel.imageUrl,
                              fit: BoxFit.cover,
                              height: 230,
                              width: Get.width,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 5,
                                top: 5,
                              ),
                              margin: const EdgeInsets.only(
                                left: 10,
                                top: 10,
                              ),
                              child: Text(
                                timeago.format(createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              garageModel.title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  getVehicleType()
                                      .firstWhere((test) =>
                                          test.title ==
                                          garageModel.bodyStyle
                                              .split(',')
                                              .first
                                              .trim())
                                      .icon,
                                  height: 20,
                                  width: 20,
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  garageModel.bodyStyle,
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
                            Column(
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      getServices()
                                          .firstWhere((test) =>
                                              test.name == offersModel.issue)
                                          .image,
                                      height: 35,
                                      width: 35,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      offersModel.issue,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 0,
                            ),
                            if (offersReceivedModel != null)
                              const SizedBox(
                                height: 15,
                              ),
                            if (offersReceivedModel != null)
                              Container(
                                height: 0.5,
                                width: Get.width,
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : primaryColor.withOpacity(0.2),
                              ),
                            if (offersReceivedModel != null)
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Price:  ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        '\$${offersReceivedModel!.price}',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Start at: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        formatDateTime(
                                          DateTime.parse(
                                            offersReceivedModel!.startDate,
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // const SizedBox(
                                  //   height: 15,
                                  // ),
                                  // Container(
                                  //   height: 0.5,
                                  //   width: Get.width,
                                  //   color: userController.isDark
                                  //       ? Colors.white.withOpacity(0.2)
                                  //       : primaryColor.withOpacity(0.2),
                                  // ),
                                ],
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (offersModel.ignoredBy
                        .contains(userController.userModel!.userId))
                      UndoIgnoreProvider(
                          offersModel: offersModel,
                          userController: userController)
                    else if (offersReceivedModel == null)
                      ServiceNewRequestButtonWidget(
                        offersModel: offersModel,
                        garageModel: garageModel,
                      )
                    else
                      Column(
                        children: [
                          if (offersReceivedModel!.status == 'Pending')
                            ServicePendingRequestButtonWidget(
                                offersModel: offersModel,
                                garageModel: garageModel,
                                offersReceivedModel: offersReceivedModel!)
                          else if (offersReceivedModel!.status == 'Upcoming')
                            ServiceInprogressRequestButtonWidget(
                                offersModel: offersModel,
                                garageModel: garageModel,
                                offersReceivedModel: offersReceivedModel!)
                          else if (offersReceivedModel!.status == 'Completed')
                            ServiceCompletedRequestButtonWidget(
                                offersModel: offersModel,
                                offersReceivedModel: offersReceivedModel!)
                          else if (offersReceivedModel!.status == 'Cancelled')
                            ServiceCancelledRequestButtonWidget(
                                offersModel: offersModel,
                                offersReceivedModel: offersReceivedModel!)
                        ],
                      )
                  ],
                ),
              ),
              if (offersModel.checkByList.any(
                  (test) => test.checkById == userController.userModel!.userId))
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: const EdgeInsets.only(right: 10, top: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.notifications_on_outlined,
                        size: 20,
                        color: Colors.white,
                      )),
                )
            ],
          );
        });
  }
}
