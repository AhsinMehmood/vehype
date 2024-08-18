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
          return Container(
            decoration: BoxDecoration(
              color: userController.isDark ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: userController.isDark
                    ? Colors.white.withOpacity(0.2)
                    : primaryColor.withOpacity(0.2),
              ),
            ),
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                SizedBox(
                  height: 230,
                  width: Get.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: ExtendedImage.network(
                      garageModel.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
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
                        Row(
                          children: [
                            SvgPicture.asset(
                              getServices()
                                  .firstWhere(
                                      (test) => test.name == offersModel.issue)
                                  .image,
                              height: 35,
                              width: 35,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              offersModel.issue,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (offersModel.additionalService != '')
                              const SizedBox(
                                width: 28,
                              ),
                            if (offersModel.additionalService != '')
                              SvgPicture.asset(
                                getAdditionalService()
                                    .firstWhere((test) =>
                                        test.name ==
                                        offersModel.additionalService)
                                    .icon,
                                height: 35,
                                width: 35,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            if (offersModel.additionalService != '')
                              const SizedBox(
                                width: 10,
                              ),
                            if (offersModel.additionalService != '')
                              Text(
                                offersModel.additionalService,
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
                        Text(
                          timeago.format(createdAt),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
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
                              const SizedBox(
                                height: 10,
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
                // if (offersModel.ignoredBy
                //         .contains(userController.userModel!.userId) ==
                //     false)
                //   const SizedBox.shrink()
                // else
                if (offersReceivedModel == null)
                  ServiceNewRequestButtonWidget(offersModel: offersModel)
                else
                  Column(
                    children: [
                      if (offersReceivedModel!.status == 'Pending')
                        ServicePendingRequestButtonWidget(
                            offersModel: offersModel,
                            offersReceivedModel: offersReceivedModel!)
                      else if (offersReceivedModel!.status == 'Upcoming')
                        ServiceInprogressRequestButtonWidget(
                            offersModel: offersModel,
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
          );
        });
  }
}
