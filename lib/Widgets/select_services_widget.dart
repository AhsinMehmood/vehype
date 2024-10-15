import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/const.dart';

class SelectServicesWidget extends StatelessWidget {
  const SelectServicesWidget({super.key});

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
              'Select Services *',
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
                    child: userController.selectedServices.isEmpty
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
                            itemCount: userController.selectedServices.length,
                            scrollDirection: Axis.horizontal,
                            // physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Center(
                                child: Text(
                                  '${userController.selectedServices[index]}, ',
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
                    if (userController.selectedServices.isNotEmpty) {
                      userController.clearServices();
                    } else {
                      List services = [];
                      for (Service service in getServices()) {
                        services.add(service.name);
                      }
                      print(services.length);
                      userController.selectAllServices(services);
                    }
                  },
                  child: Text(
                    userController.selectedServices.isEmpty
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
                        for (Service service in getServices())
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  userController.selectServices(service.name);
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
                                          value: userController.selectedServices
                                              .contains(service.name),
                                          onChanged: (s) {
                                            // appProvider.selectPrefs(pref);
                                            userController
                                                .selectServices(service.name);
                                          }),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    SvgPicture.asset(service.image,
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
