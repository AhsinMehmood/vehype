import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:interactive_slider/interactive_slider.dart';
import 'package:provider/provider.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';

class ServiceRadiusWidget extends StatelessWidget {
  const ServiceRadiusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Container(
      // child: ,
      decoration: BoxDecoration(),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Text(
                'Requests Radius',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Slider(
              value: userController.radiusMiles,
              max: 200.0,
              min: 50.0,
              // divisions: 10,
              activeColor: userController.isDark ? Colors.white : primaryColor,
              onChanged: (s) {
                userController.changeRadius(s);
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('50mi'),
              Text(
                '${userController.radiusMiles.toInt()}mi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text('200mi'),
            ],
          ),
        ],
      ),
    );
  }
}
