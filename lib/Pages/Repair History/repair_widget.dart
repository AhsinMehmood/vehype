import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Pages/Personal%20Assistance%20/assistance_guide_ui.dart';
import 'package:vehype/Pages/create_request_page.dart';
import 'package:vehype/Widgets/loading_dialog.dart';

import 'package:vehype/const.dart';

import '../../Models/product_service_model.dart';
import '../../Widgets/owner_active_request_button_widget.dart';
import '../../Widgets/owner_inprogress_button_widget.dart';
import '../../Widgets/select_date_and_price.dart';
import '../../Widgets/service_request_widget.dart';
import '../../providers/assistance_guide_ai_service.dart';
import '../owner_request_details_inprogress_inactive_page.dart';

class RepairWidget extends StatelessWidget {
  final OffersModel offersModel;
  final GarageModel garageModel;
  final OffersReceivedModel? offersReceivedModel;
  const RepairWidget(
      {super.key,
      required this.offersModel,
      this.offersReceivedModel,
      required this.garageModel});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    DateTime createdAt = DateTime.parse(offersModel.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: userController.isDark ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: userController.isDark
              ? Colors.white.withOpacity(0.2)
              : primaryColor.withOpacity(0.2),
        ),
      ),
      margin: EdgeInsets.only(left: 5, right: 5, bottom: 15, top: 0),
      child: Column(
        children: [
          SizedBox(
            height: 130,
            width: Get.width,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: offersModel.images.isNotEmpty
                        ? offersModel.images.first
                        : garageModel.imageUrl,
                    fit: BoxFit.cover,
                    height: 130,
                    width: Get.width,
                    placeholder: (context, url) => Center(
                        child: SizedBox(
                            height: 130,
                            width: 130,
                            child: Center(
                                child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: CircularProgressIndicator())))),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/icon.png"),
                  ),
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 5,
                      top: 5,
                    ),
                    margin: const EdgeInsets.only(
                      left: 10,
                      top: 10,
                    ),
                    child: Text(
                      formatDateForRequestWidget(createdAt.toLocal()),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            getServices()
                                .firstWhere(
                                    (test) => test.name == offersModel.issue)
                                .image,
                            height: 35,
                            width: 35,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            offersModel.issue,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 0.5,
                    width: Get.width,
                    color: userController.isDark
                        ? Colors.white.withOpacity(0.2)
                        : primaryColor.withOpacity(0.2),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Price:  ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '\$${offersReceivedModel!.price}',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            'Completed at: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            formatDateTime(
                              DateTime.parse(
                                offersReceivedModel!.completedAt,
                              ).toLocal(),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 0.5,
                        width: Get.width,
                        color: userController.isDark
                            ? Colors.white.withOpacity(0.2)
                            : primaryColor.withOpacity(0.2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () async {
                    Get.to(() => OwnerRequestDetailsInprogressInactivePage(
                        offersModel: offersModel,
                        garageModel: garageModel,
                        offersReceivedModel: offersReceivedModel!));
                  },
                  child: Container(
                    height: 50,
                    width: Get.width * 0.44,
                    decoration: BoxDecoration(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'See Details',
                        style: TextStyle(
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final AssistanceGuideAiService chatGPTService =
                        AssistanceGuideAiService();

                    String prompt =
                        "How to ${offersModel.issue} on Make: ${garageModel.make}, Model: ${garageModel.model}, Year: ${garageModel.year}, Submodel: ${garageModel.submodel}.";

                    // late Future<String> _repairGuide;
                    // final Map<int, bool> _expandedSections = {};
                    Map<String, dynamic>? repairGuide;
                    Get.dialog(LoadingDialog());
                    try {
                      // 2. Use in your prompt
                      // QuerySnapshot<Map<String, dynamic>> querySnapshot =
                      //     await FirebaseFirestore.instance
                      //         .collection('repairGuides')
                      //         .where(
                      //           'model',
                      //           isEqualTo: garageModel.model,
                      //         )
                      //         .where('year', isEqualTo: garageModel.year)
                      //         .get();

                      repairGuide = await chatGPTService.repairCall(
                        prompt,
                      );
                      Get.close(1);

                      Get.to(() => AssistanceGuideUi(
                            repairGuide: repairGuide,
                          ));
                    } catch (e) {
                      Get.close(1);

                      print(e);
                    }
                  },
                  child: Container(
                    height: 50,
                    width: Get.width * 0.42,
                    decoration: BoxDecoration(
                      // color:
                      //     userController.isDark ? Colors.white : primaryColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Repair Guide',
                        style: TextStyle(
                          // color: userController.isDark
                          //     ? primaryColor
                          //     : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatProduct(ProductServiceModel product) {
    final props = <String>[];

    // Check non-empty fields
    if (product.desc.isNotEmpty) {
      props.add('Description: ${product.desc}');
    }
    if (product.pricePerItem.isNotEmpty) {
      props.add('Unit Price: \$${product.pricePerItem}');
    }
    if (product.hourlyRate.isNotEmpty) {
      props.add('Hourly Rate: \$${product.hourlyRate}/h');
    }
    if (product.flatRate.isNotEmpty) {
      props.add('Flat Rate: \$${product.flatRate}');
    }
    if (product.quantity.isNotEmpty) {
      props.add('Quantity: ${product.quantity}');
    }

    return '${product.name}:\n- ${props.join('\n- ')}';
  }
}
