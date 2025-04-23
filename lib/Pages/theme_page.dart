import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:vehype/Controllers/user_controller.dart';
import 'package:vehype/const.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Provider.of<UserController>(context);
    return Scaffold(
      backgroundColor: userController.isDark ? primaryColor : Colors.white,
      appBar: AppBar(
        backgroundColor: userController.isDark ? primaryColor : Colors.white,
        elevation: 0.0,
        title: Text(
          'Appearance',
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
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                userController.sameAsSystemChange();
              },
              child: Container(
                width: Get.width * 0.9,
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Same as System'),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                          activeColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          value: userController.sameAsSystem,
                          onChanged: (ss) {
                            userController.sameAsSystemChange();
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                userController.changeTheme(true);
              },
              child: Container(
                width: Get.width * 0.9,
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dark Theme'),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                          activeColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          value: userController.sameAsSystem
                              ? false
                              : userController.isDark,
                          onChanged: (ss) {
                            userController.changeTheme(true);
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                userController.changeTheme(false);
              },
              child: Container(
                width: Get.width * 0.9,
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Light Theme'),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                          activeColor: userController.isDark
                              ? Colors.white
                              : primaryColor,
                          value: userController.sameAsSystem
                              ? false
                              : userController.isDark == false,
                          onChanged: (ss) {
                            userController.changeTheme(false);
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedRadioButton(bool value) {
    bool isSelected = value;
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(2.0),
        decoration: isSelected
            ? BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 2),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
