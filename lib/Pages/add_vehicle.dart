// ignore_for_file: prefer_const_constructors, prefer_final_fields

// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'package:package_rename/package_rename.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/Widgets/delete_vehicle_confirmation.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Controllers/vehicle_data.dart';
import '../Models/vehicle_model.dart';
import '../Widgets/loading_dialog.dart';

class AddVehicle extends StatefulWidget {
  final GarageModel? garageModel;
  final bool addService;
  const AddVehicle(
      {super.key, required this.garageModel, this.addService = false});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  TextEditingController _vinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((value) {
      if (widget.garageModel != null) {
        _vinController.text = widget.garageModel!.vin;

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);

    return WillPopScope(
      onWillPop: () async {
        garageController.disposeController();
        return true;
      },
      child: Scaffold(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: userController.isDark ? primaryColor : Colors.white,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                garageController.disposeController();

                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: userController.isDark ? Colors.white : primaryColor,
              )),
          title: Text(
            widget.garageModel == null ? 'Add Vehicle' : 'Update Vehicle',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            if (widget.garageModel != null)
              IconButton(
                onPressed: () {
                  Get.bottomSheet(DeleteVehicleConfirmation(
                      chatId: widget.garageModel!.garageId));
                },
                icon: Icon(Icons.delete_forever_outlined),
                iconSize: 28,
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    // completeProfileProvider.selectImages(0, context);
                    garageController.selectImage(context, userModel, 0);
                  },
                  child: Container(
                    height: 220,
                    width: Get.width * 0.9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: garageController.imageOneUrl == ''
                            ? Border.all(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.4)
                                    : primaryColor.withOpacity(0.4),
                              )
                            : null),
                    child: garageController.imageOneLoading
                        ? SizedBox(
                            height: 40,
                            width: 40,
                            child: CupertinoActivityIndicator())
                        : (garageController.imageOneUrl == ''
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 60,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: userController.isDark
                                            ? Colors.white.withOpacity(0.4)
                                            : primaryColor.withOpacity(0.4),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Center(
                                      child: Text(
                                        'Add Image',
                                        style: TextStyle(
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ExtendedImage.network(
                                  garageController.imageOneUrl,
                                  handleLoadingProgress: true,
                                  fit: BoxFit.cover,
                                ),
                              )),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )),
                        // constraints: BoxConstraints(
                        //   minHeight: Get.height * 0.7,
                        //   maxHeight: Get.height * 0.7,
                        // ),
                        isScrollControlled: true,
                        // showDragHandle: true,
                        builder: (context) {
                          return BodyStylePicker();
                        }).then((value) {
                      // editProfileProvider
                      //     .upadeteUpcomingDestinations(userModel);
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Type *',
                        style: TextStyle(
                          // fontFamily: 'Avenir',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: userController.isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : primaryColor.withOpacity(0.4),
                            )),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              garageController.selectedVehicleType == null
                                  ? 'Choose'
                                  : garageController.selectedVehicleType!.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // color: changeColor(color: '7B7B7B'),
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    if (garageController.selectedVehicleType == null) {
                      toastification.show(
                        context: context,
                        title: Text('Please select vehicle type first'),
                        autoCloseDuration: Duration(seconds: 3),
                      );
                      return;
                    }

                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        )),
                        // constraints: BoxConstraints(
                        //   minHeight: Get.height * 0.7,
                        //   maxHeight: Get.height * 0.7,
                        // ),
                        isScrollControlled: true,
                        // showDragHandle: true,
                        builder: (context) {
                          return MakePicker();
                        }).then((value) {
                      // editProfileProvider
                      //     .upadeteUpcomingDestinations(userModel);
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make *',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: userController.isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : primaryColor.withOpacity(0.4),
                            )),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                garageController.selectedVehicleMake == null
                                    ? 'Choose'
                                    : garageController
                                        .selectedVehicleMake!.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  // color: changeColor(color: '7B7B7B'),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    if (garageController.selectedVehicleMake != null) {
                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                          constraints: BoxConstraints(
                            minHeight: Get.height * 0.7,
                            maxHeight: Get.height * 0.7,
                          ),
                          // isScrollControlled: true,
                          // showDragHandle: true,
                          builder: (context) {
                            return YearPicker();
                          }).then((value) {
                        // editProfileProvider
                        //     .upadeteUpcomingDestinations(userModel);
                      });
                    } else {
                      toastification.show(
                        context: context,
                        title: Text('Please select make first'),
                        autoCloseDuration: Duration(seconds: 3),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Year *',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: userController.isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : primaryColor.withOpacity(0.4),
                            )),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              garageController.selectedYear == ''
                                  ? 'Choose'
                                  : garageController.selectedYear,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // color: changeColor(color: '7B7B7B'),
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    if (garageController.selectedVehicleMake != null &&
                        garageController.selectedYear != '') {
                      // List<VehicleModel> vehicleMakeList = await getSubModels(
                      //     garageController.selectedVehicleMake!.title,
                      //     '',
                      //     garageController.selectedYear,
                      //     garageController.selectedVehicleType!.title);

                      showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                          // constraints: BoxConstraints(
                          //   minHeight: Get.height * 0.7,
                          //   maxHeight: Get.height * 0.7,
                          // ),
                          isScrollControlled: true,
                          // showDragHandle: true,
                          builder: (context) {
                            return ModelPicker(
                                // listOfModels: vehicleMakeList,
                                );
                          }).then((value) {
                        // editProfileProvider
                        //     .upadeteUpcomingDestinations(userModel);
                      });
                    } else {
                      toastification.show(
                        context: context,
                        title: Text('Please select year first'),
                        autoCloseDuration: Duration(seconds: 3),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model *',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: userController.isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : primaryColor.withOpacity(0.4),
                            )),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              garageController.selectedVehicleModel == null
                                  ? 'Choose'
                                  : garageController
                                      .selectedVehicleModel!.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // color: changeColor(color: '7B7B7B'),
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              size: 24,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (garageController.vehicleSubModels.isNotEmpty)
                  InkWell(
                    onTap: () async {
                      if (garageController.selectedVehicleModel != null) {
                        // List<VehicleModel> vehicleMakeList = await getSubModels(
                        //     garageController.selectedVehicleMake!.title,
                        //     '',
                        //     garageController.selectedYear,
                        //     garageController.selectedVehicleType!.title);

                        showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )),
                            // constraints: BoxConstraints(
                            //   minHeight: Get.height * 0.7,
                            //   maxHeight: Get.height * 0.7,
                            // ),
                            isScrollControlled: true,
                            // showDragHandle: true,
                            builder: (context) {
                              return SubModelPicker(
                                  // listOfModels: vehicleMakeList,
                                  );
                            }).then((value) {
                          // editProfileProvider
                          //     .upadeteUpcomingDestinations(userModel);
                        });
                      } else {
                        toastification.show(
                          context: context,
                          title: Text('Please select model first'),
                          autoCloseDuration: Duration(seconds: 3),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sub-Model *',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.4)
                                    : primaryColor.withOpacity(0.4),
                              )),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  garageController.selectedSubModel == null
                                      ? 'Choose'
                                      : garageController
                                          .selectedSubModel!.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    // color: changeColor(color: '7B7B7B'),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                size: 24,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIN',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color:
                            userController.isDark ? Colors.white : primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      controller: _vinController,
                      cursorColor:
                          userController.isDark ? Colors.white : primaryColor,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                          hintText: 'Enter VIN',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          )
                          // counter: const SizedBox.shrink(),
                          ),
                      // initialValue: '',

                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        // color: changeColor(color: '7B7B7B'),
                        fontSize: 16,
                      ),
                      // maxLength: 25,
                      // onChanged: (String value) => editProfileProvider
                      //     .updateTexts(userModel, 'name', value),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (garageController.saveButtonValidation()) {
                        garageController.saveVehicle(
                            userModel, _vinController.text, widget.addService);
                      } else {
                        toastification.show(
                          context: context,
                          title: Text(
                              'The fields that are marked with * are required!'),
                          autoCloseDuration: Duration(seconds: 3),
                          type: ToastificationType.error,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            userController.isDark ? Colors.white : primaryColor,
                        maximumSize: Size(Get.width * 0.9, 50),
                        minimumSize: Size(Get.width * 0.9, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        )),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MakePicker extends StatefulWidget {
  const MakePicker({super.key});

  @override
  State<MakePicker> createState() => _MakePickerState();
}

class _MakePickerState extends State<MakePicker> {
  List<VehicleMake> _filteredList = [];

  void _filterSearchResults(String query, List<VehicleMake> vehicleMakesList) {
    List<VehicleMake> vehicleList = vehicleMakesList;

    List<VehicleMake> searchResult = <VehicleMake>[];

    if (query.isEmpty) {
      searchResult.addAll(vehicleList);
    } else {
      searchResult = vehicleList.where((c) => c.startsWith(query)).toList();
    }

    setState(() => _filteredList = searchResult);
  }

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);
    List<VehicleMake> vehicleMakeList =
        garageController.vehiclesMakesByVehicleType;
    vehicleMakeList.sort((a, b) => a.title.compareTo(b.title));
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.85,
      child: vehicleMakeList.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (String text) {
                      _filterSearchResults(text, vehicleMakeList);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (_filteredList.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          VehicleMake bodyStyle = _filteredList[index];
                          return InkWell(
                            onTap: () {
                              garageController.selectMake(bodyStyle);
                              Get.close(1);
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // const SizedBox(
                                            //   width: 10,
                                            // ),
                                            Expanded(
                                              child: Text(
                                                bodyStyle.title,
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
                                      if (garageController
                                                  .selectedVehicleMake !=
                                              null &&
                                          garageController
                                                  .selectedVehicleMake!.title ==
                                              bodyStyle.title)
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
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 1,
                                  width: Get.width * 0.9,
                                  color: userController.isDark
                                      ? Colors.white.withOpacity(0.3)
                                      : primaryColor.withOpacity(0.3),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: _filteredList.length,
                      ),
                    ),
                  if (_filteredList.isEmpty)
                    // for (VehicleMake bodyStyle in widget.vehicleList)
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          VehicleMake bodyStyle = vehicleMakeList[index];
                          return InkWell(
                            onTap: () {
                              garageController.selectMake(bodyStyle);
                              Get.close(1);
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // const SizedBox(
                                            //   width: 10,
                                            // ),
                                            Expanded(
                                              child: Text(
                                                bodyStyle.title,
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
                                      if (garageController
                                                  .selectedVehicleMake !=
                                              null &&
                                          garageController
                                                  .selectedVehicleMake!.title ==
                                              bodyStyle.title)
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
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 1,
                                  width: Get.width * 0.9,
                                  color: userController.isDark
                                      ? Colors.white.withOpacity(0.3)
                                      : primaryColor.withOpacity(0.3),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: vehicleMakeList.length,
                      ),
                    ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
    );
  }
}

class YearPicker extends StatelessWidget {
  const YearPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);
    List<int> yearList = garageController.vehicleYearsByMake;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      child: yearList.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                  itemCount: yearList.length, // Years from 1900 to 2024
                  shrinkWrap: true,
                  // reverse: true,
                  itemBuilder: (context, index) {
                    final year = yearList[index];
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            garageController.selectYear(year.toString());
                            Get.close(1);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  year.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: userController.isDark
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                if (garageController.selectedYear ==
                                    year.toString())
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
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
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }),
            ),
    );
  }
}

