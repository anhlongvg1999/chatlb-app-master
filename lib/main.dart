import 'dart:async';

import 'package:chat_lb/model/deeplinkModel.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:chat_lb/screen/splash.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data != null) {
    // Handle data message
    try {
      print("_firebaseMessagingBackgroundHandler: $message");
      print('Message data: ${message.data}');
      final Map<String, dynamic> data = message.data;
      if (data.containsKey('unread_number')) {
        final numberUnread = data['unread_number'];
        if (await FlutterAppBadger.isAppBadgeSupported() == true) {
          FlutterAppBadger.updateBadgeCount(numberUnread);
        }
      }
    } catch (e) {}
  }
}

/// Create a [AndroidNotificationChannel] for heads up notifications
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  enableVibration: true,
  playSound: true,
);

/// Initalize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

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
  FlutterLocalNotificationsPlugin localNotification;
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

  Future _showNotification(String title, String descipstion) async {
    var androidDetails = new AndroidNotificationDetails(
        "channelId", "Local Notification", "this is description",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotification.show(0, title.toString(), descipstion.toString(),
        generalNotificationDetails);
  }

  _configureMessaging() {
    var androidInitialize =
        new AndroidInitializationSettings('ic_notification');
    var iOSIntialize = new IOSInitializationSettings();
    var initialzationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSIntialize);
    localNotification = new FlutterLocalNotificationsPlugin();
    localNotification.initialize(initialzationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.data != null) {
        print('Message data: ${message.data}');
        final Map<String, dynamic> data = message.data;
        // if (data.containsKey('unread_number')) {
        //   final numberUnread = data['unread_number'];
        //   print('00000000000000000000' + numberUnread);
        //   int numberUnreadInt = int.parse(numberUnread);
        //   if (await FlutterAppBadger.isAppBadgeSupported() == true &&
        //       numberUnreadInt != -1) {
        //     FlutterAppBadger.updateBadgeCount(numberUnreadInt);
        //   }
        // }
        var title = data['title'].toString();
        var descipstion = data['content'].toString();
        await _showNotification(title, descipstion);
      }

      // if (message.notification != null) {
      //   print('Message also contained a notification: ${message.notification}');
      // }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  StreamSubscription _sub;

  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      print('listen link: $link');
      Provider.of<DeepLinkModel>(context, listen: false).updateDeepLink(link);
    }, onError: (err) {
      if (!mounted) return;
      print('Failed to get latest link: $err.');
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
      Provider.of<DeepLinkModel>(context, listen: false).updateDeepLink(link);
    }, onError: (err) {
      print('got err: $err');
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformStateForStringUniLinks();
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

  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
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
