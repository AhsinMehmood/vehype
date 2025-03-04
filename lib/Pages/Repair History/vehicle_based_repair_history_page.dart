import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/garage_model.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

class VehicleBasedRepairHistoryPage extends StatefulWidget {
  final GarageModel garageModel;
  const VehicleBasedRepairHistoryPage({super.key, required this.garageModel});

  @override
  State<VehicleBasedRepairHistoryPage> createState() =>
      _VehicleBasedRepairHistoryPageState();
}

class _VehicleBasedRepairHistoryPageState
    extends State<VehicleBasedRepairHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Repair History',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
      ),
    );
  }
}
