import 'package:flutter/material.dart';

class DeepLinkModel extends ChangeNotifier {

  String _deepLink;

  String get deepLink => _deepLink;

  bool _refreshTopic;

  bool get refreshTopic => _refreshTopic;

  String _topicNotification;

  String get topicNotification => _topicNotification;

  String _messageOpenApp;

  String get messageOpenApp => _messageOpenApp;

  void updateDeepLink(String value) {
    _deepLink = value;
    notifyListeners();
  }

  void hasRefreshTopic(bool value) {
    _refreshTopic = value;
    notifyListeners();
  }

  void updateTopicNotification(String value) {
    _topicNotification = value;
    notifyListeners();
  }

  void setTopicNotification(String value) {
    _topicNotification = value;
    notifyListeners();
  }

  void updateNotificationOpenApp(String value) {
    _topicNotification = "";
    _messageOpenApp = value;
    notifyListeners();
  }

  void setOpenNotification(String value) {
    _messageOpenApp = value;
    notifyListeners();
  }
}