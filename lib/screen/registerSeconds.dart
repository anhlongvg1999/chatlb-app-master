import 'package:chat_lb/model/socketResponse.dart';
import 'package:chat_lb/screen/login.dart';
import 'package:chat_lb/screen/registerFinish.dart';
import 'package:chat_lb/service/socketService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:flutter/material.dart';

import 'forgotPassword.dart';

class RegisterSecondsPage extends StatefulWidget {
  final TargetPlatform platform;
  final String email;

  RegisterSecondsPage({Key key, this.platform, this.email}) : super(key: key);

  @override
  _RegisterSecondsPageState createState() => _RegisterSecondsPageState();
}

class _RegisterSecondsPageState extends State<RegisterSecondsPage> {
  Widget _messageAlert() {
    return Container(
        alignment: Alignment.center,
        child: Text("登録確認メールを送信しました。\nメール内URLをクリックすると登録が完了します。",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Color(AppColors.primaryTextColor))));
  }

  _gotoForgotPassword() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ForgotPasswordPage(
                  platform: widget.platform,
                )),
        (route) => false);
  }

  Widget _forgotPassword() {
    return InkWell(
        onTap: () {
          _gotoForgotPassword();
        },
        child: Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'パスワードを忘れた場合は',
              style: TextStyle(
                  fontSize: 14, color: Color(AppColors.primaryTextColor)),
              children: <TextSpan>[
                TextSpan(
                    text: 'こちら',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue)),
              ],
            ),
          ),
        ));
  }

  _gotoLogin() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  platform: widget.platform,
                )),
        (route) => false);
  }

  Widget _loginUser() {
    return InkWell(
        onTap: () {
          _gotoLogin();
        },
        child: Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'アカウント登録済みの場合は',
              style: TextStyle(
                  fontSize: 14, color: Color(AppColors.primaryTextColor)),
              children: <TextSpan>[
                TextSpan(
                    text: 'こちら',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue)),
              ],
            ),
          ),
        ));
  }

  Widget _logoTitle() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "アカウント登録",
        style:
            TextStyle(fontSize: 24, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SocketService.shared().onSocketMessage = _onSocketMessage;
  }

  void _onSocketMessage(SocketResponse model) {
    setState(() {
      if (model.success && this.widget.email == model.email) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterFinishPage(
                      platform: widget.platform,
                      email: model.email,
                    )),
            (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("アカウント"),
          centerTitle: true,
        ),
        body: Container(
            height: height,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _logoTitle(),
                    SizedBox(height: 40),
                    _messageAlert(),
                    SizedBox(height: 50),
                    _loginUser(),
                    SizedBox(height: 10),
                    _forgotPassword()
                  ],
                ),
              ),
            )));
  }
}
