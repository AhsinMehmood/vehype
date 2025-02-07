import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';

class VehicleBasedCompletedRequests extends StatefulWidget {
  
  const VehicleBasedCompletedRequests({super.key});

  @override
  State<VehicleBasedCompletedRequests> createState() =>
      _VehicleBasedCompletedRequestsState();
}

class _VehicleBasedCompletedRequestsState
    extends State<VehicleBasedCompletedRequests> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
    );
  }
}
