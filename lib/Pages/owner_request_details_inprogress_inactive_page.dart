import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/Pages/owner_active_request_details.dart';

import 'package:vehype/const.dart';

import '../Controllers/vehicle_data.dart';
import '../Widgets/owner_inactive_inprogress_offer_widget.dart';

class OwnerRequestDetailsInprogressInactivePage extends StatefulWidget {
  final OffersModel offersModel;
  final GarageModel garageModel;
  final OffersReceivedModel offersReceivedModel;
  final String? chatId;
  const OwnerRequestDetailsInprogressInactivePage(
      {super.key,
      required this.offersModel,
      required this.garageModel,
      required this.offersReceivedModel,
      this.chatId});

  @override
  State<OwnerRequestDetailsInprogressInactivePage> createState() =>
      _OwnerRequestDetailsInprogressInactivePageState();
}

class _OwnerRequestDetailsInprogressInactivePageState
    extends State<OwnerRequestDetailsInprogressInactivePage> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final OffersProvider offersProvider = Provider.of<OffersProvider>(context);
    final OffersModel offersModel = offersProvider.ownerOffers
        .firstWhere((offer) => offer.offerId == widget.offersModel.offerId);

    return Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            'Offer Details',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            // IconButton(
            //   onPressed: () {
            //     Get.dialog(Dialog(
            //       backgroundColor:
            //           userController.isDark ? primaryColor : Colors.white,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(6)),
            //       child: Padding(
            //         padding: const EdgeInsets.all(12.0),
            //         child: SingleChildScrollView(
            //           child: Column(
            //             children: [
            //               const SizedBox(
            //                 height: 20,
            //               ),
            //               Row(
            //                 children: [
            //                   Icon(
            //                     Icons.feedback_rounded,
            //                   ),
            //                   const SizedBox(
            //                     width: 10,
            //                   ),
            //                   Text(
            //                     'Private Feedback',
            //                     style: TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               const SizedBox(
            //                 height: 20,
            //               ),
            //               Row(
            //                 children: [
            //                   Icon(
            //                     Icons.contact_support,
            //                   ),
            //                   const SizedBox(
            //                     width: 10,
            //                   ),
            //                   Text(
            //                     'Get Support',
            //                     style: TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.w600,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               const SizedBox(
            //                 height: 20,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ));
            //   },
            //   icon: Icon(
            //     Icons.help,
            //   ),
            // ),
          ],
        ),
        body: Column(
          children: [
            Column(
              children: [
                InkWell(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    margin: const EdgeInsets.all(0),
                    color: userController.isDark ? primaryColor : Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 12, right: 12, top: 12),
                      child: InkWell(
                        onTap: () {
                          if (widget.chatId == null) {
                            Get.to(() => OwnerActiveRequestDetails(
                                offersModel: offersModel));
                          }
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.to(() => FullImagePageView(
                                          urls: [widget.garageModel.imageUrl],
                                          currentIndex: 0,
                                        ));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.garageModel.imageUrl,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.garageModel.title,
                                        maxLines: 2,
                                        style: TextStyle(
                                          // color: Colors.black,

                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                              getServices()
                                                  .firstWhere((element) =>
                                                      element.name ==
                                                      offersModel.issue)
                                                  .image,
                                              color: userController.isDark
                                                  ? Colors.white
                                                  : primaryColor,
                                              height: 25,
                                              width: 25),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            ' ',
                                            style: TextStyle(
                                              // color: Colors.black,

                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            offersModel.issue,
                                            style: TextStyle(
                                              // color: Colors.black,

                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      )
                                    ],
                                  ),
                                ),
                                if (widget.chatId == null)
                                  IconButton(
                                    onPressed: () {
                                      if (widget.chatId == null) {
                                        Get.to(() => OwnerActiveRequestDetails(
                                            offersModel: offersModel));
                                      }
                                    },
                                    icon:
                                        Icon(Icons.arrow_forward_ios_outlined),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: OwnerInactiveInprogressOfferWidget(
                    offersModels: offersModel,
                    chatId: widget.chatId,
                    garageModel: widget.garageModel,
                    offersReceivedModels: widget.offersReceivedModel),
              ),
            ),
          ],
        ));
  }
}
