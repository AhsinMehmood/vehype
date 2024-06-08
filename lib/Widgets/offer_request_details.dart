import 'package:flutter/material.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';
import '../Models/offers_model.dart';
import 'select_date_and_price.dart';

class OfferRequestDetails extends StatelessWidget {
  const OfferRequestDetails({
    super.key,
    required this.userController,
    required this.offersReceivedModel,
  });

  final UserController userController;
  final OffersReceivedModel offersReceivedModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          'Offer Details',
          style: TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w400,
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 15,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          offersReceivedModel.comment.isEmpty
              ? 'No details'
              : offersReceivedModel.comment,
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w700,
            // color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Start At:',
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w400,
            // color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          formatDateTime(
              DateTime.parse(offersReceivedModel.startDate).toLocal()),
          style: TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w700,
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'End At:',
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w400,
            // color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          formatDateTime(DateTime.parse(offersReceivedModel.endDate).toLocal()),
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w700,
            // color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Price',
          style: const TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.w400,
            // color: Colors.black,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          '${offersReceivedModel.price}\$',
          style: TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.bold,
            color: userController.isDark ? Colors.white : primaryColor,
            fontSize: 17,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
