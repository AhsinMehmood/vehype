import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:vehype/Controllers/user_controller.dart';

import '../Models/offers_model.dart';

import '../const.dart';
import 'service_to_owner_rating_sheet.dart';

class ServiceRequestCancelledDetailsButton extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final OffersReceivedModel offersReceivedModel;

  const ServiceRequestCancelledDetailsButton(
      {super.key,
      required this.offersModel,
      this.chatId,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return offersReceivedModel.cancelBy == 'provider' &&
            offersReceivedModel.ratingTwo == 0.0
        ? SizedBox(
            height: 80,
            width: Get.width,
          )
        : Container(
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
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
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
                          // constraints: BoxConstraints(
                          //   maxHeight: Get.height * 0.95,
                          //   minHeight: Get.height * 0.95,
                          //   minWidth: Get.width,
                          // ),
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
                      width: Get.width * 0.9,
                      decoration: BoxDecoration(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Submit Feedback',
                            style: TextStyle(
                              color: userController.isDark
                                  ? primaryColor
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}

// 