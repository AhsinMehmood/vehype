import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Controllers/garage_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../Controllers/vehicle_data.dart';
import '../../Models/vehicle_model.dart';
import '../../const.dart';

class BodyStylePicker extends StatelessWidget {
  const BodyStylePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (VehicleType bodyStyle in getVehicleType())
                InkWell(
                  onTap: () {
                    // VehicleType vehicleType = VehicleType(
                    //     title: titleMapping[bodyStyle.title]!,
                    //     icon: bodyStyle.icon);
                    // garageController.selectVehicleType(bodyStyle);

                    // Get.close(1);
                    // showModalBottomSheet(
                    //     context: context,
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(15),
                    //       topRight: Radius.circular(15),
                    //     )),
                    //     // constraints: BoxConstraints(
                    //     //   minHeight: Get.height * 0.7,
                    //     //   maxHeight: Get.height * 0.7,
                    //     // ),
                    //     isScrollControlled: true,
                    //     // showDragHandle: true,
                    //     builder: (context) {
                    //       return MakePicker();
                    //     }).then((value) {
                    //   // editProfileProvider
                    //   //     .upadeteUpcomingDestinations(userModel);
                    // });
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 40,
                                    child: SvgPicture.asset(
                                      bodyStyle.icon,
                                      height: 25,
                                      width: 25,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      bodyStyle.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (garageController.selectedVehicleType != null &&
                                garageController.selectedVehicleType!.title
                                        .toLowerCase() ==
                                    bodyStyle.title.toLowerCase())
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: Colors.green,
                                ),
                                child: Icon(
                                  Icons.done,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 1,
                        width: Get.width * 0.9,
                        color: userController.isDark
                            ? Colors.white.withOpacity(0.3)
                            : primaryColor.withOpacity(0.3),
                      ),
                    ],
                  ),
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
