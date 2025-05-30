import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';

import '../../providers/in_app_purchases_provider.dart';

class SubscriptionPlansPage extends StatefulWidget {
  final String title;
  const SubscriptionPlansPage({super.key, required this.title});

  @override
  _SubscriptionPlansPageState createState() => _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends State<SubscriptionPlansPage> {
  int _selectedIndex = 1; // Default to Pro
  bool _isYearly = true;
  PageController pageController =
      PageController(viewportFraction: 0.8, initialPage: 1);

  // @override
  // void dispose() {
  //   Provider.of<InAppPurchaseProvider>(context, listen: false).dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = Provider.of<InAppPurchaseProvider>(context);

    final plans = [
      {
        'title': 'Free',
        'productId': null,
        'monthly': 0.0,
        'yearly': 0.0,
        'features': [
          "1 Vehicle",
          "1 Active Request",
          "3 AI Questions / Day",
        ],
      },
      {
        'title': 'Premium Pro',
        'productId': _isYearly ? 'premium_pro_yearly' : 'premium_pro_monthly',
        'monthly': 4.99,
        'yearly': 49.99,
        'features': [
          "5 Vehicles",
          "3 Active Requests / Vehicle",
          "8 AI Questions / Day",
          "Priority Support",
        ],
      },
      {
        'title': 'Business',
        'productId':
            _isYearly ? 'premium_business_yearly' : 'premium_business_monthly',
        'monthly': 14.99,
        'yearly': 119.99,
        'features': [
          "Unlimited Vehicles",
          "Unlimited Requests",
          "Unlimited AI",
          "Priority Support",
        ],
      }
    ];

    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        // purchaseProvider.endConnection();
                        Get.close(1);
                        // purchaseProvider.checkForAppStoreInitiatedProducts();
                      },
                      icon: Icon(Icons.close)),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        Get.close(1);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.transparent,
                      )),
                ],
              ),
            ),
            SizedBox(height: 26),
            ToggleButtons(
              isSelected: [_isYearly == false, _isYearly == true],
              onPressed: (index) {
                setState(() {
                  _isYearly = index == 1;
                });
              },
              selectedBorderColor:
                  userController.isDark ? Colors.white : primaryColor,
              borderRadius: BorderRadius.circular(8),
              children: [
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Monthly")),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Yearly")),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(
              height: Get.height * 0.5,
              width: Get.width,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                // padding: EdgeInsets.all(16),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> plan = plans[_selectedIndex];
                  final isSelected = _selectedIndex == index;
                  final product = purchaseProvider.products.firstWhereOrNull(
                    (pro) => pro.productId == plan['productId'],
                  );

                  final price = product?.localizedPrice ?? "Free";
                  return InkWell(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      margin: EdgeInsets.only(
                          bottom: !isSelected ? 24 : 16,
                          top: !isSelected ? 24 : 16,
                          left: 10),
                      height: Get.height * 0.6,
                      width: Get.width * 0.8,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(plan['title'],
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          SizedBox(height: 10),
                          Text(
                            '$price${plan['productId'] != null ? (_isYearly ? " / yr" : " / mo") : ""}',
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          ...List.generate(
                            plan['features'].length,
                            (i) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 28),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      plan['features'][i],
                                      style: TextStyle(
                                          fontSize: 16, color: primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          if (isSelected &&
                              userController.userModel!.productId ==
                                  plan['productId'])
                            Column(
                              children: [
                                SizedBox(height: 12),
                                Text(
                                  'Already Subscribed',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 12),
                          if (isSelected &&
                              plan['productId'] != null &&
                              userController.userModel!.productId !=
                                  plan['productId'])
                            ElevatedButton(
                              onPressed: purchaseProvider.purchasePending
                                  ? null
                                  : () async {
                                      if (plan['productId'] != null) {
                                        final product = purchaseProvider
                                            .products
                                            .firstWhere(
                                          (p) =>
                                              p.productId == plan['productId'],
                                          orElse: () => throw Exception(
                                              "Product not found ${plan['productId']}"),
                                        );
                                        await purchaseProvider
                                            .buyProduct(product);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(Get.width * 0.8, 50),
                                maximumSize: Size(Get.width * 0.8, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                backgroundColor: primaryColor,
                              ),
                              child: purchaseProvider.purchasePending
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Text(
                                      plan['productId'] == null
                                          ? "Select"
                                          : "Buy Now",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
