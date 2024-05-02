// ignore_for_file: prefer_const_constructors

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
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/user_model.dart';
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
  TextEditingController _descriptionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((value) {
      final GarageController garageController =
          Provider.of<GarageController>(context, listen: false);
      if (widget.garageModel != null) {
        garageController.initVehicle(widget.garageModel!);
        _vinController.text = widget.garageModel!.vin;
        _descriptionController.text = widget.garageModel!.description;
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
            'Add Vehicle',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            if (widget.garageModel != null)
              IconButton(
                onPressed: () async {
                  Get.dialog(LoadingDialog(), barrierDismissible: false);
                  await FirebaseFirestore.instance
                      .collection('garages')
                      .doc(widget.garageModel!.garageId)
                      .delete();
                  garageController.disposeController();

                  Get.close(2);
                },
                color: userController.isDark ? Colors.white : primaryColor,
                icon: Icon(
                  Icons.delete_outlined,
                ),
              ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        // completeProfileProvider.selectImages(0, context);
                        garageController.selectImage(context, userModel, 0);
                      },
                      child: Container(
                        height: Get.width * 0.35,
                        width: Get.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: garageController.imageOneUrl == ''
                              ? Colors.grey.shade400.withOpacity(0.7)
                              : null,
                        ),
                        child: garageController.imageOneLoading
                            ? SizedBox(
                                height: 40,
                                width: 40,
                                child: CupertinoActivityIndicator())
                            : (garageController.imageOneUrl == ''
                                ? Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 70,
                                    color: Colors.white,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: ExtendedImage.network(
                                      garageController.imageOneUrl,
                                      handleLoadingProgress: true,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
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
                  child: SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Body Style',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          garageController.selectedVehicleType == null
                              ? 'Select Body Style'
                              : garageController.selectedVehicleType!.title,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    Get.dialog(LoadingDialog(), barrierDismissible: false);

                    List<VehicleMake> vehicleMakeList = await getVehicleMake(
                        garageController.selectedVehicleType!.title);
                    Get.close(1);
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
                          return MakePicker(
                            vehicleList: vehicleMakeList,
                          );
                        }).then((value) {
                      // editProfileProvider
                      //     .upadeteUpcomingDestinations(userModel);
                    });
                  },
                  child: SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          garageController.selectedVehicleMake == null
                              ? 'Select Make'
                              : garageController.selectedVehicleMake!.title,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    if (garageController.selectedVehicleMake != null) {
                      Get.dialog(LoadingDialog(), barrierDismissible: false);
                      // Get.close(1);

                      List<int> yearList = await getVehicleYear(
                          garageController.selectedVehicleMake!.title);
                      Get.close(1);

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
                            return YearPicker(
                              yearList: yearList,
                            );
                          }).then((value) {
                        // editProfileProvider
                        //     .upadeteUpcomingDestinations(userModel);
                      });
                    }
                  },
                  child: SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Year',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          garageController.selectedYear.isEmpty
                              ? 'Select Year'
                              : garageController.selectedYear,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    if (garageController.selectedVehicleMake != null &&
                        garageController.selectedYear != '') {
                      Get.dialog(LoadingDialog(), barrierDismissible: false);

                      List<VehicleModel> vehicleMakeList =
                          await getVehicleModel(
                              int.parse(garageController.selectedYear),
                              garageController.selectedVehicleMake!.title);
                      Get.close(1);
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
                              listOfModels: vehicleMakeList,
                            );
                          }).then((value) {
                        // editProfileProvider
                        //     .upadeteUpcomingDestinations(userModel);
                      });
                    }
                  },
                  child: SizedBox(
                    width: Get.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Model',
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          garageController.selectedVehicleModel == null
                              ? 'Select Model'
                              : garageController.selectedVehicleModel!.title,
                          style: TextStyle(
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400,
                            // color: changeColor(color: '7B7B7B'),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VIN',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 30,
                      child: TextFormField(
                        onTapOutside: (s) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        controller: _vinController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: 'Enter VIN'
                            // counter: const SizedBox.shrink(),
                            ),
                        // initialValue: '',

                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          fontFamily: 'Avenir',
                          fontWeight: FontWeight.w400,
                          // color: changeColor(color: '7B7B7B'),
                          fontSize: 16,
                        ),
                        // maxLength: 25,
                        // onChanged: (String value) => editProfileProvider
                        //     .updateTexts(userModel, 'name', value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
                        // color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      onTapOutside: (s) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      controller: _descriptionController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Enter Description'
                          // counter: const SizedBox.shrink(),
                          ),
                      // initialValue: '',

                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w400,
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
                  height: 5,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 1,
                    width: Get.width,
                    color: changeColor(color: 'D9D9D9'),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    onPressed: garageController.saveButtonValidation()
                        ? () async {
                            garageController.saveVehicle(
                                userModel,
                                _vinController.text,
                                _descriptionController.text,
                                widget.addService);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            userController.isDark ? Colors.white : primaryColor,
                        maximumSize: Size(Get.width * 0.8, 60),
                        minimumSize: Size(Get.width * 0.8, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        )),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color:
                            userController.isDark ? primaryColor : Colors.white,
                        fontSize: 18,
                        fontFamily: 'Avenir',
                        fontWeight: FontWeight.w800,
                      ),
                    )),
                const SizedBox(
                  height: 20,
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
  final List<VehicleMake> vehicleList;
  const MakePicker({super.key, required this.vehicleList});

  @override
  State<MakePicker> createState() => _MakePickerState();
}

