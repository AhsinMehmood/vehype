// import 'package:extended_image/extended_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';

import '../Controllers/garage_controller.dart';
import '../Models/product_service_model.dart';
import '../Pages/full_image_view_page.dart';
import '../const.dart';
import 'select_date_and_price.dart';

class ServiceYourOfferWidget extends StatefulWidget {
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
  State<ServiceYourOfferWidget> createState() => _ServiceYourOfferWidgetState();
}

class _ServiceYourOfferWidgetState extends State<ServiceYourOfferWidget> {
  // List ids = [];

  @override
  void initState() {
    super.initState();

    // initProducts(ids);
  }

  // List<ProductServiceModel> prodc = [];

  // initProducts(List ids) async {
  //   final GarageController garageController =
  //       Provider.of<GarageController>(context, listen: false);
  //   for (var id in ids) {
  //     print('object');

  //     DocumentSnapshot<Map<String, dynamic>> products =
  //         await FirebaseFirestore.instance.collection('products').doc(id).get();
  //     prodc.add(ProductServiceModel.fromJson(products));
  //   }
  //   for (var element in prodc) {
  //     garageController.select(element);
  //   }
  // }

  String getServiceDetail(ProductServiceModel prod) {
    if (prod.index == 0) {
      return '\$${double.parse(prod.pricePerItem).toStringAsFixed(2)} x ${prod.quantity} units';
    } else if (prod.index == 1) {
      return '\$${prod.hourlyRate} x ${prod.hours} hours';
    } else {
      return '\$${prod.flatRate}';
    }
  }

  String getTotal(GarageController garageController) {
    double total = 0.0;

    List<ProductServiceModel> prodcuts = garageController.selected;

    for (var element in prodcuts) {
      total += double.tryParse(element.totalPrice) ?? 0.0;
    }

    return '\$${total.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final GarageController garageController =
        Provider.of<GarageController>(context);
    // for (var element in widget.offersReceivedModel.ids) {
    //   ids.add(element);
    // }
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
        height: widget.yourOfferExpanded ? Get.height * 0.8 : 60,
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
        child: widget.yourOfferExpanded == false
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
                    if (widget.offersReceivedModel.products.isNotEmpty)
                      ExpansionTile(
                        tilePadding: const EdgeInsets.all(0),
                        childrenPadding: const EdgeInsets.all(0),
                        iconColor:
                            userController.isDark ? Colors.white : primaryColor,

                        initiallyExpanded:
                            true, // You can set this to false if you want it collapsed by default
                        title: Text(
                          'Product or Service (${widget.offersReceivedModel.products.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          if (widget.offersReceivedModel.products.isNotEmpty)
                            ListView.builder(
                              itemCount:
                                  widget.offersReceivedModel.products.length,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(0),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final ProductServiceModel product =
                                    widget.offersReceivedModel.products[index];

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (product.desc.isNotEmpty)
                                            Text(
                                              product.desc, // Show description
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
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
                          Text('\$${widget.offersReceivedModel.price}',
                              style: TextStyle(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // if (widget.offersReceivedModel.status == 'Upcoming' ||
                    //     widget.offersReceivedModel.status == 'Completed' ||
                    //     widget.offersReceivedModel.status == 'Cancelled')
                    //   Column(
                    //     children: [
                    //       const SizedBox(
                    //         height: 15,
                    //       ),
                    //       Padding(
                    //         padding: const EdgeInsets.only(left: 10, right: 10),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             ElevatedButton(
                    //                 onPressed: () {},
                    //                 style: ElevatedButton.styleFrom(
                    //                     minimumSize: Size(Get.width * 0.8, 55),
                    //                     backgroundColor: userController.isDark
                    //                         ? Colors.white
                    //                         : primaryColor,
                    //                     shape: RoundedRectangleBorder(
                    //                       borderRadius:
                    //                           BorderRadius.circular(6),
                    //                     )),
                    //                 child: Text(
                    //                   'Convert to Invoice',
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.w700,
                    //                     fontSize: 16,
                    //                     color: userController.isDark
                    //                         ? primaryColor
                    //                         : Colors.white,
                    //                   ),
                    //                 )),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    if (widget.offersReceivedModel.status == 'Cancelled')
                      const SizedBox(
                        height: 15,
                      ),
                    if (widget.offersReceivedModel.status == 'Cancelled')
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
                                  widget.offersReceivedModel.cancelReason == ''
                                      ? 'No reason provided'
                                      : widget.offersReceivedModel.cancelReason,
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
                    if (widget.offersReceivedModel.status == 'Cancelled')
                      const SizedBox(
                        height: 15,
                      ),
                    if (widget.offersReceivedModel.status == 'Cancelled')
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
                                  widget.offersReceivedModel.cancelBy ==
                                          'provider'
                                      ? 'This offer was cancelled by You.'
                                      : 'This offer was cancelled by ${widget.ownerModel.name}',
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
                    if (widget.offersReceivedModel.ratingTwo != 0.0)
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
                                rating: widget.offersReceivedModel.ratingTwo,
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
                                widget.offersReceivedModel.commentTwo,
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
                          if (widget.offersReceivedModel.ratingTwoImage != '')
                            const SizedBox(
                              height: 20,
                            ),
                          if (widget.offersReceivedModel.ratingTwoImage != '')
                            InkWell(
                              onTap: () {
                                Get.to(() => FullImagePageView(
                                      urls: [
                                        widget
                                            .offersReceivedModel.ratingTwoImage
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
                                  imageUrl:
                                      widget.offersReceivedModel.ratingTwoImage,

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
                    if (widget.offersReceivedModel.ratingOne != 0.0)
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                '${widget.ownerModel.name}\'s Feedback',
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
                                rating: widget.offersReceivedModel.ratingOne,
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
                                widget.offersReceivedModel.commentOne,
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
                          if (widget.offersReceivedModel.ratingOneImage != '')
                            const SizedBox(
                              height: 20,
                            ),
                          if (widget.offersReceivedModel.ratingOneImage != '')
                            InkWell(
                              onTap: () {
                                Get.to(() => FullImagePageView(
                                      urls: [
                                        widget
                                            .offersReceivedModel.ratingOneImage
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
                                  imageUrl:
                                      widget.offersReceivedModel.ratingOneImage,

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
