// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/Controllers/chat_controller.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/chat_model.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/product_service_model.dart';
import 'package:vehype/Pages/Invoice/all_product_and_services.dart';
import 'package:vehype/Widgets/login_sheet.dart';
// import 'package:vehype/Widgets/offer_request_details.dart';
import 'package:vehype/const.dart';

import '../Controllers/notification_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/user_model.dart';
import '../Pages/Invoice/add_product_nd_service.dart';
import 'loading_dialog.dart';
// import 'request_vehicle_details.dart';

class SelectDateAndPrice extends StatefulWidget {
  final OffersModel offersModel;
  final String? chatId;
  final UserModel ownerModel;
  final GarageModel garageModel;
  final bool isUpdateInvoice;
  final OffersReceivedModel? offersReceivedModel;
  const SelectDateAndPrice(
      {super.key,
      required this.offersModel,
      this.isUpdateInvoice = false,
      required this.garageModel,
      this.chatId,
      required this.ownerModel,
      required this.offersReceivedModel});

  @override
  State<SelectDateAndPrice> createState() => _SelectDateAndPriceState();
}

class _SelectDateAndPriceState extends State<SelectDateAndPrice>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  TextEditingController comment = TextEditingController();
  TextEditingController priceController = TextEditingController();

  bool isFirstTime = false;
  late SwipeActionController swipeActionController;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    openCell();
    swipeActionController = SwipeActionController();

    if (widget.offersReceivedModel != null) {
      final GarageController garageController =
          Provider.of<GarageController>(context, listen: false);
      garageController.agreement = true;

      // garageController.selected =
      // initProducts(widget.offersReceivedModel!.ids);
      randomId = widget.offersReceivedModel!.randomId;

      comment =
          TextEditingController(text: widget.offersReceivedModel!.comment);

      priceController = TextEditingController(
          text: widget.offersReceivedModel!.price.toString());
      garageController.selected = widget.offersReceivedModel!.products;
    } else {
      randomId = generateFourDigitId();
    }

    setState(() {});
  }

  openCell() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isFirstTime = sharedPreferences.getBool('firstTimeUpdate') ?? false;
    if (!isFirstTime) {
      Future.delayed(Duration(seconds: 1)).then((s) {
        swipeActionController.openCellAt(index: 0, trailing: true);
      });
      Future.delayed(Duration(seconds: 3)).then((s) {
        sharedPreferences.setBool('firstTimeUpdate', true);

        if (!isFirstTime) {
          swipeActionController.closeAllOpenCell();
        }
      });
    }
  }

  bool showPriceWarning = false;
  String randomId = '';

  String generateFourDigitId() {
    Random random = Random();
    return List.generate(4, (_) => random.nextInt(10)).join();
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    UserModel userModel = userController.userModel!;
    final GarageController garageController =
        Provider.of<GarageController>(context);
    List<ProductServiceModel> prodcuts = garageController.selected;
    return WillPopScope(
      onWillPop: () async {
        garageController.disposeController();
        await Future.delayed(Duration(milliseconds: 100));

        return true;
      },
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          leading: IconButton(
              onPressed: () async {
                garageController.disposeController();
                await Future.delayed(Duration(milliseconds: 100));
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          title: Text(
            widget.offersReceivedModel != null
                ? 'Update Estimate #$randomId'
                : 'Estimate #$randomId',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Card(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        margin: const EdgeInsets.all(6),
                        // color:
                        //     userController.isDark ? primaryColor : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.ownerModel.name,
                                    style: TextStyle(
                                      // color: Colors.black,

                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      placeholder: (context, url) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorWidget: (context, url, error) =>
                                          const SizedBox.shrink(),
                                      imageUrl: widget.garageModel.imageUrl,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.garageModel.title,
                                          maxLines: 2,
                                          style: TextStyle(
                                            // color: Colors.black,

                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                getServices()
                                                    .firstWhere((element) =>
                                                        element.name ==
                                                        widget
                                                            .offersModel.issue)
                                                    .image,
                                                color: userController.isDark
                                                    ? Colors.white
                                                    : primaryColor,
                                                height: 25,
                                                width: 25),
                                            const SizedBox(
                                              width: 3,
                                            ),
                                            Text(
                                              ' ',
                                              style: TextStyle(
                                                // color: Colors.black,

                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              widget.offersModel.issue,
                                              style: TextStyle(
                                                // color: Colors.black,

                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (prodcuts.isNotEmpty)
                        Card(
                          elevation: 0.5,
                          color: userController.isDark
                              ? primaryColor
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.all(0),
                            childrenPadding: const EdgeInsets.all(0),
                            iconColor: userController.isDark
                                ? Colors.white
                                : primaryColor,

                            initiallyExpanded:
                                true, // You can set this to false if you want it collapsed by default
                            title: Text(
                              'Product or Service (${prodcuts.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              if (prodcuts.isNotEmpty)
                                ListView.builder(
                                  itemCount: prodcuts.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final ProductServiceModel product =
                                        prodcuts[index];

                                    return Card(
                                      elevation: 0.5,
                                      color: userController.isDark
                                          ? primaryColor
                                          : Colors.white,
                                      child: SwipeActionCell(
                                        key: ObjectKey(product.id),
                                        controller: swipeActionController,
                                        backgroundColor: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        trailingActions: <SwipeAction>[
                                          SwipeAction(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                              onTap: (CompletionHandler
                                                  handler) async {
                                                setState(() {});
                                                Get.to(() =>
                                                    AddProductNdService(
                                                        productServiceModel:
                                                            product));
                                              },
                                              color: Colors.green,
                                              backgroundRadius: 4.0),
                                          SwipeAction(
                                              icon: Icon(
                                                Icons.delete_forever,
                                                color: Colors.white,
                                              ),
                                              onTap: (CompletionHandler
                                                  handler) async {
                                                garageController
                                                    .select(product);

                                                // Get.close(1);
                                              },
                                              color: Colors.red,
                                              backgroundRadius: 4.0),
                                        ],
                                        index: index,
                                        child: ListTile(
                                          title: Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (product.desc.isNotEmpty)
                                                Text(
                                                  product
                                                      .desc, // Show description
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                getServiceDetail(
                                                    product), // Show service details
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          isThreeLine: true,
                                          trailing: Column(
                                            children: [
                                              Text('\$${product.totalPrice}',
                                                  style: TextStyle(
                                                      color:
                                                          userController.isDark
                                                              ? Colors.white
                                                              : primaryColor,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            swipeActionController.openCellAt(
                                                index: index, trailing: true);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      Card(
                        elevation: 0.5,
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            Get.to(() => AllProductAndServices());
                          },
                          child: Row(
                            children: [
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  Get.to(() => AllProductAndServices());
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Add product or service',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(getTotal(garageController),
                                style: TextStyle(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          garageController.changeAgree();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Transform.scale(
                            //   scale: 1.8,
                            //   child: Checkbox(
                            //       activeColor: userController.isDark
                            //           ? Colors.white
                            //           : primaryColor,
                            //       checkColor: userController.isDark
                            //           ? Colors.green
                            //           : Colors.white,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(4),
                            //       ),
                            //       value: garageController.agreement,
                            //       onChanged: (s) {
                            //         garageController.changeAgree();
                            //         // appProvider.selectPrefs(pref);
                            //       }),
                            // ),
                            // const SizedBox(
                            //   width: 3,
                            // ),
                            // Expanded(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       RichText(
                            //         text: TextSpan(
                            //           children: [
                            //             TextSpan(
                            //               text:
                            //                   'I acknowledge VEHYPE\'s ratings policy. ',
                            //               style: TextStyle(
                            //                   // fontFamily: 'Avenir',
                            //                   fontWeight: FontWeight.w400,
                            //                   fontSize: 16,
                            //                   color: userController.isDark
                            //                       ? Colors.white
                            //                       : primaryColor
                            //                   //  color: Colors.black,
                            //                   ),
                            //             ),
                            //             TextSpan(
                            //               text: 'See how rating works',
                            //               style: TextStyle(
                            //                 fontFamily: 'Avenir',
                            //                 decorationColor: Colors.blueAccent,
                            //                 fontWeight: FontWeight.w400,
                            //                 fontSize: 16,
                            //                 color: Colors.blueAccent,
                            //                 decoration:
                            //                     TextDecoration.underline,
                            //               ),
                            //               recognizer: TapGestureRecognizer()
                            //                 ..onTap = () async {
                            //                   await launchUrl(Uri.parse(
                            //                       'https://vehype.com/help#'));
                            //                 },
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //       const SizedBox(
                            //         height: 5,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (garageController.selected.isEmpty) {
                            Get.showSnackbar(GetSnackBar(
                              message:
                                  "Please add at least one product or service.",
                              snackPosition: SnackPosition.TOP,
                              duration: Duration(seconds: 3),
                            ));
                            return;
                          }
                          Get.bottomSheet(
                              BottomSheet(
                                  onClosing: () {},
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                      maxHeight: Get.height * 0.9),
                                  builder: (s) {
                                    return Container(
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: userController.isDark
                                            ? primaryColor
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                            "VEHYPE Terms of Use",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 12),
                                                  const SizedBox(height: 8),
                                                  _buildSectionTitle(
                                                      "1. Nature of the Platform"),
                                                  _buildBulletPoint(
                                                      "VEHYPE provides a digital marketplace for users to discover and communicate with independent automotive service providers."),
                                                  _buildBulletPoint(
                                                      "VEHYPE is not a service provider and does not supervise, guarantee, or take responsibility for services rendered."),
                                                  _buildBulletPoint(
                                                      "All service providers are independent parties. They are not employees, agents, or representatives of VEHYPE."),
                                                  _buildSectionTitle(
                                                      "2. User Responsibilities"),
                                                  _buildBulletPoint(
                                                      "Users are responsible for verifying the credentials, documentation, and insurance of any provider before agreeing to services."),
                                                  _buildBulletPoint(
                                                      "All interactions with providers occur at the user's discretion."),
                                                  _buildBulletPoint(
                                                      "VEHYPE recommends that users only engage with certified providers, who have insurance and documentation on file."),
                                                  _buildSectionTitle(
                                                      "3. Provider Responsibilities"),
                                                  _buildBulletPoint(
                                                      "Providers must agree to VEHYPE’s Code of Conduct and Service Quality Standards at registration."),
                                                  _buildBulletPoint(
                                                      "Certified providers are required to maintain active insurance documentation."),
                                                  _buildBulletPoint(
                                                      "Non-certified providers must upload valid government-issued identification and have a limited period to become certified."),
                                                  _buildBulletPoint(
                                                      "Non-certified providers failing to meet certification requirements may face account suspension."),
                                                  _buildSectionTitle(
                                                      "4. Payments and Subscriptions"),
                                                  _buildBulletPoint(
                                                      "VEHYPE does not facilitate or process payments for services. All financial transactions occur directly between users and providers."),
                                                  _buildBulletPoint(
                                                      "VEHYPE does not collect a commission. Instead, service providers subscribe to the platform via a monthly subscription fee."),
                                                  _buildBulletPoint(
                                                      "VEHYPE is not responsible for payment disputes, missed appointments, or cancellations. A community rating system is used to monitor service quality."),
                                                  _buildSectionTitle(
                                                      "5. Disputes and Reporting"),
                                                  _buildBulletPoint(
                                                      "Users and providers can report issues using VEHYPE’s in-app report feature."),
                                                  _buildBulletPoint(
                                                      "VEHYPE will investigate reported issues and provide supporting documentation when necessary."),
                                                  _buildBulletPoint(
                                                      "VEHYPE will not be liable for any service disputes. Users are encouraged to document all agreements and service terms independently."),
                                                  _buildSectionTitle(
                                                      "6. Communication and Moderation"),
                                                  _buildBulletPoint(
                                                      "VEHYPE provides an internal messaging system to facilitate user-provider communication."),
                                                  _buildBulletPoint(
                                                      "Messages may be flagged and reviewed if reported."),
                                                  _buildBulletPoint(
                                                      "VEHYPE does not tolerate harassment, fraud, or misuse of the communication system."),
                                                  _buildSectionTitle(
                                                      "7. Privacy and Data Protection"),
                                                  _buildBulletPoint(
                                                      "Access control via a secured SHA-256 authentication system."),
                                                  _buildBulletPoint(
                                                      "Encrypted storage for all user and vehicle data."),
                                                  _buildBulletPoint(
                                                      "Role-based permissions for backend operations."),
                                                  _buildBulletPoint(
                                                      "Location privacy protection (data is temporary and not permanently stored unless needed)."),
                                                  _buildBulletPoint(
                                                      "Use of HTTPS, rate limiting, and activity monitoring."),
                                                  _buildSectionTitle(
                                                      "8. Service Documentation and History"),
                                                  _buildBulletPoint(
                                                      "Providers must issue an estimate when offering a service. Upon completion, this estimate becomes an invoice."),
                                                  _buildBulletPoint(
                                                      "All invoices are saved to the repair history of both user and provider accounts and can be sent via email."),
                                                  _buildSectionTitle(
                                                      "9. Legal Disclaimer"),
                                                  _buildBulletPoint(
                                                      "VEHYPE is not responsible for the quality, legality, or safety of any service. All services are offered and accepted at the user’s own risk. VEHYPE's role is limited to facilitating discovery and communication."),
                                                  _buildBulletPoint(
                                                      "To the fullest extent permitted by law, no user shall bring any legal action or claim against VEHYPE for any property damage, physical injury, or financial loss resulting from use of the platform or services arranged through it."),
                                                  _buildBulletPoint(
                                                      "By using VEHYPE, all users agree that they are acting at their own risk and discretion."),
                                                  const SizedBox(height: 24),
                                                  const Text(
                                                    "By using VEHYPE, you acknowledge and accept these Terms of Use. These terms may be updated at any time. Continued use of the platform constitutes acceptance of any modifications.",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const SizedBox(height: 40),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Get.close(1);
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: Get.width * 0.42,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor,
                                                      )),
                                                  child: Center(
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Get.close(1);

                                                  if (userModel.isGuest) {
                                                    Get.bottomSheet(LoginSheet(
                                                        onSuccess: () {
                                                      applyToJob(
                                                          userModel,
                                                          garageController,
                                                          comment.text.trim());
                                                    }));
                                                  } else {
                                                    applyToJob(
                                                        userModel,
                                                        garageController,
                                                        comment.text);
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  elevation: 1.0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  maximumSize: Size(
                                                      Get.width * 0.42, 50),
                                                  minimumSize: Size(
                                                      Get.width * 0.42, 50),
                                                ),
                                                child: Text(
                                                  'Send',
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    color: userController.isDark
                                                        ? primaryColor
                                                        : Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    );
                                  }),
                              isScrollControlled: true);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            elevation: 0.0,
                            fixedSize: Size(Get.width * 0.9, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            )),
                        child: Text(
                          widget.offersReceivedModel == null
                              ? 'Send'
                              : 'Update',
                          style: TextStyle(
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTotal(GarageController garageController) {
    double total = 0.0;

    List<ProductServiceModel> prodcuts = garageController.selected;

    for (var element in prodcuts) {
      total += double.tryParse(element.totalPrice) ?? 0.0;
    }

    return '\$${total.toStringAsFixed(2)}';
  }

  String getTotal2(GarageController garageController) {
    double total = 0.0;

    List<ProductServiceModel> prodcuts = garageController.selected;

    for (var element in prodcuts) {
      total += double.tryParse(element.totalPrice) ?? 0.0;
    }

    return total.toStringAsFixed(2);
  }

  String getServiceDetail(ProductServiceModel prod) {
    if (prod.index == 0) {
      return '\$${double.parse(prod.pricePerItem).toStringAsFixed(2)} x ${prod.quantity} units';
    } else if (prod.index == 1) {
      return '\$${prod.hourlyRate} x ${prod.hours} hours';
    } else {
      return '\$${prod.flatRate}';
    }
  }

  applyToJob(UserModel userModel, GarageController garageController,
      String comment) async {
    Get.dialog(LoadingDialog(), barrierDismissible: false);
    try {
      UserController userController =
          Provider.of<UserController>(context, listen: false);
      // Use a default valid ID if needed
      final documentId = widget.offersReceivedModel?.id ?? 'defaultId';
      if (documentId != 'defaultId') {
        await FirebaseFirestore.instance
            .collection('offersReceived')
            .doc(documentId)
            .update({
          'price': getTotal2(garageController),

          'products': garageController.selected
              .map((toElement) => toElement.toJson())
              .toList(),
          // 'randomId': randomId,
          // 'comment': comment.text,
        });
        DocumentSnapshot<Map<String, dynamic>> ownerSnap =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.offersReceivedModel!.ownerId)
                .get();

        NotificationController().sendNotification(
            userIds: [UserModel.fromJson(ownerSnap).userId],
            offerId: widget.offersModel.offerId,
            requestId: widget.offersReceivedModel!.id,
            title: 'Service Estimate Updated',
            subtitle:
                '${userModel.name} has updated their estimate for your request. Review the new details to see the changes made just for you.');

        OffersController().updateNotificationForOffers(
            offerId: widget.offersModel.offerId,
            userId: widget.ownerModel.userId,
            senderId: userController.userModel!.userId,
            isAdd: true,
            offersReceived: widget.offersReceivedModel!.id,
            checkByList: widget.offersModel.checkByList,
            notificationTitle: '${userModel.name} updated his invoice.',
            notificationSubtitle:
                '${userModel.name} has updated their estimate for your request. Review the new details to see the changes made just for you.');
        // ChatController().updateChatRequestId(widget.chatId!, widget.offersModel.offerId);
        ChatModel? chatModel = await ChatController().getChat(userModel.userId,
            widget.ownerModel.userId, widget.offersModel.offerId);
        if (chatModel != null) {
          ChatController().updateChatRequestId(
              chatModel.id, widget.offersReceivedModel!.id);
        }
        Get.close(2);
        garageController.disposeController();

        // if (widget.isUpdateInvoice) {
        //   Get.to(() => ReviewShareInvoice(
        //       secondUser: widget.ownerModel,
        //       offersModel: widget.offersModel,
        //       offersReceivedId: widget.offersReceivedModel!.id));
        //   // return;
        // }
      } else {
        await FirebaseFirestore.instance
            .collection('offers')
            .doc(widget.offersModel.offerId)
            .update({
          'offersReceived': FieldValue.arrayUnion([userModel.userId]),
        });

        DocumentReference<Map<String, dynamic>> reference =
            await FirebaseFirestore.instance.collection('offersReceived').add({
          'offerBy': userModel.userId,
          'offerId': widget.offersModel.offerId,
          'ownerId': widget.ownerModel.userId,
          'offerAt': DateTime.now().toUtc().toIso8601String(),
          'status': 'Pending',
          'price': getTotal2(garageController),

          'randomId': randomId,
          'createdAt': DateTime.now().toUtc().toIso8601String(),

          'products': garageController.selected
              .map((toElement) => toElement.toJson())
              .toList(),
          // 'startDate': garageController.startDate!.toUtc().toIso8601String(),
          // 'endDate': garageController.endDate?.toUtc().toIso8601String(),
          // 'comment': comment.text,
        });
        // DocumentSnapshot<Map<String, dynamic>> ownerSnap =
        //     await FirebaseFirestore.instance
        //         .collection('users')
        //         .doc(widget.offersModel.ownerId)
        //         .get();

        NotificationController().sendNotification(
            userIds: [widget.offersModel.ownerId],
            offerId: widget.offersModel.offerId,
            requestId: reference.id,
            title: 'New Offer for Your Request',
            subtitle:
                '${userModel.name} has submitted an offer in response to your request. Click here to review and respond.');
        OffersController().updateNotificationForOffers(
            offerId: widget.offersModel.offerId,
            userId: widget.ownerModel.userId,
            senderId: userController.userModel!.userId,
            isAdd: true,
            offersReceived: reference.id,
            checkByList: widget.offersModel.checkByList,
            notificationTitle: '${userModel.name} has submitted an offer.',
            notificationSubtitle:
                '${userModel.name} has submitted an offer in response to your request. Click here to review and respond.');
        ChatModel? chatModel = await ChatController().getChat(userModel.userId,
            widget.ownerModel.userId, widget.offersModel.offerId);
        String chatId = chatModel?.id ?? 'defaultId';
        if (chatId != 'defaultId') {
          ChatController().updateChatRequestId(chatId, reference.id);
        }
        garageController.disposeController();

        // if (widget.chatId != null) {
        Get.close(3);
        // } else {

        // }

        // Get.showSnackbar(
        //   GetSnackBar(
        //     message: 'Submitted successfully. Check Orders history for status',
        //     duration: Duration(seconds: 3),
        //   ),
        // );
      }
    } catch (e) {
      Get.close(1);

      print(e.toString());
    }
  }
}

String formatDateTime(DateTime dateTime) {
  DateFormat format = DateFormat.yMMMMd().add_jm();

  String dateString = format.format(dateTime.toLocal());

  return dateString;
}

String formatDate(DateTime dateTime) {
  DateFormat format = DateFormat.yMMMMd();
//  -> July 10, 2024 5:08 PM
  String dateString = format.format(dateTime.toLocal());

  return dateString;
}
