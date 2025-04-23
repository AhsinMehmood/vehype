import 'package:cached_network_image/cached_network_image.dart';
// import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Controllers/user_controller.dart';

class FullImagePageView extends StatelessWidget {
  final List urls;
  final int? currentIndex;
  const FullImagePageView({super.key, required this.urls, this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    final PageController pageController =
        PageController(initialPage: currentIndex ?? 0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
          itemCount: urls.length,
          controller: pageController,
          itemBuilder: (context, index) {
            return Stack(
       
              children: [
                Center(
                  child: CachedNetworkImage(
                    placeholder: (context, url) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorWidget: (context, url, error) =>
                        const SizedBox.shrink(),
                    imageUrl: urls[index],
                    // height: Get.height,
                    // width: Get.width,

                    // fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
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
            );
          }),
    );
  }
}
