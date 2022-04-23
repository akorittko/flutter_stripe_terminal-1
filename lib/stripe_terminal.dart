library stripe_terminal;

import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

part "utils/strings.dart";
part "models/reader.dart";

class StripeTerminal {
  static const MethodChannel _channel = MethodChannel('stripe_terminal');
  Future<String> Function() fetchToken;
  StripeTerminal({
    // A callback that returns a Future that resolves to a connection token from your backend
    required this.fetchToken,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "requestConnectionToken":
          return fetchToken();
        case "onReadersFound":
          List readers = call.arguments;
          _readerStreamController.add(
            readers.map<StripeReader>((e) => StripeReader.fromJson(e)).toList(),
          );
          return fetchToken();
        default:
          return null;
      }
    });
    _channel.invokeMethod("init");
  }

  Future test() async {
    return _channel.invokeMethod("test");
  }

  final StreamController<List<StripeReader>> _readerStreamController =
      StreamController<List<StripeReader>>();
  Stream<List<StripeReader>> discoverReaders() {
    _channel.invokeMethod("discoverReaders#start");
    _readerStreamController.onCancel = () {
      _channel.invokeMethod("discoverReaders#stop");
      _readerStreamController.close();
    };
    return _readerStreamController.stream;
  }
}
