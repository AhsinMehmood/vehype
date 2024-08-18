import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Pages/service_request_details.dart';

import '../Models/offers_model.dart';

import '../Pages/inactive_offers_seeker.dart';
import '../const.dart';
import 'service_to_owner_rating_sheet.dart';

class ServiceCancelledRequestButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;

  const ServiceCancelledRequestButtonWidget(
      {super.key,
      required this.offersModel,
      this.chatId,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      height: 80,
      width: Get.width,
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        border: Border(
            top: BorderSide(
          color: userController.isDark
              ? Colors.white.withOpacity(0.2)
              : primaryColor.withOpacity(0.2),
        )),
      ),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (offersReceivedModel.ratingTwo == 0.0 &&
              offersReceivedModel.cancelBy != 'provider')
            InkWell(
              onTap: () {
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
                    showDragHandle: true,
                    builder: (contex) {
                      return ServiceToOwnerRatingSheet(
                          offersReceivedModel: offersReceivedModel,
                          offersModel: offersModel,
                          isDark: userController.isDark);
                    });
              },
              child: Container(
                height: 50,
                width: Get.width * 0.42,
                decoration: BoxDecoration(
                  // color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rate this Request',
                      style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        // color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () async {
              Get.to(() => ServiceRequestDetails(
                  offersModel: offersModel,
                  offersReceivedModel: offersReceivedModel));
            },
            child: Container(
              height: 50,
              width: offersReceivedModel.ratingTwo == 0.0 &&
                      offersReceivedModel.cancelBy != 'provider'
                  ? Get.width * 0.42
                  : Get.width * 0.8,
              decoration: BoxDecoration(
                color: userController.isDark ? Colors.white : primaryColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              ),
              child: Center(
                child: Text(
                  'See Details',
                  style: TextStyle(
                    color: userController.isDark ? primaryColor : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
