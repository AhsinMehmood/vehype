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

import '../Pages/full_image_view_page.dart';
import '../Pages/inactive_offers_seeker.dart';
import '../Pages/request_details_page.dart';
import '../const.dart';
import 'vehicle_owner_request_widget.dart';

class RequestsOwnerShortWidgetActive extends StatelessWidget {
  final OffersModel offersModel;
  final bool isActive;
  final String title;

  const RequestsOwnerShortWidgetActive(
      {super.key,
      required this.offersModel,
      this.isActive = false,
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
                        viewportFraction: offersModel.images.isEmpty ? 1 : 0.9),
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
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w400,
                      color:
                          userController.isDark ? Colors.white : primaryColor,
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
                height: 10,
              ),
              if (isActive)
                ActiveOfferDetailsButtonsVehicleOwner(
                    offersModel: offersModel, userController: userController)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StreamBuilder<List<OffersReceivedModel>>(
                        stream: FirebaseFirestore.instance
                            .collection('offersReceived')
                            .where('offerId', isEqualTo: offersModel.offerId)
                            // .where('status', isNotEqualTo: 'ignore')
                            .snapshots()
                            .map((event) => event.docs
                                .map((e) => OffersReceivedModel.fromJson(e))
                                .toList()),
                        builder: (context,
                            AsyncSnapshot<List<OffersReceivedModel>>
                                snapshots) {
                          List<OffersReceivedModel> offersReceivedModel =
                              snapshots.data ?? [];
                          offersReceivedModel = offersReceivedModel
                              .where((ee) => ee.status != 'ignore')
                              .toList();

                          if (offersReceivedModel.isEmpty) {
                            return Text(
                              'Deleted',
                            );
                          }
                          if (offersReceivedModel.first.status == 'Completed' &&
                              offersReceivedModel.first.ratingOne != 0.0) {
                            return ElevatedButton(
                              onPressed: () {
                                UserController().changeNotiOffers(
                                    6,
                                    false,
                                    userController.userModel!.userId,
                                    offersModel.offerId,
                                    userController.userModel!.accountType);
                                Get.to(() => InActiveOffersSeeker(
                                      offersModel: offersModel,
                                      tittle: title,
                                      offersReceivedModel:
                                          offersReceivedModel.first,
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  elevation: 0.0,
                                  fixedSize: Size(Get.width * 0.4, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              child: RatingBarIndicator(
                                rating: offersReceivedModel.first.ratingOne,
                                itemSize: 20,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            );
                          }
                          if (offersReceivedModel.first.status.toLowerCase() ==
                                  'Cancelled'.toLowerCase() &&
                              offersReceivedModel.first.ratingOne != 0.0) {
                            return ElevatedButton(
                              onPressed: () {
                                UserController().changeNotiOffers(
                                    6,
                                    false,
                                    userController.userModel!.userId,
                                    offersModel.offerId,
                                    userController.userModel!.accountType);
                                Get.to(() => InActiveOffersSeeker(
                                      offersModel: offersModel,
                                      tittle: title,
                                      offersReceivedModel:
                                          offersReceivedModel.first,
                                    ));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  elevation: 0.0,
                                  fixedSize: Size(Get.width * 0.4, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              child: RatingBarIndicator(
                                rating: offersReceivedModel.first.ratingOne,
                                itemSize: 20,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 55,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      UserController().changeNotiOffers(
                                          6,
                                          false,
                                          userController.userModel!.userId,
                                          offersModel.offerId,
                                          userController
                                              .userModel!.accountType);
                                      Get.to(() => InActiveOffersSeeker(
                                            offersModel: offersModel,
                                            tittle: title,
                                            offersReceivedModel:
                                                offersReceivedModel.first,
                                          ));
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        elevation: 0.0,
                                        fixedSize: Size(Get.width * 0.4, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        )),
                                    child: Text(
                                      offersReceivedModel.first.status,
                                      style: TextStyle(
                                          color: userController.isDark
                                              ? primaryColor
                                              : Colors.white),
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
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: Colors.red,
                                        ),
                                        padding: const EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.notifications_on_sharp,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ))
                              ],
                            ),
                          );
                        }),
                    const SizedBox(
                      width: 10,
                    ),
                    // if (filterReceivedOffers.isEmpty)
                    ElevatedButton(
                      onPressed: () {
                        Get.to(
                            () => RequestDetailsPage(offersModel: offersModel));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          elevation: 0.0,
                          fixedSize: Size(Get.width * 0.4, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
