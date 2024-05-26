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

class OfferReceivedDetails extends StatefulWidget {
  final OffersModel offersModel;
  final bool isChat;
  const OfferReceivedDetails(
      {super.key, required this.offersModel, this.isChat = false});

  @override
  State<OfferReceivedDetails> createState() => _OfferReceivedDetailsState();
}

class _OfferReceivedDetailsState extends State<OfferReceivedDetails> {
  PageController pageController = PageController();
  int currentInde = 0;
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: widget.isChat
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
                widget.offersModel.vehicleId,
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
                .doc(widget.offersModel.ownerId)
                .snapshots()
                .map((event) => UserModel.fromJson(event)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
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
                    SizedBox(
                        width: Get.width,
                        height: Get.width * 0.3,
                        child: PageView(
                          controller: pageController,
                          onPageChanged: (value) {
                            setState(() {
                              currentInde = value;
                            });
                          },
                          children: [
                            if (widget.offersModel.imageOne != '')
                              InkWell(
                                onTap: () {
                                  Get.to(() => FullImagePageView(
                                        url: widget.offersModel.imageOne,
                                      ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: ExtendedImage.network(
                                    widget.offersModel.imageOne,
                                    width: Get.width,
                                    height: Get.width * 0.3,
                                    fit: BoxFit.cover,
                                    cache: true,
                                    // border: Border.all(color: Colors.red, width: 1.0),
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    //cancelToken: cancellationToken,
                                  ),
                                ),
                              ),
                            if (widget.offersModel.imageTwo != '')
                              InkWell(
                                onTap: () {
                                  Get.to(() => FullImagePageView(
                                        url: widget.offersModel.imageTwo,
                                      ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: ExtendedImage.network(
                                    widget.offersModel.imageTwo,
                                    width: Get.width,
                                    height: Get.width * 0.3,
                                    fit: BoxFit.cover,
                                    cache: true,
                                    // border: Border.all(color: Colors.red, width: 1.0),
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    //cancelToken: cancellationToken,
                                  ),
                                ),
                              ),
                          ],
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 15,
                      width: Get.width,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: currentInde == 0
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: currentInde == 1
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
                            widget.offersModel.vehicleId,
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
                                          element.name ==
                                          widget.offersModel.issue)
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
                                widget.offersModel.issue,
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
                            widget.offersModel.description == ''
                                ? 'Details will be provided on Chat.'
                                : widget.offersModel.description,
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
                              widget.offersModel.additionalService == ''
                                  ? 'No Additional Service'
                                  : widget.offersModel.additionalService,
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
                                    position: LatLng(widget.offersModel.lat,
                                        widget.offersModel.long),
                                  ),
                                },
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(widget.offersModel.lat,
                                      widget.offersModel.long),
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
                    if (widget.isChat == false)
                      ElevatedButton(
                        onPressed: () async {
                          Get.dialog(LoadingDialog(),
                              barrierDismissible: false);
                          ChatModel? chatModel = await ChatController().getChat(
                              userModel.userId,
                              ownerDetails.userId,
                              widget.offersModel.offerId);
                          if (chatModel == null) {
                            await ChatController().createChat(
                                userModel,
                                ownerDetails,
                                '',
                                widget.offersModel,
                                'New Message',
                                '${userModel.name} started a chat for ${widget.offersModel.vehicleId}',
                                'chat');
                            ChatModel? newchat = await ChatController().getChat(
                              userModel.userId,
                              ownerDetails.userId,
                              widget.offersModel.offerId,
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
                            Get.to(
                              () => SelectDateAndPrice(
                                offersModel: widget.offersModel,
                                ownerModel: ownerDetails,
                                offersReceivedModel: null,
                              ),
                            );
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
        .doc(widget.offersModel.offerId)
        .update({
      'offersReceived': FieldValue.arrayUnion([userModel.userId]),
    });
    await FirebaseFirestore.instance
        .collection('offers')
        .doc(widget.offersModel.offerId)
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
