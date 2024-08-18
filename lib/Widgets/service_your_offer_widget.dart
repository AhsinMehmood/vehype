import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';

import '../const.dart';
import 'select_date_and_price.dart';

class ServiceYourOfferWidget extends StatelessWidget {
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;
  final bool yourOfferExpanded;
  const ServiceYourOfferWidget(
      {super.key,
      required this.offersModel,
      required this.offersReceivedModel,
      required this.yourOfferExpanded});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Card(
      // elevation: 12.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 400,
        ),
        curve: Curves.bounceInOut,
        height: yourOfferExpanded ? Get.height * 0.6 : 60,
        width: Get.width,
        decoration: BoxDecoration(
          color: userController.isDark ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: userController.isDark
                ? Colors.white.withOpacity(0.4)
                : primaryColor.withOpacity(0.4),
          ),
        ),
        padding: const EdgeInsets.all(15),
        child: yourOfferExpanded == false
            ? Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your Offer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Offer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: yourOfferExpanded
                              ? Icon(
                                  Icons.expand_more_outlined,
                                  size: 32.0,
                                  key: ValueKey('down'),
                                )
                              : Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  size: 32.0,
                                  key: ValueKey('right'),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
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
                                fontSize: 17,
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
                              formatDateTime(DateTime.parse(
                                  offersReceivedModel.startDate)),
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
                              formatDateTime(
                                  DateTime.parse(offersReceivedModel.endDate)),
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
                                'Details',
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
                                  fontWeight: FontWeight.w500,
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
                    if (offersReceivedModel.status == 'Completed')
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cancellation Reason',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'I have cancelled this job because I dont have enough time to countinue working on this forever.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
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
                    if (offersReceivedModel.status == 'Completed')
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cancelled By',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  offersReceivedModel.cancelBy ==
                                          userController.userModel!.userId
                                      ? 'This request was cancelled by ${userController.userModel!.name}.'
                                      : 'This request was cancelled by Service Owner.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
