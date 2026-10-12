export 'package:ar_flutter_plugin_plus/widgets/ar_view.dart';

import 'dart:async';

import 'package:flutter/services.dart';

class ArFlutterPluginPlus {
  static const MethodChannel _channel =
      const MethodChannel('ar_flutter_plugin_plus');

  /// Private constructor to prevent accidental instantiation of the Plugin using the implicit default constructor
  ArFlutterPluginPlus._();

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
