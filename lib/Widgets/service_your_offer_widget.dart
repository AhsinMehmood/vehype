// import 'package:extended_image/extended_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';

import '../Pages/full_image_view_page.dart';
import '../const.dart';
import 'select_date_and_price.dart';

class ServiceYourOfferWidget extends StatelessWidget {
  final OffersModel offersModel;
  final OffersReceivedModel offersReceivedModel;
  // final GarageModel garageModel;
  final UserModel ownerModel;
  final bool yourOfferExpanded;
  const ServiceYourOfferWidget(
      {super.key,
      required this.offersModel,
      required this.offersReceivedModel,
      required this.ownerModel,
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
        height: yourOfferExpanded ? Get.height * 0.76 : 60,
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
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Offer Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 35,
                        ),
                      ],
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
                                fontSize: 16,
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
                                fontSize: 16,
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
                                fontSize: 16,
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
                              InkWell(
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
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
                    if (offersReceivedModel.status == 'Cancelled')
                      const SizedBox(
                        height: 15,
                      ),
                    if (offersReceivedModel.status == 'Cancelled')
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  child: Text(
                                    'Cancellation Reason',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  offersReceivedModel.cancelReason == ''
                                      ? 'No reason provided'
                                      : offersReceivedModel.cancelReason,
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
                    if (offersReceivedModel.status == 'Cancelled')
                      const SizedBox(
                        height: 15,
                      ),
                    if (offersReceivedModel.status == 'Cancelled')
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  child: Text(
                                    'Cancelled By',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  offersReceivedModel.cancelBy == 'provider'
                                      ? 'This offer was cancelled by You.'
                                      : 'This offer was cancelled by ${ownerModel.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (offersReceivedModel.ratingTwo != 0.0)
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                'Your Feedback',
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
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: offersReceivedModel.ratingTwo,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 25,
                                ),
                                itemSize: 25,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ReadMoreText(
                                offersReceivedModel.commentTwo,
                                trimMode: TrimMode.Line,
                                trimLines: 2,
                                colorClickableText: Colors.pink,
                                trimCollapsedText: ' Show more',
                                trimExpandedText: ' Show less',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                moreStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (offersReceivedModel.ratingTwoImage != '')
                            const SizedBox(
                              height: 20,
                            ),
                          if (offersReceivedModel.ratingTwoImage != '')
                            InkWell(
                              onTap: () {
                                Get.to(() => FullImagePageView(
                                      urls: [
                                        offersReceivedModel.ratingTwoImage
                                      ],
                                      currentIndex: 0,
                                    ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorWidget: (context, url, error) =>
                                      const SizedBox.shrink(),
                                  imageUrl: offersReceivedModel.ratingTwoImage,

                                  height: 220,
                                  // shape: BoxShape.rectangle,
                                  fit: BoxFit.cover,
                                  // borderRadius: BorderRadius.only(
                                  //   bottomLeft: Radius.circular(6),
                                  //   bottomRight: Radius.circular(6),
                                  // ),
                                  width: Get.width * 0.95,
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (offersReceivedModel.ratingOne != 0.0)
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                '${ownerModel.name}\'s Feedback',
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
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: offersReceivedModel.ratingOne,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 25,
                                ),
                                itemSize: 25,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ReadMoreText(
                                offersReceivedModel.commentOne,
                                trimMode: TrimMode.Line,
                                trimLines: 2,
                                colorClickableText: Colors.pink,
                                trimCollapsedText: ' Show more',
                                trimExpandedText: ' Show less',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                moreStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (offersReceivedModel.ratingOneImage != '')
                            const SizedBox(
                              height: 20,
                            ),
                          if (offersReceivedModel.ratingOneImage != '')
                            InkWell(
                              onTap: () {
                                Get.to(() => FullImagePageView(
                                      urls: [
                                        offersReceivedModel.ratingOneImage
                                      ],
                                      currentIndex: 0,
                                    ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  placeholder: (context, url) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorWidget: (context, url, error) =>
                                      const SizedBox.shrink(),
                                  imageUrl: offersReceivedModel.ratingOneImage,

                                  height: 220,
                                  // shape: BoxShape.rectangle,
                                  fit: BoxFit.cover,
                                  // borderRadius: BorderRadius.only(
                                  //   bottomLeft: Radius.circular(6),
                                  //   bottomRight: Radius.circular(6),
                                  // ),
                                  width: Get.width * 0.95,
                                ),
                              ),
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
