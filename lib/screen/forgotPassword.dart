import 'package:chat_lb/screen/login.dart';
import 'package:chat_lb/screen/registerFirst.dart';
import 'package:chat_lb/screen/registerSeconds.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ForgotPasswordPage extends StatefulWidget {
  final TargetPlatform platform;

  ForgotPasswordPage({Key key, this.platform}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _textEmailController = TextEditingController();

  String _errorEmailMessage = "";

  bool isSendEmail = false;

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

  Widget _emailIDInfo() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.topLeft,
            child: Text(_textEmailController.text,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14, color: Color(AppColors.primaryTextColor))),
          ),
          Divider(
              color: Color(AppColors.primaryColor),
              height: 1,
              thickness: 1,
              endIndent: 0),
        ],
      ),
    );
  }

  Future<void> _forgotEmail() async {
    final email = _textEmailController.text;
    FocusScope.of(context).unfocus();
    if (email.isNotEmpty) {
      final params = {
        'email': email
      };
      EasyLoading.show();
      final response = await ApiService.forgot(params);
      setState(() {
        EasyLoading.dismiss();
        if (response.code == 200) {
          isSendEmail = true;
        } else {
          _errorEmailMessage = response.message ?? Strings.systemError;
        }
      });
    } else {
      _errorEmailMessage = "Please input email";
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _errorEmailMessage = "";
        _forgotEmail();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("パスワードを再発行",
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

  Widget _forgotPassword() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'メール内URLをクリックして \n 新しいパスワードを設定してください。',
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 14, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  _gotoRegister() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterFirstPage(
                  platform: widget.platform,
                )),
        (route) => false);
  }

  Widget _registerUser() {
    return InkWell(
        onTap: () {
          _gotoRegister();
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
        "新しいパスワードを \n登録アドレスにお送りします",
        textAlign: TextAlign.center,
        style:
            TextStyle(fontSize: 24, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        isSendEmail ? _emailIDInfo() : _entryFieldID(),
        _errorEmailView()],
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
                    isSendEmail ? _forgotPassword() : _submitButton(),
                    SizedBox(height: 20),
                    !isSendEmail ? _registerUser() : Container(),
                  ],
                ),
              ),
            )));
  }
}
