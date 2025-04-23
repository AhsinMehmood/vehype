import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
// import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/garage_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/chat_model.dart';
import '../Widgets/loading_dialog.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'message_page.dart';
// import 'select_service_crv.dart';

class SendRequestInvitePage extends StatelessWidget {
  final UserModel profileModel;
  const SendRequestInvitePage({super.key, required this.profileModel});

  @override
  Widget build(BuildContext context) {
    UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: userController.isDark ? Colors.white : primaryColor,
            )),
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Select a Request',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OffersModel>>(
            stream: GarageController().getRepairOffersPosted(userModel.userId),
            builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
              List<OffersModel> offersPosted = snap.data ?? [];

              if (offersPosted.isEmpty) {
                return Center(
                  child: Text(
                    'No Request Found!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: offersPosted.length,
                  physics: ClampingScrollPhysics(),
                  // padding: const EdgeInsets.only(
                  //   bottom: 60,
                  // ),
                  itemBuilder: (context, index) {
                    OffersModel offersModel = offersPosted[index];
                    DateTime createdAt = DateTime.parse(offersModel.createdAt);
                    return StreamBuilder<GarageModel>(
                        stream: FirebaseFirestore.instance
                            .collection('garages')
                            .doc(offersModel.garageId)
                            .snapshots()
                            .map((convert) => GarageModel.fromJson(convert)),
                        builder:
                            (context, AsyncSnapshot<GarageModel> garageSnap) {
                          if (!garageSnap.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          GarageModel garageModels = garageSnap.data!;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
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
                                          imageUrl: garageModels.imageUrl,
                                          fit: BoxFit.cover,
                                          height: 230,
                                          width: Get.width,
                                        ),
                                      ),
                                      Positioned(
                                        left: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
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
                                                color: primaryColor),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          garageModels.title,
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
                                                      garageModels.bodyStyle
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
                                              garageModels.bodyStyle,
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
                                                          test.name ==
                                                          offersModel.issue)
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
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    Get.dialog(LoadingDialog(),
                                        barrierDismissible: false);
                                    ChatModel? chatModel =
                                        await ChatController().getChat(
                                            userModel.userId,
                                            profileModel.userId,
                                            offersModel.offerId);
                                    if (chatModel == null) {
                                      await ChatController().createChat(
                                          userModel,
                                          profileModel,
                                          '',
                                          offersModel,
                                          'New Message',
                                          '${userModel.name} sent an inquiry for ${offersModel.vehicleId}',
                                          'Message',
                                          garageModels);
                                      ChatModel? newchat =
                                          await ChatController().getChat(
                                              userModel.userId,
                                              profileModel.userId,
                                              offersModel.offerId);
                                      Get.close(2);
                                      Get.to(() => MessagePage(
                                            offersModel: offersModel,
                                            garageModel: garageModels,
                                            chatModel: newchat!,
                                            secondUser: profileModel,
                                          ));
                                    } else {
                                      Get.close(2);

                                      Get.to(() => MessagePage(
                                            offersModel: offersModel,
                                            garageModel: garageModels,
                                            chatModel: chatModel,
                                            secondUser: profileModel,
                                          ));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      minimumSize: Size(Get.width * 0.8, 50),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6))),
                                  child: Text(
                                    'Select and Chat',
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  });
            }),
      ),
    );
  }
}
