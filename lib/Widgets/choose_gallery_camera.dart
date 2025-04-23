import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';

class ChooseGalleryCamera extends StatelessWidget {
  final Function onTapCamera;
  final Function onTapGallery;
  const ChooseGalleryCamera(
      {super.key, required this.onTapCamera, required this.onTapGallery});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return BottomSheet(
        constraints: BoxConstraints(
          maxHeight: 200,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
     
        ),
        onClosing: () {},
        builder: (context) {
          return Card(
            margin: const EdgeInsets.all(0),
            elevation: 4.0,
            color: userController.isDark ? primaryColor : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      onTapGallery();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.perm_media_outlined,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          size: 70,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Open Gallery',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  InkWell(
                    onTap: () {
                      onTapCamera();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 70,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Open Camera',
                          style: TextStyle(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
