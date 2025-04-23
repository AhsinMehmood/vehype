import 'package:get/get.dart';

class AppController extends GetxController {
  RxInt selectedTab = 0.obs;

  selectTab(int index) {
    selectedTab = index.obs;
  }
}
 
 