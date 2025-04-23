import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/garage_controller.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';

import '../Models/user_model.dart';
import '../Widgets/choose_gallery_camera.dart';

class ServiceRepairInfoFill extends StatefulWidget {
  const ServiceRepairInfoFill({super.key});

  @override
  State<ServiceRepairInfoFill> createState() => _ServiceRepairInfoFillState();
}

class _ServiceRepairInfoFillState extends State<ServiceRepairInfoFill> {
  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        title: Text(
          'Title',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Text(
                'Subtitle: Tell us more about the job...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              CreateRequestImageAddWidget(
                  garageController: GarageController(),
                  userModel: userController.userModel!,
                  userController: userController),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hours Spent*',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    cursorColor:
                        userController.isDark ? Colors.white : primaryColor,
                    // controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                      hintText: 'e.g 3 hours',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      counter: const SizedBox.shrink(),
                    ),
                    // initialValue: '',
                    maxLength: 10,

                    textCapitalization: TextCapitalization.sentences,

                    // maxLines: 4,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                height: 20,
              ),
              Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tools That You have Used*',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    cursorColor:
                        userController.isDark ? Colors.white : primaryColor,
                    // controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                      hintText: 'e.g wrench',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      counter: const SizedBox.shrink(),
                    ),
                    // initialValue: '',
                    maxLength: 10,

                    textCapitalization: TextCapitalization.sentences,

                    // maxLines: 4,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                height: 20,
              ),
              Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Parts that you have changed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    onTapOutside: (s) {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    cursorColor:
                        userController.isDark ? Colors.white : primaryColor,
                    // controller: _descriptionController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: userController.isDark
                                ? Colors.white
                                : primaryColor,
                          )),
                      hintText: 'e.g headlights',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                      counter: const SizedBox.shrink(),
                    ),
                    // initialValue: '',
                    maxLength: 10,

                    textCapitalization: TextCapitalization.sentences,

                    // maxLines: 4,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
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
                height: 50,
              ),
              Container(
                height: 50,
                width: Get.width,
                decoration: BoxDecoration(
                    color: userController.isDark ? Colors.white : primaryColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: Center(
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          userController.isDark ? primaryColor : Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CreateRequestImageAddWidget extends StatelessWidget {
  const CreateRequestImageAddWidget({
    super.key,
    required this.garageController,
    required this.userModel,
    required this.userController,
  });

  final GarageController garageController;
  final UserModel userModel;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Add Media (Images/Videos)',
            style: TextStyle(
              color: userController.isDark ? Colors.white : primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  ChooseGalleryCamera(
                    onTapCamera: () {
                      // garageController.selectRequestImageUpdateSingleImage(
                      //     ImageSource.camera, userModel.userId, 0);
                      Get.close(1);
                    },
                    onTapGallery: () {
                      // garageController.selectRequestImageUpdateSingleImage(
                      //     ImageSource.gallery, userModel.userId, 0);
                      Get.close(1);
                    },
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: garageController.requestImages.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: Get.width * 0.15,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: garageController.requestImages[0].imageFile ==
                                null
                            ? CachedNetworkImage(
                                placeholder: (context, url) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    const SizedBox.shrink(),
                                imageUrl:
                                    garageController.requestImages[0].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                garageController.requestImages[0].imageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  ChooseGalleryCamera(
                    onTapCamera: () {
                      // garageController.selectRequestImageUpdateSingleImage(
                      //     ImageSource.camera, userModel.userId, 1);
                      // Get.close(1);
                    },
                    onTapGallery: () {
                      // garageController.selectRequestImageUpdateSingleImage(
                      //     ImageSource.gallery, userModel.userId, 1);
                      // Get.close(1);
                    },
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: garageController.requestImages.elementAtOrNull(1) == null
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: Get.width * 0.15,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: garageController.requestImages[1].imageFile ==
                                null
                            ? CachedNetworkImage(
                                placeholder: (context, url) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    const SizedBox.shrink(),
                                imageUrl:
                                    garageController.requestImages[1].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                garageController.requestImages[1].imageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  ChooseGalleryCamera(
                    onTapCamera: () {
                      // garageController.selectRequestImageUpdateSingleImage(
                      //     ImageSource.camera, userModel.userId, 2);
                      // Get.close(1);
                    },
                    onTapGallery: () {
                      // garageController.selectRequestImageUpdateSingleImage(
                      //     ImageSource.gallery, userModel.userId, 2);
                      // Get.close(1);
                    },
                  ),
                  backgroundColor:
                      userController.isDark ? primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                );
              },
              child: Container(
                height: Get.width * 0.25,
                width: Get.width * 0.25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color:
                          userController.isDark ? Colors.white : primaryColor,
                    )),
                child: garageController.requestImages.elementAtOrNull(2) == null
                    ? Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: Get.width * 0.15,
                          color: userController.isDark
                              ? Colors.white
                              : primaryColor,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: garageController.requestImages[2].imageFile ==
                                null
                            ? CachedNetworkImage(
                                placeholder: (context, url) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    const SizedBox.shrink(),
                                imageUrl:
                                    garageController.requestImages[2].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                garageController.requestImages[2].imageFile!,
                                fit: BoxFit.cover,
                              ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        // InkWell(
        //   child: Container(
        //       width: Get.width,
        //       height: Get.width * 0.45,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(4),
        //         // color: Colors.grey.shade400.withOpacity(0.7),
        //       ),
        //       child: garageController.requestImages.isEmpty
        //           ? InkWell(
        //               onTap: () {
        //                 Get.bottomSheet(
        //                   ChooseGalleryCamera(
        //                     onTapCamera: () {
        //                       garageController.selectRequestImage(
        //                           ImageSource.camera, userModel.userId);
        //                       Get.close(1);
        //                     },
        //                     onTapGallery: () {
        //                       garageController.selectRequestImage(
        //                           ImageSource.gallery, userModel.userId);
        //                       Get.close(1);
        //                     },
        //                   ),
        //                   backgroundColor: userController.isDark
        //                       ? primaryColor
        //                       : Colors.white,
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.only(
        //                       topLeft: Radius.circular(20),
        //                       topRight: Radius.circular(20),
        //                     ),
        //                   ),
        //                 );
        //               },
        //               child: Card(
        //                 color:
        //                     userController.isDark ? primaryColor : Colors.white,
        //                 child: Icon(
        //                   Icons.add_a_photo_rounded,
        //                   size: 70,
        //                   color: userController.isDark
        //                       ? Colors.white
        //                       : primaryColor,
        //                 ),
        //               ),
        //             )
        //           : PageView.builder(
        //               scrollDirection: Axis.horizontal,
        //               itemCount: garageController.requestImages.length,
        //               controller: PageController(viewportFraction: 0.50),
        //               itemBuilder: (context, index) {
        //                 RequestImageModel requestImageModel =
        //                     garageController.requestImages[index];
        //                 return InkWell(
        //                   onTap: () {
        //                     Get.bottomSheet(
        //                       ChooseGalleryCamera(
        //                         onTapCamera: () {
        //                           garageController
        //                               .selectRequestImageUpdateSingleImage(
        //                                   ImageSource.camera,
        //                                   userModel.userId,
        //                                   index);
        //                           Get.close(1);
        //                         },
        //                         onTapGallery: () {
        //                           garageController
        //                               .selectRequestImageUpdateSingleImage(
        //                                   ImageSource.gallery,
        //                                   userModel.userId,
        //                                   index);
        //                           Get.close(1);
        //                         },
        //                       ),
        //                       backgroundColor: userController.isDark
        //                           ? primaryColor
        //                           : Colors.white,
        //                       shape: RoundedRectangleBorder(
        //                         borderRadius: BorderRadius.only(
        //                           topLeft: Radius.circular(20),
        //                           topRight: Radius.circular(20),
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                   child: CreateRequestImageWidget(
        //                     requestImageModel: requestImageModel,
        //                     index: index,
        //                   ),
        //                 );
        //               })),
        // ),

        // const SizedBox(
        //   height: 10,
        // ),
        // Align(
        //   alignment: Alignment.center,
        //   child: ElevatedButton(
        //       onPressed: garageController.requestImages.length == 3
        //           ? null
        //           : () {
        //               Get.bottomSheet(
        //                 ChooseGalleryCamera(
        //                   onTapCamera: () {
        //                     garageController.selectRequestImage(
        //                         ImageSource.camera, userModel.userId);
        //                     Get.close(1);
        //                   },
        //                   onTapGallery: () {
        //                     garageController.selectRequestImage(
        //                         ImageSource.gallery, userModel.userId);
        //                     Get.close(1);
        //                   },
        //                 ),
        //                 backgroundColor:
        //                     userController.isDark ? primaryColor : Colors.white,
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.only(
        //                     topLeft: Radius.circular(20),
        //                     topRight: Radius.circular(20),
        //                   ),
        //                 ),
        //               );
        //             },
        //       style: TextButton.styleFrom(
        //         backgroundColor:
        //             userController.isDark ? primaryColor : Colors.white,
        //         maximumSize: Size(Get.width * 0.6, 50),
        //         minimumSize: Size(Get.width * 0.6, 50),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(7),
        //         ),
        //       ),
        //       child: Text(
        //         'Select Media ${garageController.requestImages.length}/3',
        //         style: TextStyle(
        //           color: userController.isDark ? Colors.white : primaryColor,
        //           fontSize: 16,
        //           fontFamily: 'Avenir',
        //           fontWeight: FontWeight.w800,
        //         ),
        //       )),
        // ),
        // const SizedBox(
        //   height: 10,
        // ),
      ],
    );
  }
}
