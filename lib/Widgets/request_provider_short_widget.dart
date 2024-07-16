import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../Controllers/chat_controller.dart';
import '../Models/chat_model.dart';
import '../Pages/choose_account_type.dart';
import '../Pages/full_image_view_page.dart';
import '../Pages/inactive_offers_seeker.dart';
import '../Pages/message_page.dart';
import '../Pages/offers_received_details.dart';
import '../Pages/request_details_page.dart';
import '../Pages/requests_received_provider_details.dart';
import '../const.dart';
import 'loading_dialog.dart';
import 'offer_request_details.dart';
import 'select_date_and_price.dart';
// import 'vehicle_owner_request_dart';

class RequestsProviderShortWidgetActive extends StatelessWidget {
  final OffersModel offersModel;
  final bool isActive;
  final String title;
  final OffersReceivedModel? offersReceivedModel;

  const RequestsProviderShortWidgetActive(
      {super.key,
      required this.offersModel,
      this.isActive = false,
      this.offersReceivedModel,
      required this.title});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    List<String> vehicleInfo = offersModel.vehicleId.split(',');
    final String vehicleType = vehicleInfo[0].trim();
    final String vehicleMake = vehicleInfo[1].trim();
    final String vehicleYear = vehicleInfo[2].trim();
    final String vehicleModle = vehicleInfo[3].trim();
    final createdAt = DateTime.parse(offersModel.createdAt);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: userController.isDark ? Colors.blueGrey.shade700 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: Get.width * 0.42,
                width: Get.width,
                child: PageView.builder(
                    itemCount: offersModel.images.length + 1,
                    controller: PageController(
                        viewportFraction:
                            offersModel.images.isEmpty ? 1 : 0.95),
                    itemBuilder: (context, index) {
                      List imagess = [];
                      for (var element in offersModel.images) {
                        imagess.add(element);
                      }
                      imagess.insert(0, offersModel.imageOne);

                      if (index == 0) {
                        return InkWell(
                          onTap: () {
                            Get.to(() => FullImagePageView(
                                  urls: imagess,
                                  currentIndex: index,
                                ));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ExtendedImage.network(
                                offersModel.imageOne,
                                fit: BoxFit.cover,
                                width: Get.width,
                                height: Get.width * 0.42,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      } else {
                        int inde = index - 1;
                        return InkWell(
                          onTap: () {
                            Get.to(() => FullImagePageView(
                                  urls: imagess,
                                  currentIndex: index,
                                ));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ExtendedImage.network(
                                offersModel.images[inde],
                                fit: BoxFit.cover,
                                width: Get.width,
                                height: Get.width * 0.42,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Vehicle Make',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      vehicleMake.trim(),
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w700,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Year',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      vehicleYear.trim(),
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w700,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Model',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        vehicleModle.trim(),
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w700,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  if (offersReceivedModel == null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Time Ago',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          timeago.format(createdAt),
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w700,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Start At',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          formatDateTime(
                              DateTime.parse(offersReceivedModel!.startDate)
                                  .toLocal()),
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w700,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: SvgPicture.asset(
                                getServices()
                                    .firstWhere(
                                        (ss) => ss.name == offersModel.issue)
                                    .image,
                                height: 40,
                                // cache: true,
                                // shape: BoxShape.rectangle,
                                // borderRadius: BorderRadius.circular(8),
                                width: 40,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              offersModel.issue,
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w500,
                                // color: changeColor(color: '7B7B7B'),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  if (offersReceivedModel != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Price',
                            style: const TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w600,
                              // color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            '\$${offersReceivedModel!.price.toInt()}',
                            style: TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.bold,
                              // color: Colors.red,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (isActive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (userModel.email == 'No email set') {
                          Get.showSnackbar(GetSnackBar(
                            message: 'Login to continue',
                            duration: const Duration(
                              seconds: 3,
                            ),
                            backgroundColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            mainButton: TextButton(
                              onPressed: () {
                                Get.to(() => ChooseAccountTypePage());
                                Get.closeCurrentSnackbar();
                              },
                              child: Text(
                                'Login Page',
                                style: TextStyle(
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ));
                        } else {
                          await FirebaseFirestore.instance
                              .collection('offers')
                              .doc(offersModel.offerId)
                              .update({
                            'ignoredBy':
                                FieldValue.arrayUnion([userModel.userId]),
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: userController.isDark
                              ? Colors.white70
                              : primaryColor.withOpacity(0.3),
                          elevation: 0.0,
                          fixedSize: Size(Get.width * 0.35, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: Text(
                        'Ignore',
                        style: TextStyle(
                            color: userController.isDark
                                ? primaryColor
                                : primaryColor),
                      ),
                    ),
                    SizedBox(
                      height: 65,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: () {
                                if (userModel.email == 'No email set') {
                                  Get.showSnackbar(GetSnackBar(
                                    message: 'Login to continue',
                                    duration: const Duration(
                                      seconds: 3,
                                    ),
                                    backgroundColor: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    mainButton: TextButton(
                                      onPressed: () {
                                        Get.to(() => ChooseAccountTypePage());
                                        Get.closeCurrentSnackbar();
                                      },
                                      child: Text(
                                        'Login Page',
                                        style: TextStyle(
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ));
                                } else {
                                  UserController().changeNotiOffers(
                                      0,
                                      false,
                                      userModel.userId,
                                      offersModel.offerId,
                                      userModel.accountType);
                                  Get.to(() => OfferReceivedDetails(
                                        offersModel: offersModel,
                                      ));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  fixedSize: Size(Get.width * 0.35, 40),
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              child: Text(
                                'Details',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (userController.userModel!.offerIdsToCheck
                              .contains(offersModel.offerId))
                            Positioned(
                                right: 5,
                                top: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: Colors.red,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.notifications_on_sharp,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ))
                        ],
                      ),
                    ),
                  ],
                ),
              if (offersReceivedModel != null)
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OfferRequestDetailsShort(
                          userController: userController,
                          offersReceivedModel: offersReceivedModel!),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (offersReceivedModel!.status != 'Completed' &&
                            offersReceivedModel!.status != 'Cancelled')
                          InkWell(
                            onTap: () async {
                              Get.dialog(LoadingDialog(),
                                  barrierDismissible: false);
                              DocumentSnapshot<Map<String, dynamic>> snap =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(offersReceivedModel!.ownerId)
                                      .get();
                              UserModel ownerDetails = UserModel.fromJson(snap);
                              ChatModel? chatModel = await ChatController()
                                  .getChat(userController.userModel!.userId,
                                      ownerDetails.userId, offersModel.offerId);
                              if (chatModel == null) {
                                await ChatController().createChat(
                                    userController.userModel!,
                                    ownerDetails,
                                    offersReceivedModel!.id,
                                    offersModel,
                                    'New Message',
                                    '${userController.userModel!.name} started a chat for ${offersModel.vehicleId}',
                                    'chat');
                                ChatModel? newchat = await ChatController()
                                    .getChat(
                                        userController.userModel!.userId,
                                        ownerDetails.userId,
                                        offersModel.offerId);
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
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(300),
                              ),
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SvgPicture.asset(
                                  'assets/messages.svg',
                                  height: 34,
                                  width: 34,
                                  color: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (offersReceivedModel!.status != 'Completed' &&
                            offersReceivedModel!.status != 'Cancelled')
                          const SizedBox(
                            width: 10,
                          ),
                        ElevatedButton(
                            onPressed: () {
                              int id = offersReceivedModel!.status == 'Pending'
                                  ? 1
                                  : offersReceivedModel!.status == 'inProgress'
                                      ? 2
                                      : offersReceivedModel!.status ==
                                              'Completed'
                                          ? 3
                                          : 4;
                              UserController().changeNotiOffers(
                                  id,
                                  false,
                                  userModel.userId,
                                  offersModel.offerId,
                                  userModel.accountType);
                              Get.to(() => RequestsReceivedProviderDetails(
                                    offersModel: offersModel,
                                    offersReceivedModel: offersReceivedModel!,
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: Size(
                                    offersReceivedModel!.status !=
                                                'Completed' &&
                                            offersReceivedModel!.status !=
                                                'Cancelled'
                                        ? Get.width * 0.6
                                        : Get.width * 0.8,
                                    50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                )),
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ))
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
