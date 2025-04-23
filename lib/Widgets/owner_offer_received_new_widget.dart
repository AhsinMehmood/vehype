import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Widgets/owner_accept_offer_confirmation.dart';
import 'package:vehype/Widgets/owner_ignore_offer_confirmation_widget.dart';
import 'package:vehype/Widgets/user_rating_short_widget.dart';

import '../Controllers/offers_controller.dart';
import '../Models/product_service_model.dart';
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
                  return UserRatingShortWidget(secondUser: secondUser);
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
          if (offersReceivedModel.products.isNotEmpty)
            ExpansionTile(
              tilePadding: const EdgeInsets.all(0),
              childrenPadding: const EdgeInsets.all(0),
              iconColor: userController.isDark ? Colors.white : primaryColor,

              initiallyExpanded:
                  true, // You can set this to false if you want it collapsed by default
              title: Text(
                'Product or Service (${offersReceivedModel.products.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                const SizedBox(
                  height: 10,
                ),
                if (offersReceivedModel.products.isNotEmpty)
                  ListView.builder(
                    itemCount: offersReceivedModel.products.length,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final ProductServiceModel product =
                          offersReceivedModel.products[index];

                      return Stack(
                        children: [
                          ListTile(
                            dense: true,
                            title: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.desc.isNotEmpty)
                                  Text(
                                    product.desc, // Show description
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  getServiceDetail(
                                      product), // Show service details
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Text('\$${product.totalPrice}',
                                style: TextStyle(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      );
                    },
                  ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('\$${offersReceivedModel.price}',
                    style: TextStyle(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),

          const SizedBox(
            height: 15,
          ),
          // if (offersReceivedModel.endDate != null)
          //   Row(
          //     children: [
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'End At',
          //             style: TextStyle(
          //               fontSize: 15,
          //               fontWeight: FontWeight.w400,
          //             ),
          //           ),
          //           const SizedBox(
          //             height: 5,
          //           ),
          //           Text(
          //             formatDateTime(
          //                 DateTime.parse(offersReceivedModel.endDate!)),
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w800,
          //             ),
          //           ),
          //         ],
          //       )
          //     ],
          //   ),
          // if (offersReceivedModel.endDate != null)
          //   const SizedBox(
          //     height: 15,
          //   ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Description',
          //             style: TextStyle(
          //               fontSize: 15,
          //               fontWeight: FontWeight.w400,
          //             ),
          //           ),
          //           const SizedBox(
          //             height: 5,
          //           ),
          //           Text(
          //             offersReceivedModel.comment == ''
          //                 ? 'No details provided'
          //                 : offersReceivedModel.comment,
          //             style: TextStyle(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w600,
          //             ),
          //           ),
          //         ],
          //       ),
          //     )
          //   ],
          // ),
          // const SizedBox(
          //   height: 15,
          // ),
          // if()
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.green.withOpacity(0.2),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    Text(
                      '  EST will be provided in the chat.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Spacer(),
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
                      'Reject',
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

String getServiceDetail(ProductServiceModel prod) {
  if (prod.index == 0) {
    return '\$${double.parse(prod.pricePerItem).toStringAsFixed(2)} x ${prod.quantity} units';
  } else if (prod.index == 1) {
    return '\$${prod.hourlyRate} x ${prod.hours} hours';
  } else {
    return '\$${prod.flatRate}';
  }
}
