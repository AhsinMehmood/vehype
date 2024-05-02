import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/const.dart';

import '../Controllers/user_controller.dart';

class FullImagePageView extends StatelessWidget {
  final String url;
  const FullImagePageView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: ExtendedImage.network(
              url,
              // height: Get.height,
              // width: Get.width,
              cache: true,
              // fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              mode: ExtendedImageMode.gesture,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(Icons.close, color: Colors.white)),
          )
        ],
      ),
    );
  }
}
