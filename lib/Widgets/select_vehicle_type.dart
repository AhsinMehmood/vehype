import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/const.dart';

import '../Models/vehicle_model.dart';

class SelectVehicleType extends StatelessWidget {
  const SelectVehicleType({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select Vehicle Types',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Get.bottomSheet(selectServiceSheet(context));
          },
          child: Container(
            width: Get.width,
            // height: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: userController.isDark
                      ? Colors.white.withOpacity(0.2)
                      : primaryColor.withOpacity(0.2),
                )),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: Get.width * 0.8,
                    child: userController.selectedVehicleTypesFilter.isEmpty
                        ? Row(
                            children: [
                              Text(
                                'Tap to Select',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: userController
                                .selectedVehicleTypesFilter.length,
                            scrollDirection: Axis.horizontal,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Center(
                                child: Text(
                                  '${userController.selectedVehicleTypesFilter[index]}, ',
                                  style: TextStyle(
                                    // color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                  ),
                  Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget selectServiceSheet(BuildContext context) {
    return SelectServicesSheet();
  }
}

class SelectServicesSheet extends StatelessWidget {
  const SelectServicesSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController =
        Provider.of<UserController>(context, listen: true);
    return Container(
      decoration: BoxDecoration(
          color: userController.isDark ? primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6), topRight: Radius.circular(6))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Get.close(1);
                  },
                  child: Icon(Icons.close),
                ),
                InkWell(
                  onTap: () {
                    if (userController.selectedVehicleTypesFilter.isNotEmpty) {
                      userController.clearSelectedVehicleeTypes();
                    } else {
                      // List services = [];
                      for (VehicleType service in getVehicleType()) {
                        // services.add(service.title);
                        userController.selectVehicleTypesFilter(service.title);
                      }
                      // print(services.length);
                    }
                  },
                  child: Text(
                    userController.selectedVehicleTypesFilter.isEmpty
                        ? 'Select All'
                        : 'Clear',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 12, top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (VehicleType service in getVehicleType())
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                userController
                                    .selectVehicleTypesFilter(service.title);
                                // appProvider.selectPrefs(pref);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.5,
                                          child: Checkbox(
                                              value: userController
                                                  .selectedVehicleTypesFilter
                                                  .contains(service.title),
                                              onChanged: (ss) {
                                                userController
                                                    .selectVehicleTypesFilter(
                                                        service.title);
                                              }),
                                        ),
                                        SizedBox(
                                          height: 25,
                                          width: 40,
                                          child: SvgPicture.asset(
                                            service.icon,
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
                                            service.title,
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
                                  if (userController.selectedVehicleTypesFilter
                                      .contains(service.title))
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(200),
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
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
