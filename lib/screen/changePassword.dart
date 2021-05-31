import 'package:chat_lb/screen/login.dart';
import 'package:chat_lb/screen/registerFirst.dart';
import 'package:chat_lb/screen/registerSeconds.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _textChangeController = TextEditingController();
  final _textConfirmController = TextEditingController();

  String _errorChangeMessage = "";
  String _errorConfirmMessage = "";

  bool isChangePassSuccess = false;

  Widget _changePassTitle() {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        "パスワード",
        style:
            TextStyle(fontSize: 18, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _entryFieldPassword() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textChangeController,
          obscureText: false,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "新しいパスワード",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Widget _entryFieldChangePassword() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textConfirmController,
          obscureText: false,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "新しいパスワード（確認）",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Widget _messageAlert() {
    return Container(
        alignment: Alignment.center,
        child: Text("パスワードを変更したい場合はすべて入力してください。",
            style: TextStyle(
                fontSize: 12, color: Color(AppColors.primaryTextColor))));
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    try {
      final password = _textChangeController.text;
      final confirmPassword = _textConfirmController.text;
      if (password.isEmpty) {
        setState(() {
          _errorChangeMessage = Strings.pleaseInputPassword;
        });
        return;
      }
      if (confirmPassword.isEmpty) {
        setState(() {
          _errorConfirmMessage = Strings.pleaseInputPassword;
        });
        return;
      }

      if (!password.isValidPassword()) {
        setState(() {
          _errorChangeMessage = Strings.passwordWrongFormat;
          _errorConfirmMessage = "";
        });
        return;
      }
      if (!confirmPassword.isValidPassword()) {
        setState(() {
          _errorConfirmMessage = Strings.passwordWrongFormat;
          _errorChangeMessage = "";
        });
        return;
      }

      if (password != confirmPassword) {
        setState(() {
          _errorConfirmMessage = Strings.passwordNotMath;
        });
        return;
      }
      EasyLoading.show();
      final params = {"password": password};
      final response = await ApiService.updateUser(params);
      setState(() {
        EasyLoading.dismiss();
      });
      if (response.code != 200) {
        _errorChangeMessage = response.message;
        return;
      }
      AppPrefs.share().savePassword(password);
      setState(() {
        isChangePassSuccess = true;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        EasyLoading.dismiss();
      });
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _errorChangeMessage = "";
        _errorConfirmMessage = "";
        _changePassword();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("変更する",
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

  Widget _faqAndQA() {
    return InkWell(
        onTap: () {},
        child: Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: "※ご質問、ご要望は",
              style: TextStyle(
                  fontSize: 14, color: Color(AppColors.primaryTextColor)),
              children: <TextSpan>[
                TextSpan(
                    text: 'こちら',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue)),
                TextSpan(
                    text: 'から',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.primaryTextColor))),
              ],
            ),
          ),
        ));
  }

  Widget _errorChangeView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorChangeMessage.isNotEmpty
          ? Text(
              _errorChangeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  Widget _errorConfirmView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorConfirmMessage.isNotEmpty
          ? Text(
              _errorConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  Widget _changePasswordSuccess(double height) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: height * 0.2),
          Container(
              alignment: Alignment.center,
              child: Text("パスワードを変更しました。",
                  style: TextStyle(
                      fontSize: 16, color: Color(AppColors.primaryTextColor)))),
          SizedBox(height: 40),
          FlatButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
            child: Text("戻る",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            textColor: Colors.white,
            color: Color(int.parse("0xFF91AAFF")),
          )
        ],
      ),
    );
  }

  Widget _changePasswordView(double height) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 32),
            _changePassTitle(),
            SizedBox(height: 24),
            _entryFieldPassword(),
            _errorChangeView(),
            _entryFieldChangePassword(),
            _errorConfirmView(),
            SizedBox(height: 10),
            _messageAlert(),
            SizedBox(height: 24),
            _submitButton(),
            SizedBox(height: height * 0.3),
            _faqAndQA()
          ],
        ),
      ),
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
          title: Text("パスワード"),
          centerTitle: true,
        ),
        body: Container(
            child: isChangePassSuccess
                ? _changePasswordSuccess(height)
                : _changePasswordView(height)));
  }
}
