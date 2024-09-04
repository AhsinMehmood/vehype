import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/owner_accept_offer_confirmation.dart';
import 'package:vehype/Widgets/owner_ignore_offer_confirmation_widget.dart';

import '../Controllers/offers_controller.dart';
import '../Models/user_model.dart';
import '../Pages/second_user_profile.dart';
import '../const.dart';
import 'select_date_and_price.dart';

class OwnerOfferReceivedNewWidget extends StatelessWidget {
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;
  final GarageModel garageModel;
  final String? chatId;
  const OwnerOfferReceivedNewWidget(
      {super.key,
      this.chatId,
      required this.offersModel,
      required this.garageModel,
      required this.offersReceivedModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Container(
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: userController.isDark
              ? Colors.white.withOpacity(0.2)
              : primaryColor.withOpacity(0.2),
        ),
      ),
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 15, top: 0),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Offer by',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          StreamBuilder<UserModel>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(offersReceivedModel.offerBy)
                  .snapshots()
                  .map((ss) => UserModel.fromJson(ss)),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel secondUser = snapshot.data!;
                  return InkWell(
                    onTap: () {
                      Get.to(
                          () => SecondUserProfile(userId: secondUser.userId));
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: ExtendedImage.network(
                            secondUser.profileUrl,
                            height: 65,
                            width: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              secondUser.name,
                              style: TextStyle(
                                // color: Colors.black,

                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            RatingBarIndicator(
                              rating: secondUser.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Text(
                                  'See Profile ',
                                  style: TextStyle(
                                    // color: Colors.black,

                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 16,
                                  weight: 900.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: 0.5,
            width: Get.width,
            color: userController.isDark
                ? Colors.white.withOpacity(0.2)
                : primaryColor.withOpacity(0.2),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Offer Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '\$${offersReceivedModel.price}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start At',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    formatDateTime(
                        DateTime.parse(offersReceivedModel.startDate)),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End At',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    formatDateTime(DateTime.parse(offersReceivedModel.endDate)),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      offersReceivedModel.comment == ''
                          ? 'No details provided'
                          : offersReceivedModel.comment,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  Get.bottomSheet(OwnerIgnoreOfferConfirmationWidget(
                      userController: userController,
                      offersModel: offersModel,
                      offersReceivedModel: offersReceivedModel));
                },
                child: Container(
                  height: 50,
                  width: Get.width * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'Ignore',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  DocumentSnapshot<Map<String, dynamic>> offerByQuery =
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(offersReceivedModel.offerBy)
                          .get();
                  // Get.close(1);

                  await OffersController().chatWithOffer(
                      userModel,
                      UserModel.fromJson(offerByQuery),
                      offersModel,
                      offersReceivedModel,
                      garageModel);
                },
                child: Container(
                  height: 50,
                  width: Get.width * 0.28,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/messenger.png',
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        'Chat',
                        style: TextStyle(
                          // color: userController.isDark ? Colors.white : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  Get.bottomSheet(OwnerAcceptOfferConfirmation(
                      offersReceivedModel: offersReceivedModel,
                      offersModel: offersModel,
                      userModel: userModel,
                      chatId: chatId,
                      garageModel: garageModel,
                      userController: userController));
                },
                child: Container(
                  height: 50,
                  width: Get.width * 0.28,
                  decoration: BoxDecoration(
                    color: userController.isDark ? Colors.white : primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'Accept',
                      style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
