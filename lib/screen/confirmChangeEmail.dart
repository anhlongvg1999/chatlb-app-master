import 'package:chat_lb/screen/login.dart';
import 'package:chat_lb/screen/registerFirst.dart';
import 'package:chat_lb/screen/registerSeconds.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ConfirmChangeEmailPage extends StatefulWidget {
  final String email;

  ConfirmChangeEmailPage({Key key, this.email}) : super(key: key);

  @override
  _ConfirmChangeEmailPageState createState() => _ConfirmChangeEmailPageState();
}

class _ConfirmChangeEmailPageState extends State<ConfirmChangeEmailPage> {

  String _errorChangeMessage = "";

  Widget _entryFieldEmail() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.topLeft,
            child: Text(widget.email,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 14, color: Color(AppColors.primaryTextColor))),
          ),
          Divider(
              color: Color(AppColors.primaryColor),
              height: 1,
              thickness: 1,
              endIndent: 0),
          _errorEmailView()
        ],
      ),
    );
  }

  Widget _errorEmailView() {
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

  Widget _messageAlert() {
    return Container(
        alignment: Alignment.center,
        child: Text("新しいメールアドレスに\n確認メールを送信しました。",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Color(AppColors.primaryTextColor))));
  }

  Future<void> _changeEmail() async {
    FocusScope.of(context).unfocus();
    EasyLoading.show();
    try {
      final params = {"email": widget.email};
      final response = await ApiService.updateUser(params);
      if (response.code != 200) {
        _errorChangeMessage = response.message;
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _errorChangeMessage = "";
        _changeEmail();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
      child: Text("完了",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      textColor: Colors.white,
      color: Color(int.parse("0xFF91AAFF")),
    );
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

  Widget _changeEmailView(double height) {
    return Container(
      height: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: height * 0.2),
            _entryFieldEmail(),
            _errorChangeView(),
            SizedBox(height: 10),
            _messageAlert(),
            SizedBox(height: 24),
            _submitButton(),
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
            child: _changeEmailView(height)));
  }
}
