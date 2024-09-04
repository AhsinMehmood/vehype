import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/offers_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import '../Pages/owner_request_details_inprogress_inactive_page.dart';

class OwnerInprogressButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final GarageModel garageModel;
  final OffersReceivedModel? offersReceivedModel;

  const OwnerInprogressButtonWidget(
      {super.key,
      required this.offersModel,
      required this.garageModel,
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
          InkWell(
            onTap: () async {
              // print(userController.userModel!.userId);
              // await FirebaseFirestore.instance
              //     .collection('offers')
              //     .doc(offersModel.offerId)
              //     .update({
              //   'offerReceivedIdJob': '1r029bckpmAmQViHHRS7',
              //   'status': 'inactive',
              // });

              OffersController().updateNotificationForOffers(
                  offerId: offersModel.offerId,
                  userId: userController.userModel!.userId,
                  isAdd: false,
                  offersReceived: offersReceivedModel!.id,
                  checkByList: offersModel.checkByList,
                  senderId: userController.userModel!.userId,
                  notificationTitle: '',
                  notificationSubtitle: '');
              Get.to(() => OwnerRequestDetailsInprogressInactivePage(
                  offersModel: offersModel,
                  garageModel: garageModel,
                  offersReceivedModel: offersReceivedModel!));
            },
            child: Container(
              height: 50,
              width: Get.width * 0.88,
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
