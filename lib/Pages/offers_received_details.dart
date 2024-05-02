// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/chat_model.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/Widgets/select_date_and_price.dart';
import 'package:vehype/const.dart';

import '../Controllers/chat_controller.dart';
import '../Controllers/garage_controller.dart';
import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import 'comments_page.dart';
import 'full_image_view_page.dart';
import 'message_page.dart';

class OfferReceivedDetails extends StatelessWidget {
  final OffersModel offersModel;
  final bool isChat;
  const OfferReceivedDetails(
      {super.key, required this.offersModel, this.isChat = false});

  @override
  Widget build(BuildContext context) {
    final PageController imagePageController = PageController();
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: isChat
          ? null
          : AppBar(
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              elevation: 0.0,
              leading: IconButton(
                  onPressed: () {
                    // garageController.disposeController();

                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: userController.isDark ? Colors.white : primaryColor,
                  )),
              title: Text(
                offersModel.vehicleId,
                style: TextStyle(
                  color: userController.isDark ? Colors.white : primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: StreamBuilder<UserModel>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(offersModel.ownerId)
                .snapshots()
                .map((event) => UserModel.fromJson(event)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  children: [
                    SizedBox(
                      height: Get.height * 0.4,
                    ),
                    Center(
                      child: CircularProgressIndicator(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                  ],
                );
              }
              final UserModel ownerDetails = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    if (offersModel.imageOne != '')
                      SizedBox(
                        width: Get.width * 0.9,
                        height: Get.width * 0.35,
                        child: Stack(
                          children: [
                            PageView(
                              controller: imagePageController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => FullImagePageView(
                                          url: offersModel.imageOne,
                                        ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: ExtendedImage.network(
                                      offersModel.imageOne,
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: ExtendedImage.network(
                            ownerDetails.profileUrl,
                            width: 75,
                            height: 75,
                            fit: BoxFit.fill,
                            cache: true,
                            // border: Border.all(color: Colors.red, width: 1.0),
                            shape: BoxShape.circle,
                            borderRadius:
                                BorderRadius.all(Radius.circular(200.0)),
                            //cancelToken: cancellationToken,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ownerDetails.name,
                              style: TextStyle(
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => CommentsPage(data: ownerDetails));
                              },
                              child: Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: ownerDetails.rating,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 25.0,
                                    direction: Axis.horizontal,
                                  ),
                                  Text(
                                    ownerDetails.ratings.length.toString(),
                                    style: TextStyle(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Info',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            offersModel.vehicleId,
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
                            'Issue',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                  getServices()
                                      .firstWhere((element) =>
                                          element.name == offersModel.issue)
                                      .image,
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  height: 35,
                                  width: 35),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                offersModel.issue,
                                style: TextStyle(
                                  fontFamily: 'Avenir',
                                  fontWeight: FontWeight.w400,
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Details',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              // color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            offersModel.description == ''
                                ? 'Details will be provided on Chat.'
                                : offersModel.description,
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 1,
                        width: Get.width,
                        color: changeColor(color: 'D9D9D9'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {},
                      child: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Service',
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              offersModel.additionalService == ''
                                  ? 'No Additional Service'
                                  : offersModel.additionalService,
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w400,
                                // color: changeColor(color: '7B7B7B'),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 1,
                                width: Get.width,
                                color: changeColor(color: 'D9D9D9'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      child: SizedBox(
                        width: Get.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: Get.width,
                              child: GoogleMap(
                                markers: {
                                  Marker(
                                    markerId: MarkerId('current'),
                                    position: LatLng(
                                        offersModel.lat, offersModel.long),
                                  ),
                                },
                                initialCameraPosition: CameraPosition(
                                  target:
                                      LatLng(offersModel.lat, offersModel.long),
                                  zoom: 16.0,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 1,
                                width: Get.width,
                                color: changeColor(color: 'D9D9D9'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    if (isChat == false)
                      ElevatedButton(
                        onPressed: () async {
                          Get.dialog(LoadingDialog(),
                              barrierDismissible: false);
                          ChatModel? chatModel = await ChatController().getChat(
                              userModel.userId,
                              ownerDetails.userId,
                              offersModel.offerId);
                          if (chatModel == null) {
                            await ChatController().createChat(
                                userModel,
                                ownerDetails,
                                '',
                                offersModel,
                                'New Message',
                                '${userModel.name} started a chat for ${offersModel.vehicleId}',
                                'chat');
                            ChatModel? newchat = await ChatController().getChat(
                              userModel.userId,
                              ownerDetails.userId,
                              offersModel.offerId,
                            );
                            // ChatController(). updateOfferId(newchat!, userModel.userId);

                            Get.close(1);
                            Get.to(() => MessagePage(
                                  chatModel: newchat!,
                                  secondUser: ownerDetails,
                                ));
                          } else {
                            Get.close(1);

                            Get.to(() => MessagePage(
                                  chatModel: chatModel,
                                  secondUser: ownerDetails,
                                ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            elevation: 0.0,
                            fixedSize: Size(Get.width * 0.8, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            )),
                        child: Text(
                          'Chat',
                          style: TextStyle(
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // applyToJob(userModel);
                            Get.bottomSheet(
                                SelectDateAndPrice(
                                  offersModel: offersModel,
                                  ownerModel: ownerDetails,
                                  offersReceivedModel: null,
                                ),
                                isScrollControlled: true);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0.0,
                              fixedSize: Size(Get.width * 0.8, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              )),
                          child: Text(
                            'Send Offer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  applyToJob(UserModel userModel) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersModel.offerId)
        .update({
      'offersReceived': FieldValue.arrayUnion([userModel.userId]),
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(offersModel.offerId)
        .collection('offersReceived')
        .add({
      'offerBy': userModel.userId,
      'offerAt': DateTime.now().toUtc().toIso8601String(),
      'status': 'pending',
    });
    Get.close(2);
    Get.showSnackbar(
      GetSnackBar(
        message: 'Submitted successfully.',
        duration: Duration(seconds: 3),
      ),
    );
  }
}
