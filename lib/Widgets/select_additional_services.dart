import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/const.dart';

class SelectAdditionalServices extends StatelessWidget {
  const SelectAdditionalServices({super.key});

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
              'Select Additional Services',
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
                    child: userController.selectedAdditionalServices.isEmpty
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
                                .selectedAdditionalServices.length,
                            scrollDirection: Axis.horizontal,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Center(
                                child: Text(
                                  '${userController.selectedAdditionalServices[index]}, ',
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
                    if (userController.selectedAdditionalServices.isNotEmpty) {
                      userController.clearAdditionalServices();
                    } else {
                      List services = [];
                      for (AdditionalServiceModel service
                          in getAdditionalService()) {
                        services.add(service.name);
                      }
                      print(services.length);
                      userController.selectAllAdditionalServices(services);
                    }
                  },
                  child: Text(
                    userController.selectedAdditionalServices.isEmpty
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
                        for (AdditionalServiceModel service
                            in getAdditionalService())
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  userController
                                      .selectAdditionalServices(service.name);
                                  // appProvider.selectPrefs(pref);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Transform.scale(
                                      scale: 1.5,
                                      child: Checkbox(
                                          activeColor: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          checkColor: userController.isDark
                                              ? Colors.green
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          value: userController
                                              .selectedAdditionalServices
                                              .contains(service.name),
                                          onChanged: (s) {
                                            // appProvider.selectPrefs(pref);
                                            userController
                                                .selectAdditionalServices(
                                                    service.name);
                                          }),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    SvgPicture.asset(service.icon,
                                        height: 40,
                                        width: 40,
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      service.name,
                                      style: TextStyle(
                                        color: userController.isDark
                                            ? Colors.white
                                            : primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
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
