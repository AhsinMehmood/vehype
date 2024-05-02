import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/Models/user_model.dart';
import 'package:vehype/const.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  bool agreeToReverify = false;
  bool cancelSubs = false;
  TextEditingController reason = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserController>(context).userModel!;
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            // size: 29,
            color: userController.isDark ? Colors.white : primaryColor,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Delete Account',
          style: TextStyle(
              fontFamily: 'Avenir',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: userController.isDark ? Colors.white : primaryColor
              // color: Colors.black,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Text(
                'Thank you for trying our app!',
                style: TextStyle(
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                'Please tell us why you want to delete your account and any feedback for improvement.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Avenir',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  controller: reason,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onTapOutside: (s) {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  onChanged: (u) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'You could add a guestbook feature.',
                    hintStyle: TextStyle(
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      // color: Colors.grey,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              // const SizedBox(
              //   height: 10,
              // ),

              SizedBox(
                height: Get.height * 0.20,
              ),
              ElevatedButton(
                  onPressed: reason.text.length < 3
                      ? null
                      : () {
                          UserController().deleteUserAccount(userModel.userId);
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      maximumSize: Size(Get.width * 0.8, 60),
                      minimumSize: Size(Get.width * 0.8, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      )),
                  child: const Text(
                    'Delete account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.w800,
                    ),
                  )),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
