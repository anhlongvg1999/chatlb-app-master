import 'package:flutter/material.dart';

class DeepLinkModel extends ChangeNotifier {

  String _deepLink;

  String get deepLink => _deepLink;

  void updateDeepLink(String value) {
    _deepLink = value;
    notifyListeners();
  }
}