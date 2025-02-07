import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/const.dart';

import '../../Controllers/garage_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../Models/product_service_model.dart';
import 'add_product_nd_service.dart';

class AllProductAndServices extends StatefulWidget {
  final bool isFromMyProfile;
  const AllProductAndServices({super.key, this.isFromMyProfile = false});

  @override
  State<AllProductAndServices> createState() => _AllProductAndServicesState();
}

class _AllProductAndServicesState extends State<AllProductAndServices> {
  TextEditingController searchController = TextEditingController();
  List<ProductServiceModel> allProducts = [];
  List<ProductServiceModel> filteredProducts = []; // This is what we'll display
  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterProducts); // Add listener
  }

  void _filterProducts() {
    String query = searchController.text.toLowerCase();

    setState(() {
      if (query.isNotEmpty) {
        filteredProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.desc.toLowerCase().contains(query);
        }).toList();
      } else {
        filteredProducts = List.from(allProducts); // Show all when empty
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final GarageController garageController =
        Provider.of<GarageController>(context);

    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<ProductServiceModel>>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('serviceId', isEqualTo: userController.userModel!.userId)
                .orderBy('createdAt', descending: true)
                .snapshots()
                .map((s) => s.docs
                    .map((toElement) => ProductServiceModel.fromJson(toElement))
                    .toList()),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(
              //       child:
              //           CircularProgressIndicator()); // Show loading indicator
              // }

              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                    child: Text('Error: ${snapshot.error}')); // Handle errors
              }
              // List<ProductServiceModel> allProducts = [];
              allProducts =
                  snapshot.data ?? []; // Update allProducts from stream
              if (searchController.text.isEmpty) {
                filteredProducts = List.from(
                    allProducts); // Show all initially and when search is empty
              }
              allProducts = snapshot.data ?? [];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back_ios_new),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: searchController,
                            cursorColor: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            onChanged: (String value) {
                              _filterProducts(); // Call filterProducts
                            },
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(fontSize: 17),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: userController.isDark
                                      ? Colors.white
                                      : primaryColor,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(
                          () => AddProductNdService(productServiceModel: null));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                      minimumSize: Size(Get.width * 0.95, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(
                      'Add product or service',
                      style: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'All Products and Services',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(child: Text('No products or services found'))
                        : ListView.builder(
                            itemCount: filteredProducts.length,
                            padding: const EdgeInsets.all(10),
                            itemBuilder: (context, index) {
                              final ProductServiceModel product =
                                  filteredProducts[index];
                              bool isSelected = garageController.selected
                                  .any((selected) => selected.id == product.id);

                              return Card(
                                color: userController.isDark
                                    ? primaryColor
                                    : Colors.white,
                                child: SwipeActionCell(
                                  key: ObjectKey(product.id),
                                  backgroundColor: userController.isDark
                                      ? primaryColor
                                      : Colors.white,
                                  trailingActions: <SwipeAction>[
                                    SwipeAction(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                        ),
                                        onTap:
                                            (CompletionHandler handler) async {
                                          setState(() {});
                                          Get.to(() => AddProductNdService(
                                              productServiceModel: product));
                                        },
                                        color: Colors.green,
                                        backgroundRadius: 4.0),
                                    SwipeAction(
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.white,
                                        ),
                                        onTap:
                                            (CompletionHandler handler) async {
                                          await FirebaseFirestore.instance
                                              .collection('products')
                                              .doc(product.id)
                                              .delete();
                                          if (garageController.selected.any(
                                              (test) =>
                                                  test.id == product.id)) {
                                            garageController.select(product);
                                          }
                                          // Get.close(1);
                                        },
                                        color: Colors.red,
                                        backgroundRadius: 4.0),
                                  ],
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
                                        Text('\$${product.totalPrice}',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                        if (product.desc.isNotEmpty)
                                          Text(
                                            product.desc, // Show description
                                            style: TextStyle(fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          getServiceDetail(
                                              product), // Show service details
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                    trailing: widget.isFromMyProfile
                                        ? null
                                        : Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: isSelected
                                                ? Colors.green
                                                : null,
                                          ),
                                    onTap: widget.isFromMyProfile
                                        ? null
                                        : () {
                                            garageController.select(product);
                                          },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  String getServiceDetail(ProductServiceModel prod) {
    if (prod.index == 0) {
      return '\$${double.parse(prod.pricePerItem).toStringAsFixed(2)} x ${prod.quantity} units';
    } else if (prod.index == 1) {
      return '\$${prod.hourlyRate} x ${prod.hours} hours';
    } else {
      return '${prod.flatRate} ';
    }
  }
}
