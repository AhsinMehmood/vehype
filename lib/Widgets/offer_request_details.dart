// ignore_for_file: prefer_const_constructors

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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Price:',
                    style: const TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w600,
                      // color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '\$${offersReceivedModel.price.toInt()}',
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.bold,
                      // color: Colors.red,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
