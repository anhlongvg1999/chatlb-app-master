import 'package:chat_lb/screen/login.dart';
import 'package:chat_lb/screen/registerSeconds.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/socketService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'forgotPassword.dart';

class RegisterFirstPage extends StatefulWidget {
  final TargetPlatform platform;

  RegisterFirstPage({Key key, this.platform}) : super(key: key);

  @override
  _RegisterFirstPageState createState() => _RegisterFirstPageState();
}

class _RegisterFirstPageState extends State<RegisterFirstPage> {
  final _textEmailController = TextEditingController();

  String _errorEmailMessage = "";

  Widget _entryFieldID() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textEmailController,
          obscureText: false,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "メールアドレス",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Future<void> _registerEmail() async {
    final email = _textEmailController.text;
    FocusScope.of(context).unfocus();
    if (email.isNotEmpty) {
      if (!email.isValidEmail()) {
        _errorEmailMessage = Strings.pleaseInputEmail;
        return;
      }
      final socketId = SocketService.shared().getSocketId();
      final params = {
        'email': email,
        'socket_id': socketId,
      };
      EasyLoading.show();
      final response = await ApiService.registerFirst(params);
      setState(() {
        EasyLoading.dismiss();
        if (response.code == 200) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RegisterSecondsPage(
                      platform: widget.platform,
                      email: email,
                    )),
          );
        } else {
          _errorEmailMessage = response.message ?? Strings.systemError;
        }
      });
    } else {
      _errorEmailMessage = Strings.noInputEmail;
    }
}

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _errorEmailMessage = "";
        _registerEmail();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("新規登録",
          style: TextStyle(color: Color(AppColors.primaryTextColor))),
      textColor: Color(AppColors.primaryTextColor),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Color(AppColors.primaryColor),
              width: 1,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8)),
    );
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

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[_entryFieldID(), _errorEmailView()],
    );
  }

  Widget _errorEmailView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorEmailMessage.isNotEmpty
          ? Text(
              _errorEmailMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  @override
  void initState() {
    SocketService.shared().connect();
    super.initState();
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
                    SizedBox(height: 30),
                    _emailPasswordWidget(),
                    SizedBox(height: 20),
                    _submitButton(),
                    SizedBox(height: 20),
                    _loginUser(),
                    SizedBox(height: 10),
                    _forgotPassword()
                  ],
                ),
              ),
            )));
  }
}
