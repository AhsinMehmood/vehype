import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import 'service_request_widget.dart';

class IgnoredOffers extends StatelessWidget {
  const IgnoredOffers({
    super.key,
    required this.userController,
    required this.userModel,
    required this.ignoredOffers,
  });

  final UserController userController;
  final UserModel userModel;
  final List<OffersModel> ignoredOffers;

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final UserModel userModel = userController.userModel!;
    if (ignoredOffers.isEmpty) {
      return Center(
        child: Text(
          'No Ignored Offers Yet!',
          style: TextStyle(
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
        itemCount: ignoredOffers.length,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 15),
        itemBuilder: (context, index) {
          OffersModel offersModel = ignoredOffers[index];

          return ServiceRequestWidget(
            offersModel: offersModel,
          );
        });
  }
}
