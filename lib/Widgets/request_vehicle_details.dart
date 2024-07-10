import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
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
            height: Get.width * 0.42,
            width: Get.width,
            child: PageView.builder(
                itemCount: widget.offersModel.images.length + 1,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  List imagess = [];
                  for (var element in widget.offersModel.images) {
                    imagess.add(element);
                  }
                  imagess.insert(0, widget.offersModel.imageOne);

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
                            widget.offersModel.imageOne,
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
                            widget.offersModel.images[inde],
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

          // if (widget.offersModel.imageOne != '' && widget.isShowImage)

          Padding(
            padding: const EdgeInsets.all(9),
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
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
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
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (widget.offersModel.additionalService != '')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Service',
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
                              getAdditionalService()
                                  .firstWhere((element) =>
                                      element.name ==
                                      widget.offersModel.additionalService)
                                  .icon,
                              color: widget.userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              height: 35,
                              width: 35),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            widget.offersModel.additionalService,
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
                    ],
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
                  height: 8,
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
                  height: 15,
                ),
                // if (widget.offersModel.description != '')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Details',
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
                      widget.offersModel.description == ''
                          ? 'Details will be provided on Chat.'
                          : widget.offersModel.description,
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
                  height: 20,
                ),
                InkWell(
                  child: SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: Get.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GoogleMap(
                              markers: {
                                Marker(
                                  markerId: MarkerId('current'),
                                  position: LatLng(widget.offersModel.lat,
                                      widget.offersModel.long),
                                ),
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(widget.offersModel.lat,
                                    widget.offersModel.long),
                                zoom: 16.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              MapsLauncher.launchCoordinates(
                                  widget.offersModel.lat,
                                  widget.offersModel.long);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(200),
                              ),
                              color: primaryColor,
                              child: Container(
                                height: 40,
                                width: Get.width * 0.7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: primaryColor,
                                    border: Border.all(color: Colors.white)),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'View Directions',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
