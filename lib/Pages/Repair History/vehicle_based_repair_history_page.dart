import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/offers_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Controllers/vehicle_data.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/offers_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Pages/Repair%20History/repair_widget.dart';
import 'package:vehype/const.dart';

import '../../Controllers/offers_provider.dart';
import '../../Widgets/owner_request_widget.dart';
import '../../Widgets/select_date_and_price.dart';

class VehicleBasedRepairHistoryPage extends StatefulWidget {
  final GarageModel garageModel;
  const VehicleBasedRepairHistoryPage({super.key, required this.garageModel});

  @override
  State<VehicleBasedRepairHistoryPage> createState() =>
      _VehicleBasedRepairHistoryPageState();
}

class _VehicleBasedRepairHistoryPageState
    extends State<VehicleBasedRepairHistoryPage> {
  late Future<List<OfferWithReceived>> _futureOffers;
  List<OfferWithReceived> _offers = [];
  List<OfferWithReceived> _filteredOffers = [];

  List<String> _selectedServiceTypes = [];

  @override
  void initState() {
    super.initState();
    _futureOffers = _fetchOffers(); // Initial fetch
  }

  Future<List<OfferWithReceived>> _fetchOffers() async {
    final offers = await getAllOffers(); // Fetch data
    setState(() {
      _offers = offers;
      _sortAndFilterOffers();
    });
    return offers;
  }

  Future<List<OfferWithReceived>> getAllOffers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Fetch all inactive offers for the given garageId
      QuerySnapshot<Map<String, dynamic>> offersSnapshot = await firestore
          .collection('offers')
          .where('garageId', isEqualTo: widget.garageModel.garageId)
          .where('status', isEqualTo: 'inactive')
          .get();

      List<OffersModel> offersList = [];
      List<String> offerIds = [];

      // Extract offers and offerIds
      for (var doc in offersSnapshot.docs) {
        OffersModel offer = OffersModel.fromJson(doc);
        offersList.add(offer);
        offerIds.add(offer.offerId);
      }

      print('Fetched ${offersList.length} offers.');

      // If no offers, return early
      if (offerIds.isEmpty) return [];

      // Step 2: Fetch all completed offersReceived where offerId is in offerIds
      QuerySnapshot<Map<String, dynamic>> receivedSnapshot = await firestore
          .collection('offersReceived')
          .where('offerId', whereIn: offerIds)
          .where('status', isEqualTo: 'Completed')
          .get();

      print(
          'Fetched ${receivedSnapshot.docs.length} completed offersReceived.');

      // Step 3: Create a mapping of offerId -> OffersReceivedModel
      Map<String, OffersReceivedModel> receivedMap = {
        for (var doc in receivedSnapshot.docs)
          doc.data()['offerId']: OffersReceivedModel.fromJson(doc),
      };

      // Step 4: Pair each offer with its corresponding offerReceived
      List<OfferWithReceived> pairedOffers = [];
      for (var offer in offersList) {
        if (receivedMap.containsKey(offer.offerId)) {
          pairedOffers.add(OfferWithReceived(
            offer: offer,
            offerReceived: receivedMap[offer.offerId]!,
          ));
        }
      }

      print('Final paired offers count: ${pairedOffers.length}');
      return pairedOffers;
    } catch (e) {
      print("Error fetching offers: $e");
      return [];
    }
  }

  void _sortAndFilterOffers() {
    List<OfferWithReceived> tempOffers = [..._offers];

    // Apply service type filtering
    if (_selectedServiceTypes.isNotEmpty) {
      tempOffers = tempOffers
          .where((offer) => _selectedServiceTypes.contains(offer.offer.issue))
          .toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Date Created':
        tempOffers
            .sort((a, b) => a.offer.createdAt.compareTo(b.offer.createdAt));
        break;
      case 'Date Completed':
        tempOffers.sort((a, b) =>
            a.offerReceived.completedAt.compareTo(b.offerReceived.completedAt));
        break;
      case 'Price: Low to High':
        tempOffers.sort((a, b) => double.parse(a.offerReceived.price)
            .compareTo(double.parse(b.offerReceived.price)));
        break;
      case 'Price: High to Low':
        tempOffers.sort((a, b) => double.parse(b.offerReceived.price)
            .compareTo(double.parse(a.offerReceived.price)));
        break;
    }

    setState(() {
      _filteredOffers = tempOffers;
    });
  }

  void _toggleServiceSelection(String serviceType) {
    setState(() {
      if (_selectedServiceTypes.contains(serviceType)) {
        _selectedServiceTypes.remove(serviceType);
      } else {
        _selectedServiceTypes.add(serviceType);
      }
      _sortAndFilterOffers();
    });
  }

  String _selectedSort = 'Date Created';

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;

    //  offersController.
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      // appBar: AppBar(
      //   backgroundColor: userController.isDark ? primaryColor : Colors.white,
      //   title: Text(
      //     'Repair History',
      //     style: TextStyle(
      //       fontWeight: FontWeight.w700,
      //       fontSize: 17,
      //       color: userController.isDark ? Colors.white : primaryColor,
      //     ),
      //   ),
      //   centerTitle: true,
      //   leading: IconButton(
      //     onPressed: () => Get.back(),
      //     icon: Icon(Icons.arrow_back_ios_new_outlined),
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Row(
      //         children: [
      //           // ✅ Sort Icon with Indicator
      //           Stack(
      //             children: [
      //               PopupMenuButton<String>(
      //                 color:
      //                     userController.isDark ? primaryColor : Colors.white,
      //                 elevation: 62,
      //                 icon: Icon(
      //                   Icons.sort,
      //                   color:
      //                       userController.isDark ? Colors.white : primaryColor,
      //                 ), // Sort Icon
      //                 onSelected: (value) {
      //                   setState(() {
      //                     _selectedSort = value;
      //                     _sortAndFilterOffers();
      //                   });
      //                 },
      //                 itemBuilder: (context) => [
      //                   PopupMenuItem(
      //                       value: 'Date Created',
      //                       child: Text(
      //                         'Date Created',
      //                         style: TextStyle(
      //                           // fontWeight: FontWeight.w700,
      //                           // fontSize: 17,
      //                           color: userController.isDark
      //                               ? Colors.white
      //                               : primaryColor,
      //                         ),
      //                       )),
      //                   PopupMenuItem(
      //                       value: 'Date Completed',
      //                       child: Text(
      //                         'Date Completed',
      //                         style: TextStyle(
      //                           // fontWeight: FontWeight.w700,
      //                           // fontSize: 17,
      //                           color: userController.isDark
      //                               ? Colors.white
      //                               : primaryColor,
      //                         ),
      //                       )),
      //                   PopupMenuItem(
      //                       value: 'Price: Low to High',
      //                       child: Text(
      //                         'Price: Low to High',
      //                         style: TextStyle(
      //                           // fontWeight: FontWeight.w700,
      //                           // fontSize: 17,
      //                           color: userController.isDark
      //                               ? Colors.white
      //                               : primaryColor,
      //                         ),
      //                       )),
      //                   PopupMenuItem(
      //                       value: 'Price: High to Low',
      //                       child: Text(
      //                         'Price: High to Low',
      //                         style: TextStyle(
      //                           // fontWeight: FontWeight.w700,
      //                           // fontSize: 17,
      //                           color: userController.isDark
      //                               ? Colors.white
      //                               : primaryColor,
      //                         ),
      //                       )),
      //                 ],
      //               ),
      //               if (_selectedSort !=
      //                   'Date Created') // Show dot if sort is applied
      //                 Positioned(
      //                   right: 6,
      //                   top: 6,
      //                   child: CircleAvatar(
      //                     radius: 4,
      //                     backgroundColor: Colors.red, // Indicator color
      //                   ),
      //                 ),
      //             ],
      //           ),

      //           SizedBox(width: 10),

      //           // ✅ Filter Icon with Count Indicator
      //           InkWell(
      //             onTap: () => _showFilterDialog(getServices(), userController),
      //             child: Stack(
      //               children: [
      //                 IconButton(
      //                   color:
      //                       userController.isDark ? Colors.white : primaryColor,
      //                   icon: Icon(
      //                     Icons.filter_list,
      //                   ),
      //                   onPressed: () =>
      //                       _showFilterDialog(getServices(), userController),
      //                 ),
      //                 if (_selectedServiceTypes
      //                     .isNotEmpty) // Show count if filters are selected
      //                   Positioned(
      //                     right: 6,
      //                     top: 6,
      //                     child: CircleAvatar(
      //                       radius: 9,
      //                       backgroundColor: Colors.red, // Indicator color
      //                       child: Text(
      //                         '${_selectedServiceTypes.length}',
      //                         style: TextStyle(
      //                           fontSize: 12,
      //                           color: Colors.white,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),

      body: SafeArea(
        child: Column(
          children: [
            VehicleDetails(
              garageModel: widget.garageModel,
              pairedOffers: _filteredOffers,
            ),
            Expanded(
              child: LiquidPullToRefresh(
                onRefresh: _fetchOffers,
                color: userController.isDark ? primaryColor : Colors.white,
                // strokeWidth: 3,
                height: 100, // Adjust pull height

                animSpeedFactor: 2, // Adjust animation speed
                showChildOpacityTransition: false, // Smooth effect
                backgroundColor:
                    userController.isDark ? Colors.white : primaryColor,
                child: FutureBuilder<List<OfferWithReceived>>(
                  future: _futureOffers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData) {
                      return Center(child: Text("No repairs found."));
                    } else {
                      // List<OfferWithReceived> pairedOffers = snapshot.data!;
                      // _sortOffers(pairedOffers);
                      if (_filteredOffers.isEmpty) {
                        return Center(child: Text("No repairs found."));
                      }
                      return Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                              child: ListView.builder(
                                  itemCount: _filteredOffers.length,
                                  itemBuilder: (context, index) {
                                    OfferWithReceived offerPair =
                                        _filteredOffers[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: RepairWidget(
                                        offersModel: offerPair.offer,
                                        garageModel: widget.garageModel,
                                        offersReceivedModel:
                                            offerPair.offerReceived,
                                      ),
                                    );
                                  }))
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:  AnimatedContainer(
        height: _selectedSort != 'Date Created' ? 120 : 60,
        duration: Duration(milliseconds: 400),
        child: Column(
          children: [
            if (_selectedSort != 'Date Created')
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 4, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
         
                    Chip(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      label: Text(
                        _selectedSort,
                      ),
                      labelStyle: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                      ),
                      deleteIcon: Icon(Icons.close),
                      deleteIconColor:
                          userController.isDark ? primaryColor : Colors.white,
                      onDeleted: () {
                        setState(() {
                          _selectedSort = 'Date Created'; // Reset to default
                          _sortAndFilterOffers();
                        });
                      },
                      backgroundColor:
                          userController.isDark ? Colors.white : primaryColor,
                    ),
                  ],
                ),
              ),
            AppBar(
              backgroundColor:
                  userController.isDark ? primaryColor : Colors.white,
              title: Text(
                'Repair History',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: userController.isDark ? Colors.white : primaryColor,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios_new_outlined),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // ✅ Sort Icon with Indicator
                      Stack(
                        children: [
                          PopupMenuButton<String>(
                            color: userController.isDark
                                ? primaryColor
                                : Colors.white,
                            elevation: 62,
                            icon: Icon(
                              Icons.sort,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                            ), // Sort Icon
                            onSelected: (value) {
                              setState(() {
                                _selectedSort = value;
                                _sortAndFilterOffers();
                              });
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                  value: 'Date Created',
                                  child: Text(
                                    'Date Created',
                                    style: TextStyle(
                                      // fontWeight: FontWeight.w700,
                                      // fontSize: 17,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                  )),
                              PopupMenuItem(
                                  value: 'Date Completed',
                                  child: Text(
                                    'Date Completed',
                                    style: TextStyle(
                                      // fontWeight: FontWeight.w700,
                                      // fontSize: 17,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                  )),
                              PopupMenuItem(
                                  value: 'Price: Low to High',
                                  child: Text(
                                    'Price: Low to High',
                                    style: TextStyle(
                                      // fontWeight: FontWeight.w700,
                                      // fontSize: 17,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                  )),
                              PopupMenuItem(
                                  value: 'Price: High to Low',
                                  child: Text(
                                    'Price: High to Low',
                                    style: TextStyle(
                                      // fontWeight: FontWeight.w700,
                                      // fontSize: 17,
                                      color: userController.isDark
                                          ? Colors.white
                                          : primaryColor,
                                    ),
                                  )),
                            ],
                          ),
                          if (_selectedSort !=
                              'Date Created') // Show dot if sort is applied
                            Positioned(
                              right: 6,
                              top: 6,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.red, // Indicator color
                              ),
                            ),
                        ],
                      ),

                      SizedBox(width: 10),

                      // ✅ Filter Icon with Count Indicator
                      InkWell(
                        onTap: () =>
                            _showFilterDialog(getServices(), userController),
                        child: Stack(
                          children: [
                            IconButton(
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              icon: Icon(
                                Icons.filter_list,
                              ),
                              onPressed: () => _showFilterDialog(
                                  getServices(), userController),
                            ),
                            if (_selectedServiceTypes
                                .isNotEmpty) // Show count if filters are selected
                              Positioned(
                                right: 6,
                                top: 6,
                                child: CircleAvatar(
                                  radius: 9,
                                  backgroundColor:
                                      Colors.red, // Indicator color
                                  child: Text(
                                    '${_selectedServiceTypes.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(
      List<Service> allServiceTypes, UserController userController) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          bool allSelected =
              _selectedServiceTypes.length == allServiceTypes.length;
          bool hasSelection = _selectedServiceTypes.isNotEmpty;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor:
                userController.isDark ? primaryColor : Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.9, // 90% of screen width
              padding: EdgeInsets.all(16),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filter by Service Type",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: allServiceTypes.map((service) {
                          return CheckboxListTile(
                            title: Text(service.name),
                            value: _selectedServiceTypes.contains(service.name),
                            onChanged: (bool? value) {
                              setState(() {
                                _toggleServiceSelection(service.name);
                              });
                              // Navigator.pop(context);
                              // _showFilterDialog(allServiceTypes);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSelection)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedServiceTypes.clear();
                              _sortAndFilterOffers();
                            });
                          },
                          child: Text("Clear Filters"),
                        ),
                      if (!allSelected) // ✅ Hide "Select All" button when everything is selected
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedServiceTypes = allServiceTypes
                                  .map((service) => service.name)
                                  .toList();
                              _sortAndFilterOffers();
                            });
                          },
                          child: Text("Select All"),
                        ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Close"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

class VehicleDetails extends StatelessWidget {
  final GarageModel garageModel;
  final List<OfferWithReceived> pairedOffers;
  const VehicleDetails(
      {super.key, required this.garageModel, required this.pairedOffers});

  @override
  Widget build(BuildContext context) {
    double getTotalPrice(List<OfferWithReceived> pairedOffers) {
      double totalPrice = 0.0;

      for (var pair in pairedOffers) {
        // Convert price string to double safely
        double price = double.tryParse(pair.offerReceived.price) ?? 0.0;
        totalPrice += price;
      }

      return totalPrice;
    }

    final UserController userController = Provider.of<UserController>(context);
    DateTime? getLastRepairDate(List<OfferWithReceived> pairedOffers) {
      if (pairedOffers.isEmpty) return null; // No repairs found

      return pairedOffers
          .map((offer) => DateTime.parse(offer
              .offerReceived.completedAt)) // Access from offersReceivedModel
          .reduce((a, b) => a.isAfter(b) ? a : b); // Find the latest date
    }

    return Card(
      elevation: 0.5,
      color: userController.isDark ? primaryColor : Colors.white,
      margin: EdgeInsets.only(
        top: 0.0,
        bottom: 0.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Hero(
                tag: garageModel.garageId,
                child: CachedNetworkImage(
                  imageUrl: garageModel.imageUrl,
                  height: 115,
                  fit: BoxFit.cover,
                  width: 80,
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    garageModel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        'Total Spent : ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' \$${getTotalPrice(pairedOffers)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        'Times Repaired : ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' ${pairedOffers.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        'Last Repaired : ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' ${getLastRepairDate(pairedOffers) == null ? 'No repair' : formatDate(getLastRepairDate(pairedOffers) ?? DateTime.now())}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OfferWithReceived {
  final OffersModel offer;
  final OffersReceivedModel offerReceived;

  OfferWithReceived({required this.offer, required this.offerReceived});
}
