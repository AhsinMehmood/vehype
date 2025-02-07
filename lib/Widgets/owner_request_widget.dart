import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';

import 'package:vehype/const.dart';

import 'owner_active_request_button_widget.dart';
import 'owner_inprogress_button_widget.dart';
import 'service_request_widget.dart';

class OwnerRequestWidget extends StatelessWidget {
  final OffersModel offersModel;
  final GarageModel garageModel;
  final OffersReceivedModel? offersReceivedModel;
  const OwnerRequestWidget(
      {super.key,
      required this.offersModel,
      this.offersReceivedModel,
      required this.garageModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    DateTime createdAt = DateTime.parse(offersModel.createdAt);

    return Stack(
      children: [
        if (offersModel.checkByList
            .any((noti) => noti.checkById == userController.userModel!.userId))
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
                    topLeft: Radius.circular(6), topRight: Radius.circular(6)),
              ),
              padding: const EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                offersModel.checkByList
                    .firstWhere((check) =>
                        check.checkById == userController.userModel!.userId)
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
              top: offersModel.checkByList.any((noti) =>
                      noti.checkById == userController.userModel!.userId)
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
                        placeholder: (context, url) => Center(
                            child: SizedBox(
                                height: 230,
                                width: 230,
                                child: Center(
                                    child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator())))),
                        errorWidget: (context, url, error) =>
                            Image.asset("assets/icon.png"),
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
                          formatDateForRequestWidget(createdAt.toLocal()),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor),
                        ),
                      ),
                    ),
                    if (offersModel.status == 'inactive' &&
                        offersReceivedModel != null)
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: offersModel.offersReceived.isEmpty
                                ? Colors.red
                                : primaryColor,
                          ),
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 5,
                            top: 5,
                          ),
                          margin: const EdgeInsets.only(
                            right: 10,
                            top: 10,
                          ),
                          child: Text(
                            offersReceivedModel!.status,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: offersModel.offersReceived.isEmpty
                                    ? Colors.white
                                    : Colors.greenAccent),
                          ),
                        ),
                      )
                    else if (offersModel.offersReceived.isEmpty &&
                        offersModel.status == 'inactive')
                      Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.red,
                          ),
                          padding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 5,
                            top: 5,
                          ),
                          margin: const EdgeInsets.only(
                            right: 10,
                            top: 10,
                          ),
                          child: Text(
                            'Deleted',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: offersModel.offersReceived.isEmpty
                                    ? Colors.white
                                    : Colors.greenAccent),
                          ),
                        ),
                      )
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
                          // SvgPicture.asset(
                          //   getVehicleType()
                          //       .firstWhere((test) =>
                          //           test.title ==
                          //           garageModel.bodyStyle
                          //               .split(',')
                          //               .first
                          //               .trim())
                          //       .icon,
                          //   height: 20,
                          //   width: 20,
                          //   color: userController.isDark
                          //       ? Colors.white
                          //       : primaryColor,
                          // ),
                          // const SizedBox(
                          //   width: 8,
                          // ),
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
                            // Row(
                            //   children: [
                            //     Text(
                            //       'Start at: ',
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w400,
                            //       ),
                            //     ),
                            //     Text(
                            //       formatDateTime(
                            //         DateTime.parse(
                            //           offersReceivedModel!.startDate,
                            //         ).toLocal(),
                            //       ),
                            //       style: TextStyle(
                            //         fontSize: 16,
                            //         fontWeight: FontWeight.w700,
                            //       ),
                            //     ),
                            //   ],
                            // ),

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
              if (offersModel.status == 'active')
                OwnerActiveRequestButtonWidget(
                  offersModel: offersModel,
                  garageModel: garageModel,
                )
              else if (offersModel.status == 'inProgress')
                OwnerInprogressButtonWidget(
                  offersModel: offersModel,
                  offersReceivedModel: offersReceivedModel,
                  garageModel: garageModel,
                )
              else if (offersModel.status == 'inactive')
                if (offersModel.offersReceived.isNotEmpty)
                  OwnerInprogressButtonWidget(
                    offersModel: offersModel,
                    garageModel: garageModel,
                    offersReceivedModel: offersReceivedModel,
                  )
                else
                  Container(
                    height: 30,
                    width: Get.width,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        )),
                    child: InkWell(
                      onTap: () {
                        Get.to(
                            () => CreateRequestPage(offersModel: offersModel));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Edit & Repost >',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: userController.isDark
                                    ? primaryColor
                                    : Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (offersModel.checkByList
            .any((noti) => noti.checkById == userController.userModel!.userId))
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
  }
}
