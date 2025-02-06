import 'package:flutter/services.dart';

class PlatformService {
  static const platform = MethodChannel('app.channel.shared.data');

  static Future<bool> verifyNetworkTimeAndTimeZone() async {
    try {
      final bool isValidConfiguration = await platform.invokeMethod('verifyNetworkTimeAndTimeZone');

      return isValidConfiguration;
    } on PlatformException {
      
      return false;
    }
  }
}
