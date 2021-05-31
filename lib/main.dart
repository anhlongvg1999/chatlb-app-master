import 'dart:async';

import 'package:chat_lb/model/deeplinkModel.dart';
import 'package:chat_lb/screen/splash.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("_firebaseMessagingBackgroundHandler: $message");
  if (message.data != null) {
    // Handle data message
    try {
      print('BackgroundHandler Message data: ${message.data}');
      final Map<String, dynamic> data = message.data;
      if (data.containsKey('unread_number')) {
        final numberUnread = data['unread_number'] ?? 0;
        if (await FlutterAppBadger.isAppBadgeSupported() == true) {
          FlutterAppBadger.updateBadgeCount(numberUnread);
        }
      }

      if (data.containsKey('message_id')) {
        final messageId = data['message_id'];
        if (messageId.isEmpty) {
          return;
        }
        var response = await ApiService.receiveMessage(messageId);
        if (response.code == 200) {
          print("receive message success: " + messageId);
        } else {
          print("receive message fail: " + messageId);
        }
      }
    } catch (e) {}
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => DeepLinkModel(),
      child: MyApp(),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  _requestPushPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // authorized: The user granted permission.
    // denied: The user denied permission.
    // notDetermined: The user has not yet chosen whether to grant permission.
    // provisional: The user granted provisional permission
    print('User granted permission: ${settings.authorizationStatus}');
  }

  _configureMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        Fluttertoast.showToast(
            msg: message.notification.body,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }

      if (message.data != null) {
        print('onMessage Message data: ${message.data}');
        final Map<String, dynamic> data = message.data;
        if (data.containsKey('unread_number')) {
          final numberUnread = data['unread_number'] ?? 0;
          if (await FlutterAppBadger.isAppBadgeSupported() == true) {
            FlutterAppBadger.updateBadgeCount(numberUnread);
          }
        }

        if (data.containsKey('topic_id')) {
          final topicId = data['topic_id'];
          Provider.of<DeepLinkModel>(context, listen: false)
              .updateNotificationOpenApp(topicId);
        }

        if (data.containsKey('message_id')) {
          final messageId = data['message_id'];
          if (messageId.isEmpty) {
            return;
          }
          var response = await ApiService.receiveMessage(messageId);
          if (response.code == 200) {
            print("receive message success: " + messageId);
          } else {
            print("receive message fail: " + messageId);
          }
        }
      }

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      if (message.data != null) {
        print('MessageOpened Message data: ${message.data}');
        final Map<String, dynamic> data = message.data;
        if (data.containsKey('unread_number')) {
          final numberUnread = data['unread_number'] ?? 0;
          if (await FlutterAppBadger.isAppBadgeSupported() == true) {
            FlutterAppBadger.updateBadgeCount(numberUnread);
          }
        }
        if (data.containsKey('topic_id')) {
          final topicId = data['topic_id'];
          Provider.of<DeepLinkModel>(context, listen: false)
              .updateTopicNotification(topicId);
        }

        if (data.containsKey('message_id')) {
          final messageId = data['message_id'];
          if (messageId.isEmpty) {
            return;
          }
          var response = await ApiService.receiveMessage(messageId);
          if (response.code == 200) {
            print("receive message success: " + messageId);
          } else {
            print("receive message fail: " + messageId);
          }
        }
      }
    });

    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage?.data != null) {
      print('initialMessage Message data: ${initialMessage.data}');
      final Map<String, dynamic> data = initialMessage.data;
      if (data.containsKey('topic_id')) {
        final topicId = data['topic_id'];
        Provider.of<DeepLinkModel>(context, listen: false)
            .setTopicNotification(topicId);
      }
    }
  }

  void _initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      print('deepLink uri: ' + deepLink.path + ' --- ' + deepLink.query);
      if (deepLink.query != null && deepLink.query.isNotEmpty) {
        Provider.of<DeepLinkModel>(context, listen: false)
            .updateDeepLink(deepLink.query);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      print('deepLink: ' + deepLink.path + ' --- ' + deepLink.query);
      if (deepLink.query != null && deepLink.query.isNotEmpty) {
        Provider.of<DeepLinkModel>(context, listen: false)
            .updateDeepLink(deepLink.query);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
    _configureMessaging();
    _requestPushPermission();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Registered: $token");
      AppPrefs.share().savePushToken(token);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Strings.appName,
        theme: ThemeData(
          primaryColor: Color(AppColors.primaryColor),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyAppPage(platform: platform),
        builder: EasyLoading.init());
  }
}

class MyAppPage extends StatefulWidget {
  final TargetPlatform platform;

  MyAppPage({Key key, this.platform}) : super(key: key);

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new SplashPage(platform: widget.platform);
  }
}
