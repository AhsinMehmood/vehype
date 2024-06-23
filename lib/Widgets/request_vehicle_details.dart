import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/offers_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class VehicleDetailsRequest extends StatefulWidget {
  const VehicleDetailsRequest({
    super.key,
    required this.userController,
    required this.vehicleType,
    required this.vehicleMake,
    required this.vehicleYear,
    required this.vehicleModle,
    this.isShowImage = true,
    required this.offersModel,
  });

  final UserController userController;
  final String vehicleType;
  final bool isShowImage;
  final String vehicleMake;
  final String vehicleYear;
  final String vehicleModle;
  final OffersModel offersModel;

  @override
  State<VehicleDetailsRequest> createState() => _VehicleDetailsRequestState();
}

class _VehicleDetailsRequestState extends State<VehicleDetailsRequest> {
  PageController pageController = PageController();
  int currentInde = 0;
  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(widget.offersModel.createdAt);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: Get.width,
              height: Get.width * 0.4,
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentInde = value;
                  });
                },
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => FullImagePageView(
                            urls: [widget.offersModel.imageOne],
                          ));
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: ExtendedImage.network(
                        widget.offersModel.imageOne,
                        width: Get.width,
                        height: Get.width * 0.4,
                        fit: BoxFit.cover,
                        cache: true,

                        // border: Border.all(color: Colors.red, width: 1.0),
                        shape: BoxShape.rectangle,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
                        //cancelToken: cancellationToken,
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          widget.offersModel.images.isEmpty
              ? const SizedBox.shrink()
              : SizedBox(
                  height: Get.width * 0.42,
                  width: Get.width,
                  child: PageView.builder(
                      itemCount: widget.offersModel.images.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.to(() => FullImagePageView(
                                  urls: widget.offersModel.images,
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
                                widget.offersModel.images[index],
                                fit: BoxFit.cover,
                                width: Get.width,
                                height: Get.width * 0.42,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        );
                      }),
                ),

          // if (widget.offersModel.imageOne != '' && widget.isShowImage)

          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Body Style',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: widget.userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.vehicleType.trim(),
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w700,
                            color: widget.userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle Year',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            color: widget.userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.vehicleYear.trim(),
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w700,
                            color: widget.userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Vehicle Make',
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.vehicleMake.trim(),
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w700,
                    color: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Vehicle Model',
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  widget.vehicleModle.trim(),
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w700,
                    color: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Time Ago',
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: widget.userController.isDark
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
                    color: widget.userController.isDark
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
                    color: widget.userController.isDark
                        ? Colors.white
                        : primaryColor,
                    fontSize: 13,
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
                                element.name == widget.offersModel.issue)
                            .image,
                        color: widget.userController.isDark
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
                        fontWeight: FontWeight.w700,
                        color: widget.userController.isDark
                            ? Colors.white
                            : primaryColor,
                        fontSize: 16,
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
        ],
      ),
    );
  }
}
