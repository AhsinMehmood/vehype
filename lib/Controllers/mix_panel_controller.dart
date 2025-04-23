import 'dart:developer';

import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixPanelController extends GetxController {
  late Mixpanel _mixpanel;

  @override
  void onInit() {
    super.onInit();
    _initMixPanel();
  }

  void identifyUser(String userId) {
    _mixpanel.identify(userId);
  }

  Future<void> _initMixPanel() async {
    // Clear shared preferences
    _mixpanel = await Mixpanel.init('c40aeb8e3a8f1030b811314d56973f5a',
        trackAutomaticEvents: true);
    // enable debug logs post-init
    _mixpanel.setLoggingEnabled(false);
    // log('sksjkdl');
    _mixpanel.track('initialize mix panel');
    _mixpanel.flush();
  }

  void trackEvent(
      {required String eventName, required Map<String, dynamic> data}) {
    _mixpanel.track(eventName, properties: data);
    _mixpanel.flush();
  }
}
