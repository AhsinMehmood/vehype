import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehype/const.dart';
import '../../Controllers/garage_controller.dart';
import '../../Controllers/user_controller.dart';
import '../../Models/product_service_model.dart';
import '../../Widgets/owner_offer_received_new_widget.dart';
import 'add_product_nd_service.dart';
class TextIconToAdd extends StatelessWidget {
  const TextIconToAdd({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          elevation: 4.5,
          margin: const EdgeInsets.all(12),
          color: userController.isDark ? Colors.white : primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: SizedBox(
            width: Get.width * 0.85,
            child: InkWell(
              borderRadius: BorderRadius.circular(2),
              onTap: () {
                Get.to(() => AddProductNdService(productServiceModel: null));
              },
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Get.to(
                          () => AddProductNdService(productServiceModel: null));
                    },
                    icon: Icon(
                      Icons.add,
                      // size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Add new product or service',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class OnlyIconToAdd extends StatelessWidget {
  const OnlyIconToAdd({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Card(
          elevation: 0.0,
          margin: const EdgeInsets.all(12),
          color: userController.isDark ? primaryColor : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              Get.to(() => AddProductNdService(productServiceModel: null));
            },
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200),
                  ),
                  color: Colors.green,
                  child: Icon(
                    Icons.add,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                // Text(
                //   'Add new product or service',
                //   style: TextStyle(
                //     fontWeight: FontWeight.w700,
                //     fontSize: 16,
                //   ),
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class AllProductAndServices extends StatefulWidget {
  final bool isFromMyProfile;
  const AllProductAndServices({super.key, this.isFromMyProfile = false});

  @override
  State<AllProductAndServices> createState() => _AllProductAndServicesState();
}
class _AllProductAndServicesState extends State<AllProductAndServices>
    with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  List<ProductServiceModel> allProducts = [];
  List<ProductServiceModel> filteredProducts = [];
  List<ProductServiceModel> selectedProducts = [];

  late SwipeActionController swipeActionController;
  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterProducts);
    swipeActionController = SwipeActionController();
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!widget.isFromMyProfile && garageController.selected.isNotEmpty)
            OnlyIconToAdd(),
          if (!widget.isFromMyProfile && garageController.selected.isEmpty)
            TextIconToAdd(),
          if (widget.isFromMyProfile) TextIconToAdd(),
          if (!widget.isFromMyProfile && garageController.selected.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                // Get.to(() => AddProductNdService(productServiceModel: null));
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    userController.isDark ? Colors.white : primaryColor,
                minimumSize: Size(Get.width * 0.9, 50),
                maximumSize: Size(Get.width * 0.9, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Add to estimate',
                    style: TextStyle(
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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

                              return ProductOrServiceCard(
                                  product: product,
                                  swipeActionController: swipeActionController,
                                  index: index,
                                  isFromMyProfile: widget.isFromMyProfile);
                            },
                          ),
                  ),
                  const SizedBox(height: 80),
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
      return '\$${prod.flatRate}';
    }
  }
}
class ProductOrServiceCard extends StatefulWidget {
  final bool isFromMyProfile;
  final ProductServiceModel product;
  final int index;
  final SwipeActionController swipeActionController;
  const ProductOrServiceCard(
      {super.key,
      required this.isFromMyProfile,
      required this.swipeActionController,
      required this.product,
      required this.index});

  @override
  State<ProductOrServiceCard> createState() => _ProductOrServiceCardState();
}
class _ProductOrServiceCardState extends State<ProductOrServiceCard> {
  @override
  void initState() {
    super.initState();
    openCell();
    // setState(() {});
  }

  openCell() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isFirstTime = sharedPreferences.getBool('firstTime') ?? false;
    if (!isFirstTime) {
      Future.delayed(Duration(seconds: 1)).then((s) {
        widget.swipeActionController.openCellAt(index: 0, trailing: true);
      });
      Future.delayed(Duration(seconds: 3)).then((s) {
        sharedPreferences.setBool('firstTime', true);

        if (!isFirstTime) {
          widget.swipeActionController.closeAllOpenCell();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final GarageController garageController =
        Provider.of<GarageController>(context);
    bool isSelected = garageController.selected
        .any((selected) => selected.id == widget.product.id);

    return InkWell(
      child: Card(
        color: userController.isDark ? primaryColor : Colors.white,
        child: SwipeActionCell(
          key: ObjectKey(widget.product.id),
          controller: widget.swipeActionController,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          trailingActions: <SwipeAction>[
            SwipeAction(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onTap: (CompletionHandler handler) async {
                  setState(() {});
                  Get.to(() =>
                      AddProductNdService(productServiceModel: widget.product));
                },
                color: Colors.green,
                backgroundRadius: 4.0),
            SwipeAction(
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                ),
                onTap: (CompletionHandler handler) async {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(widget.product.id)
                      .delete();
                  if (garageController.selected
                      .any((test) => test.id == widget.product.id)) {
                    garageController.select(widget.product);
                  }
                  // Get.close(1);
                },
                color: Colors.red,
                backgroundRadius: 4.0),
          ],
          index: widget.index,
          child: Stack(
            children: [
              ListTile(
                title: Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${widget.product.totalPrice}',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    if (widget.product.desc.isNotEmpty)
                      Text(
                        widget.product.desc, // Show description
                        style: TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      getServiceDetail(widget.product), // Show service details
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                        color: isSelected ? Colors.green : null,
                      ),
                onTap: widget.isFromMyProfile
                    ? () {
                        widget.swipeActionController
                            .openCellAt(index: widget.index, trailing: true);
                      }
                    : () {
                        garageController.select(widget.product);
                      },
              ),
              // if (widget.index == 0)
              // if (_showSwipeTutorial)
              //   Positioned(
              //     right: 0,
              //     child: AnimatedBuilder(
              //       animation: _animationController,
              //       builder: (context, child) {
              //         return Transform.translate(
              //           offset: Offset(-20 * _animationController.value, 0),
              //           child: Opacity(
              //             opacity: 1 - _animationController.value,
              //             child: Icon(
              //               Icons.arrow_back,
              //               color: Colors.grey.withOpacity(0.5),
              //             ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}