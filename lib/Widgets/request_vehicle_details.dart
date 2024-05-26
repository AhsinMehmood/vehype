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
              height: Get.width * 0.3,
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentInde = value;
                  });
                },
                children: [
                  if (widget.offersModel.imageOne != '' && widget.isShowImage)
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
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          //cancelToken: cancellationToken,
                        ),
                      ),
                    ),
                  if (widget.offersModel.imageTwo != '' && widget.isShowImage)
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
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                      color: currentInde == 0 ? Colors.green : Colors.grey,
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
                      color: currentInde == 1 ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // if (widget.offersModel.imageOne != '' && widget.isShowImage)
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
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
                  widget.vehicleType,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
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
                  widget.vehicleMake,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
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
                  widget.vehicleYear,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
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
                  widget.vehicleModle,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
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
                    fontWeight: FontWeight.w400,
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
                        height: 15,
                        width: 15),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.offersModel.issue,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
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