class BodyStylePicker extends StatelessWidget {
  const BodyStylePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (VehicleType bodyStyle in getVehicleType())
                InkWell(
                  onTap: () {
                    garageController.selectVehicleType(bodyStyle);

                    Get.close(1);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 25,
                                    width: 40,
                                    child: SvgPicture.asset(
                                      bodyStyle.icon,
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
                                      bodyStyle.title,
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
                            if (garageController.selectedVehicleType != null &&
                                garageController.selectedVehicleType!.id ==
                                    bodyStyle.id)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
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
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 1,
                        width: Get.width * 0.9,
                        color: userController.isDark
                            ? Colors.white.withOpacity(0.3)
                            : primaryColor.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModelPicker extends StatefulWidget {
  const ModelPicker({super.key});

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  List<VehicleModel> _filteredList = [];

  void _filterSearchResults(
    String query,
    List<VehicleModel> vehicleModelList,
  ) {
    List<VehicleModel> vehicleList = vehicleModelList;

    List<VehicleModel> searchResult = <VehicleModel>[];

    if (query.isEmpty) {
      searchResult.addAll(vehicleList);
    } else {
      searchResult = vehicleList.where((c) => c.startsWith(query)).toList();
    }

    setState(() => _filteredList = searchResult);
  }

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);
    List<VehicleModel> vehicleModels = garageController.vehiclesModelsByYear;
    vehicleModels.sort((a, b) => a.title.compareTo(b.title));
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.85,
      child: vehicleModels.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (String text) {
                      _filterSearchResults(text, vehicleModels);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (_filteredList.isNotEmpty)
                    // for (VehicleModel bodyStyle in _filteredList)
                    Expanded(
                        child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        VehicleModel bodyStyle = _filteredList[index];
                        return InkWell(
                          onTap: () {
                            garageController.selectModel(bodyStyle);
                            Get.close(1);
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bodyStyle.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (garageController.selectedVehicleModel !=
                                            null &&
                                        garageController
                                                .selectedVehicleModel!.title ==
                                            bodyStyle.title)
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
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 1,
                                width: Get.width * 0.9,
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: _filteredList.length,
                    )),
                  if (_filteredList.isEmpty)
                    // for (VehicleModel bodyStyle in widget.listOfModels)
                    Expanded(
                        child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        VehicleModel bodyStyle = vehicleModels[index];
                        return InkWell(
                          onTap: () {
                            garageController.selectModel(bodyStyle);
                            Get.close(1);
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bodyStyle.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (garageController.selectedVehicleModel !=
                                            null &&
                                        garageController
                                                .selectedVehicleModel!.title ==
                                            bodyStyle.title)
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
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 1,
                                width: Get.width * 0.9,
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: vehicleModels.length,
                    )),
                ],
              ),
            ),
    );
  }
}

class SubModelPicker extends StatefulWidget {
  const SubModelPicker({super.key});

