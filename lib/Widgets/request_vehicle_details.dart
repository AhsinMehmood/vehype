import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vehype/Pages/full_image_view_page.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/offers_model.dart';

class VehicleDetailsRequest extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offersModel.imageOne != '' && isShowImage)
            SizedBox(
              // width: Get.width * 0.9,
              // height: Get.width * 0.9,
              child: InkWell(
                onTap: () {
                  Get.to(() => FullImagePageView(
                        url: offersModel.imageOne,
                      ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: ExtendedImage.network(
                    offersModel.imageOne,
                    width: Get.width * 0.9,
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
            ),
          if (offersModel.imageOne != '' && isShowImage)
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
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  vehicleType,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: userController.isDark ? Colors.white : primaryColor,
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
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  vehicleMake,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: userController.isDark ? Colors.white : primaryColor,
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
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  vehicleYear,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: userController.isDark ? Colors.white : primaryColor,
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
                    color: userController.isDark ? Colors.white : primaryColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  vehicleModle,
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w400,
                    color: userController.isDark ? Colors.white : primaryColor,
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
                    color: userController.isDark ? Colors.white : primaryColor,
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
                            .firstWhere(
                                (element) => element.name == offersModel.issue)
                            .image,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                        height: 15,
                        width: 15),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      offersModel.issue,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
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
