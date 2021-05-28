import 'dart:async';
import 'dart:core';

import 'package:chat_lb/screen/home.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/color.dart';

import 'chat.dart';
import 'login.dart';

class SplashPage extends StatefulWidget {
  final TargetPlatform platform;

  const SplashPage({Key key, this.platform}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void _startFirstPage() async {
    bool isLogin = await AppPrefs.share().isLogin();
    Widget firstPage = isLogin
        ? new HomePage(platform: widget.platform)
        : new LoginPage(platform: widget.platform);
    Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (BuildContext context) => firstPage));
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      _startFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new InkWell(
            child: new Stack(fit: StackFit.expand, children: <Widget>[
      Container(
        decoration: new BoxDecoration(
          color: Color(AppColors.primaryColor),
        ),
      ),
      Container(
          padding: const EdgeInsets.only(left: 32, right: 32),
          alignment: Alignment.center,
          child: Text(Strings.appName,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)))
    ])));
  }
}