  @override
  State<SubModelPicker> createState() => _SubModelPickerState();
}

class _SubModelPickerState extends State<SubModelPicker> {
  List<VehicleModel> _filteredList = [];

  void _filterSearchResults(
    String query,
    List<VehicleModel> vehicleModelList,
  ) {
    List<VehicleModel> vehicleList = vehicleModelList;

    List<VehicleModel> searchResult = <VehicleModel>[];

    if (query.isEmpty) {
      searchResult.addAll(vehicleList);
    } else {
      searchResult = vehicleList.where((c) => c.startsWith(query)).toList();
    }

    setState(() => _filteredList = searchResult);
  }

  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);
    List<VehicleModel> vehicleModels = garageController.vehicleSubModels;
    vehicleModels.sort((a, b) => a.title.compareTo(b.title));
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.85,
      child: vehicleModels.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: userController.isDark ? Colors.white : primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (String text) {
                      _filterSearchResults(text, vehicleModels);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (_filteredList.isNotEmpty)
                    // for (VehicleModel bodyStyle in _filteredList)
                    Expanded(
                        child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        VehicleModel bodyStyle = _filteredList[index];
                        return InkWell(
                          onTap: () {
                            garageController.selectSubModel(bodyStyle);
                            Get.close(1);
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bodyStyle.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (garageController.selectedSubModel !=
                                            null &&
                                        garageController
                                                .selectedSubModel!.title ==
                                            bodyStyle.title)
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
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 1,
                                width: Get.width * 0.9,
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: _filteredList.length,
                    )),
                  if (_filteredList.isEmpty)
                    // for (VehicleModel bodyStyle in widget.listOfModels)
                    Expanded(
                        child: ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        VehicleModel bodyStyle = vehicleModels[index];
                        return InkWell(
                          onTap: () {
                            garageController.selectSubModel(bodyStyle);
                            Get.close(1);
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bodyStyle.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: userController.isDark
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (garageController.selectedSubModel !=
                                            null &&
                                        garageController
                                                .selectedSubModel!.title ==
                                            bodyStyle.title)
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
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                height: 1,
                                width: Get.width * 0.9,
                                color: userController.isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: vehicleModels.length,
                    )),
                ],
              ),
            ),
    );
  }
}

class FuelPicker extends StatefulWidget {
  const FuelPicker({super.key});

  @override
  State<FuelPicker> createState() => _FuelPickerState();
}

class _FuelPickerState extends State<FuelPicker> {
  @override
  Widget build(BuildContext context) {
    final GarageController garageController =
        Provider.of<GarageController>(context);
    final UserController userController = Provider.of<UserController>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            String fuelType = garageController.fuelTypes[index];
            return InkWell(
              onTap: () {
                garageController.selectFuelType(fuelType);
                Get.close(1);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fuelType,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (garageController.selectedFuelType == fuelType)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
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
            );
          },
          itemCount: garageController.fuelTypes.length,
        ),
      ),
    );
  }
}
