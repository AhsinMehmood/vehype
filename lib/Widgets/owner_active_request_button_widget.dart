import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Pages/owner_active_request_details.dart';
import 'package:vehype/Pages/owner_see_offers_new.dart';
import 'package:vehype/Widgets/delete_request_confirmation_widget.dart';
import 'package:vehype/const.dart';

import '../Controllers/offers_controller.dart';
import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import '../Pages/choose_account_type.dart';

class OwnerActiveRequestButtonWidget extends StatelessWidget {
  final OffersModel offersModel;
  final String? chatId;
  final GarageModel garageModel;

  const OwnerActiveRequestButtonWidget(
      {super.key,
      required this.offersModel,
      this.chatId,
      required this.garageModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return StreamBuilder<List<OffersReceivedModel>>(
        stream: FirebaseFirestore.instance
            .collection('offersReceived')
            .where('offerId', isEqualTo: offersModel.offerId)
            .where('status', isNotEqualTo: 'ignore')
            .snapshots()
            .map((QuerySnapshot<Map<String, dynamic>> convert) => convert.docs
                .map((DocumentSnapshot<Map<String, dynamic>> doc) =>
                    OffersReceivedModel.fromJson(doc))
                .toList()),
        builder: (context, AsyncSnapshot<List<OffersReceivedModel>> snapshot) {
          List<OffersReceivedModel> offersReceived = snapshot.data ?? [];
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
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (offersReceived.isEmpty)
                  InkWell(
                    onTap: () {
                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: userController.userModel!.userId,
                          isAdd: false,
                          offersReceived: null,
                          checkByList: offersModel.checkByList,
                          senderId: userController.userModel!.userId,
                          notificationTitle: '',
                          notificationSubtitle: '');
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          context: context,
                          backgroundColor: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          builder: (context) {
                            return DeleteRequestConfirmationWidget(
                                userController: userController,
                                offersModel: offersModel);
                          });
                    },
                    child: Container(
                      height: 50,
                      width: Get.width * 0.42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.red,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  InkWell(
                    onTap: () {
                      OffersController().updateNotificationForOffers(
                          offerId: offersModel.offerId,
                          userId: userController.userModel!.userId,
                          isAdd: false,
                          offersReceived: null,
                          checkByList: offersModel.checkByList,
                          senderId: userController.userModel!.userId,

                          notificationTitle: '',
                          notificationSubtitle: '');

                      Get.to(() => OwnerSeeOffersNew(
                          offersReceived: offersReceived,
                          garageModel: garageModel,
                          offersModel: offersModel));
                    },
                    child: Container(
                      height: 50,
                      width: Get.width * 0.42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'See Offers (${offersReceived.length})',
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
                InkWell(
                  onTap: () async {
                    OffersController().updateNotificationForOffers(
                        offerId: offersModel.offerId,
                        userId: userController.userModel!.userId,
                        isAdd: false,
                          senderId: userController.userModel!.userId,

                        checkByList: offersModel.checkByList,
                        offersReceived: null,
                        notificationTitle: '',
                        notificationSubtitle: '');
                    Get.to(() =>
                        OwnerActiveRequestDetails(offersModel: offersModel));
                  },
                  child: Container(
                    height: 50,
                    width: Get.width * 0.42,
                    decoration: BoxDecoration(
                      // color:
                      //     userController.isDark ? Colors.white : primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'See Details',
                        style: TextStyle(
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
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
        });
  }
}