class _MakePickerState extends State<MakePicker> {
  List<VehicleMake> _filteredList = [];

  void _filterSearchResults(
    String query,
  ) {
    List<VehicleMake> vehicleList = widget.vehicleList;

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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              onChanged: (String text) {
                _filterSearchResults(text);
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        fontFamily: 'Avenir',
                                        fontWeight: FontWeight.w400,
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
                            if (garageController.selectedVehicleMake != null &&
                                garageController.selectedVehicleMake!.id ==
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
                    VehicleMake bodyStyle = widget.vehicleList[index];
                    return InkWell(
                      onTap: () {
                        garageController.selectMake(bodyStyle);
                        Get.close(1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        fontFamily: 'Avenir',
                                        fontWeight: FontWeight.w400,
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
                            if (garageController.selectedVehicleMake != null &&
                                garageController.selectedVehicleMake!.id ==
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
                    );
                  },
                  itemCount: widget.vehicleList.length,
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
  final List<int> yearList;
  const YearPicker({super.key, required this.yearList});

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
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.w400,
                              color: userController.isDark
                                  ? Colors.white
                                  : primaryColor,
                              fontSize: 16,
                            ),
                          ),
                          if (garageController.selectedYear == year.toString())
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
                  child: Padding(
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
                                    fontFamily: 'Avenir',
                                    fontWeight: FontWeight.w400,
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
  final List<VehicleModel> listOfModels;
  const ModelPicker({super.key, required this.listOfModels});

  @override
  State<ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<ModelPicker> {
  List<VehicleModel> _filteredList = [];

  void _filterSearchResults(
    String query,
  ) {
    List<VehicleModel> vehicleList = widget.listOfModels;

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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: userController.isDark ? primaryColor : Colors.white,
      ),
      height: Get.height * 0.7,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              onChanged: (String text) {
                _filterSearchResults(text);
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bodyStyle.title,
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w400,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (garageController.selectedVehicleModel != null &&
                              garageController.selectedVehicleModel!.title ==
                                  bodyStyle.title)
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
                itemCount: _filteredList.length,
              )),
            if (_filteredList.isEmpty)
              // for (VehicleModel bodyStyle in widget.listOfModels)
              Expanded(
                  child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  VehicleModel bodyStyle = widget.listOfModels[index];
                  return InkWell(
                    onTap: () {
                      garageController.selectModel(bodyStyle);
                      Get.close(1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              bodyStyle.title,
                              style: TextStyle(
                                fontFamily: 'Avenir',
                                fontWeight: FontWeight.w400,
                                color: userController.isDark
                                    ? Colors.white
                                    : primaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (garageController.selectedVehicleModel != null &&
                              garageController.selectedVehicleModel!.title ==
                                  bodyStyle.title)
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
                itemCount: widget.listOfModels.length,
              )),
          ],
        ),
      ),
    );
  }
}
