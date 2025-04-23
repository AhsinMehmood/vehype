import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/product_service_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/loading_dialog.dart';
import 'package:vehype/const.dart';

import '../../Controllers/garage_controller.dart';

class AddProductNdService extends StatefulWidget {
  final ProductServiceModel? productServiceModel;
  const AddProductNdService({super.key, required this.productServiceModel});

  @override
  State<AddProductNdService> createState() => _AddProductNdServiceState();
}

class _AddProductNdServiceState extends State<AddProductNdService>
    with SingleTickerProviderStateMixin {
  bool isServiceOrProductSelected = false;
  late TabController tabController;
  // int tabIndex = 0;
  String pricePerItem = '';
  String quantity = '';
  String hourlyRate = '';
  String hours = '';
  String flatRate = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String totalPrice() {
    double price = 0.0;

    if (tabController.index == 0) {
      // Tab 0: Calculate price per item
      double itemPrice =
          pricePerItem.isNotEmpty ? double.parse(pricePerItem) : 0.0;
      double qty =
          quantity.isNotEmpty ? double.parse(quantity) : 1.0; // Default to 1
      price = itemPrice * qty;
    } else if (tabController.index == 1) {
      // Tab 1: Calculate hourly rate
      double rate = hourlyRate.isNotEmpty ? double.parse(hourlyRate) : 0.0;
      double hrs = hours.isNotEmpty ? double.parse(hours) : 1.0; // Default to 1
      price = rate * hrs;
    } else if (tabController.index == 2) {
      // Tab 2: Flat rate
      price = flatRate.isNotEmpty ? double.parse(flatRate) : 0.0;
    }

    return price.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    if (widget.productServiceModel != null) {
      tabController = TabController(
          length: 3,
          vsync: this,
          initialIndex: widget.productServiceModel!.index);
      pricePerItem = widget.productServiceModel!.pricePerItem;
      quantity = widget.productServiceModel!.quantity;
      hourlyRate = widget.productServiceModel!.hourlyRate;
      hours = widget.productServiceModel!.hours;
      flatRate = widget.productServiceModel!.flatRate;
      nameController =
          TextEditingController(text: widget.productServiceModel!.name);
      descriptionController =
          TextEditingController(text: widget.productServiceModel!.desc);
    } else {
      tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    }
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {
          // tabController.
          if (tabController.index == 0) {
            isServiceOrProductSelected = true;
          } else {
            isServiceOrProductSelected = false;
          }
        });
      }
    });
  }

  saveToFirestore() async {
    try {
      Get.dialog(LoadingDialog(), barrierDismissible: false);
      final UserController userController =
          Provider.of<UserController>(context, listen: false);
      final UserModel userModel = userController.userModel!;
      if (nameController.text.trim().isEmpty) {
        Get.close(1);

        Get.showSnackbar(GetSnackBar(
          message: 'Name cannot be empty',
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        ));

        return;
      }
      // Check for duplicate name
      QuerySnapshot<Map<String, dynamic>> existingProducts =
          await FirebaseFirestore.instance
              .collection('products')
              .where('serviceId', isEqualTo: userModel.userId)
              .where('name',
                  isEqualTo: nameController.text.trim()) // Direct filtering
              .get();

      if (existingProducts.docs.isNotEmpty &&
          widget.productServiceModel == null) {
        Get.close(1);
        Get.showSnackbar(GetSnackBar(
          message: 'A product with this name already exists!',
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        ));
        return;
      }
      // Auto-set '0.0' for empty fields based on the selected index
      if (tabController.index == 0) {
        pricePerItem = pricePerItem.isEmpty ? '0.0' : pricePerItem;
      } else if (tabController.index == 1) {
        hourlyRate = hourlyRate.isEmpty ? '0.0' : hourlyRate;
      } else if (tabController.index == 2) {
        flatRate = flatRate.isEmpty ? '0.0' : flatRate;
      }

      ProductServiceModel productServiceModel = ProductServiceModel(
          name: nameController.text.trim(),
          desc: descriptionController.text.trim(),
          totalPrice: totalPrice(),
          index: tabController.index,
          serviceId: userModel.userId,
          hourlyRate: hourlyRate,
          hours: hours,
          flatRate: flatRate,
          pricePerItem: pricePerItem,
          createdAt: widget.productServiceModel == null
              ? DateTime.now().toUtc().toIso8601String()
              : widget.productServiceModel!.createdAt,
          quantity: quantity,
          id: widget.productServiceModel == null
              ? ''
              : widget.productServiceModel!.id);
      if (widget.productServiceModel != null) {
        final GarageController garageController =
            Provider.of<GarageController>(context, listen: false);
        if (garageController.selected
            .any((product) => product.id == widget.productServiceModel!.id)) {
          log('Matched');
          // garageController.select(widget.productServiceModel!);
          garageController.updateProductAndSelection(
              productServiceModel, widget.productServiceModel!.id);
        }
        //  try {
        FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productServiceModel!.id)
            .update(productServiceModel.toJson());
        //  } catch (e) {

        //  }
        print(productServiceModel.desc);
      } else {
        print(productServiceModel.toJson());
        FirebaseFirestore.instance
            .collection('products')
            .add(productServiceModel.toJson());
      }

      Get.close(2);
    } catch (e) {
      Get.close(1);
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final GarageController garageController =
        Provider.of<GarageController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Get.close(1);
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          widget.productServiceModel == null
              ? 'Add Product or Service'
              : 'Update Product or Service',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.productServiceModel != null)
            IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(widget.productServiceModel!.id)
                      .delete();
                  if (garageController.selected.any(
                      (test) => test.id == widget.productServiceModel!.id)) {
                    garageController.select(widget.productServiceModel!);
                  }
                  Get.close(1);
                },
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                ))
        ],
      ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton:
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 0.5,
                      // color: Colors.transparent,
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isServiceOrProductSelected = false;
                                  tabController.animateTo(1);
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Service',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isServiceOrProductSelected == false)
                                    Icon(
                                      Icons.done,
                                      color: Colors.green,
                                    )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 1,
                              width: Get.width,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isServiceOrProductSelected = true;
                                  tabController.animateTo(0);
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Product',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isServiceOrProductSelected == true)
                                    Icon(
                                      Icons.done,
                                      color: Colors.green,
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Card(
                      elevation: 0.5,
                      // color: Colors.transparent,
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            TextFormField(
                              onTapOutside: (d) {
                                FocusScope.of(context).unfocus();
                              },
                              controller: nameController,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              inputFormatters: [
                                // Only numbers and one decimal
                                LengthLimitingTextInputFormatter(
                                    20), // Set max length to 10
                              ],
                              cursorColor: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              decoration: InputDecoration(
                                hintText: 'Name',
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor, // Default underline color
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor, // Underline color when focused
                                    width: 2.0, // Thickness of the underline
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              onTapOutside: (d) {
                                FocusScope.of(context).unfocus();
                              },
                              controller: descriptionController,
                              inputFormatters: [
                                // Only numbers and one decimal
                                LengthLimitingTextInputFormatter(
                                    25), // Set max length to 10
                              ],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                              cursorColor: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              decoration: InputDecoration(
                                hintText: 'Description (optional)',
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor, // Default underline color
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor, // Underline color when focused
                                    width: 2.0, // Thickness of the underline
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Card(
                      elevation: 0.5,
                      // color: Colors.transparent,
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              width: Get.width,
                              child: TabBar(
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  controller: tabController,
                                  indicatorColor: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  labelStyle: TextStyle(
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor),
                                  tabs: [
                                    Tab(
                                      text: 'QUANTITY',
                                    ),
                                    Tab(
                                      text: 'HOURLY',
                                    ),
                                    Tab(
                                      text: 'FLAT RATE',
                                    )
                                  ]),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 70,
                              width: Get.width,
                              child: TabBarView(
                                  controller: tabController,
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Price per item'),
                                              Text('Quantity'),
                                              const SizedBox(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '\$',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      pricePerItem = value;
                                                    });
                                                    print(pricePerItem);
                                                  },
                                                  onTapOutside: (d) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d*\.?\d*$')), // Only numbers and one decimal
                                                    LengthLimitingTextInputFormatter(
                                                        10), // Set max length to 10
                                                  ],
                                                  initialValue: pricePerItem,
                                                  cursorColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  decoration: InputDecoration(
                                                    hintText: '0.0',
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Default underline color
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Underline color when focused
                                                        width:
                                                            2.0, // Thickness of the underline
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              Text(
                                                'X',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  onTapOutside: (d) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  cursorColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      quantity = value;
                                                    });
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly, // Only allows whole numbers
                                                  ],
                                                  initialValue: quantity,
                                                  decoration: InputDecoration(
                                                    hintText: '0',
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Default underline color
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Underline color when focused
                                                        width:
                                                            2.0, // Thickness of the underline
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Hourly rate'),
                                              Text('Hours'),
                                              const SizedBox(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '\$',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                  onTapOutside: (d) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  cursorColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  initialValue: hourlyRate,
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      hourlyRate = value;
                                                    });
                                                  },
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d*\.?\d*$')), // Only numbers and one decimal
                                                    LengthLimitingTextInputFormatter(
                                                        10), // Set max length to 10
                                                  ],
                                                  decoration: InputDecoration(
                                                    hintText: '0.0',
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Default underline color
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Underline color when focused
                                                        width:
                                                            2.0, // Thickness of the underline
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              Text(
                                                'X',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  onTapOutside: (d) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  cursorColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  initialValue: hours,
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      hours = value;
                                                    });
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly, // Only allows whole numbers
                                                  ],
                                                  decoration: InputDecoration(
                                                    hintText: '0',
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Default underline color
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Underline color when focused
                                                        width:
                                                            2.0, // Thickness of the underline
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Rate'),
                                              const SizedBox(),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '\$',
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w800),
                                              ),
                                              Expanded(
                                                child: TextFormField(
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w800),
                                                  onTapOutside: (d) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  },
                                                  initialValue: flatRate,
                                                  onChanged: (String value) {
                                                    setState(() {
                                                      flatRate = value;
                                                    });
                                                  },
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                    decimal: true,
                                                  ),
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r'^\d*\.?\d*$')), // Only numbers and one decimal
                                                    LengthLimitingTextInputFormatter(
                                                        10), // Set max length to 10
                                                  ],
                                                  cursorColor:
                                                      userController.isDark
                                                          ? Colors.white
                                                          : primaryColor,
                                                  decoration: InputDecoration(
                                                    hintText: '0.0',
                                                    hintStyle: TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Default underline color
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: userController
                                                                .isDark
                                                            ? Colors.white
                                                            : primaryColor, // Underline color when focused
                                                        width:
                                                            2.0, // Thickness of the underline
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 30,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  '\$${totalPrice()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    InkWell(
                      onTap: () {
       
                        saveToFirestore();
                      },
                      child: Container(
                        height: 50,
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            widget.productServiceModel == null
                                ? 'Add'
                                : 'Update',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
