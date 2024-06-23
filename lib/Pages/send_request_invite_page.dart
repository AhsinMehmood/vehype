import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/request_vehicle_details.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/garage_controller.dart';
import '../Controllers/offers_controller.dart';
import '../Models/chat_model.dart';
import '../Widgets/loading_dialog.dart';
import 'message_page.dart';
import 'repair_page.dart';
import 'select_service_crv.dart';

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
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<OffersModel>>(
            stream: GarageController().getRepairOffersPosted(userModel.userId),
            builder: (context, AsyncSnapshot<List<OffersModel>> snap) {
              if (!snap.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: userController.isDark ? Colors.white : primaryColor,
                  ),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Text(snap.error.toString()),
                );
              }
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
                  padding: const EdgeInsets.only(
                    bottom: 60,
                  ),
                  itemBuilder: (context, index) {
                    OffersModel offersModel = offersPosted[index];
                    List<String> vehicleInfo = offersModel.vehicleId.split(',');
                    final String vehicleType = vehicleInfo[0];
                    final String vehicleMake = vehicleInfo[1];
                    final String vehicleYear = vehicleInfo[2];
                    final String vehicleModle = vehicleInfo[3];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          VehicleDetailsRequest(
                              userController: userController,
                              vehicleType: vehicleType,
                              vehicleMake: vehicleMake,
                              vehicleYear: vehicleYear,
                              vehicleModle: vehicleModle,
                              offersModel: offersModel),
                          ElevatedButton(
                            onPressed: () async {
                              Get.dialog(LoadingDialog(),
                                  barrierDismissible: false);
                              ChatModel? chatModel = await ChatController()
                                  .getChat(userModel.userId,
                                      profileModel.userId, offersModel.offerId);
                              if (chatModel == null) {
                                await ChatController().createChat(
                                    userModel,
                                    profileModel,
                                    '',
                                    offersModel,
                                    'New Message',
                                    '${userModel.name} sent an inquiry for ${offersModel.vehicleId}',
                                    'Message');
                                ChatModel? newchat = await ChatController()
                                    .getChat(
                                        userModel.userId,
                                        profileModel.userId,
                                        offersModel.offerId);
                                Get.close(2);
                                Get.to(() => MessagePage(
                                      chatModel: newchat!,
                                      secondUser: profileModel,
                                    ));
                              } else {
                                Get.close(2);

                                Get.to(() => MessagePage(
                                      chatModel: chatModel,
                                      secondUser: profileModel,
                                    ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(Get.width * 0.8, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            child: Text(
                              'Select',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            height: 1,
                            width: Get.width,
                            color: changeColor(color: 'D9D9D9'),
                          ),
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
