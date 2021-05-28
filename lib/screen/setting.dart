import 'package:chat_lb/model/userModel.dart';
import 'package:chat_lb/screen/changePassword.dart';
import 'package:chat_lb/screen/changeSubscribed.dart';
import 'package:chat_lb/screen/confirmChangeEmail.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

enum SingingCharacter { ON, OFF }

class _SettingPageState extends State<SettingPage> {
  SingingCharacter _pushNotification = SingingCharacter.ON;
  final _textEmailController = TextEditingController();
  String _messageInputEmailError = "";
  UserModel _userModel;

  Widget _settingPushTitle() {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        "通知設定",
        style:
            TextStyle(fontSize: 18, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _settingPush() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(children: [
            Radio(
              value: SingingCharacter.ON,
              groupValue: _pushNotification,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _pushNotification = value;
                  _onSettingReceiveNotification(true);
                });
              },
            ),
            Text('ON'),
          ]),
          Row(children: [
            Radio(
              value: SingingCharacter.OFF,
              groupValue: _pushNotification,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _pushNotification = value;
                  _onSettingReceiveNotification(false);
                });
              },
            ),
            Text('OFF'),
          ]),
        ],
      ),
    );
  }

  Widget _messageAlertSettingPush() {
    return Container(
        alignment: Alignment.center,
        child: Text("アプリ全体の通知設定になります。",
            style: TextStyle(
                fontSize: 12, color: Color(AppColors.primaryTextColor))));
  }

  Widget _settingUnsubscribedTitle() {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        "退会したスレッド",
        style:
            TextStyle(fontSize: 18, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _settingUnsubscribedButton() {
    return FlatButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChangeSubscribedPage()));
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("退会リストを確認する",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
      textColor: Color(AppColors.primaryTextColor),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Color(AppColors.primaryColor),
              width: 1,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _settingEmailTitle() {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        "メールアドレス",
        style:
            TextStyle(fontSize: 18, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _entryEmailID() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.topLeft,
            child: Text(_userModel?.email ?? "",
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

  Widget _entryNewEmailID() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textEmailController,
          obscureText: false,
          style:
              TextStyle(fontSize: 14, color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "新しいメールアドレス",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Widget _messageAlertEmailSetting() {
    return Container(
        alignment: Alignment.center,
        child: Text("新しいメールアドレスに確認メールが送信されます。\n確認メール内のURLをクリックすると変更完了です。",
            style: TextStyle(
                fontSize: 12, color: Color(AppColors.primaryTextColor))));
  }

  Widget _errorEmailView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _messageInputEmailError.isNotEmpty
          ? Text(
              _messageInputEmailError,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  Widget _changeEmailButton() {
    return FlatButton(
      onPressed: () async {
        final newEmail = _textEmailController.text;
        if (newEmail.isEmpty) {
          _messageInputEmailError = Strings.pleaseInputEmail;
        } else {
          _messageInputEmailError = "";
          final resultChangeEmail = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConfirmChangeEmailPage(
                        email: newEmail,
                      )));
          if (resultChangeEmail) {
            setState(() {
              _textEmailController.text = "";
              _userModel.email = newEmail;
            });
          }
        }
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("メールアドレスを変更する",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
      textColor: Color(AppColors.primaryTextColor),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Color(AppColors.primaryColor),
              width: 1,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _settingPasswordTitle() {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        "パスワード",
        style:
            TextStyle(fontSize: 18, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _entryPasswordID() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.topLeft,
            child: Text("現在のパスワード",
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

  Widget _messageAlertPasswordSetting() {
    return Container(
        alignment: Alignment.center,
        child: Text("パスワードを変更したい場合は\n 現在のパスワードを入力してください。",
            style: TextStyle(
                fontSize: 12, color: Color(AppColors.primaryTextColor))));
  }

  Widget _changePasswordButton() {
    return FlatButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ChangePasswordPage()));
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("パスワードを変更する",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
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

  @override
  void initState() {
    super.initState();
    _getUserSetting();
  }

  Future<void> _showAlertMessage(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Strings.appName),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.ok),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  _getUserSetting() async {
    final user = await AppPrefs.share().getCurrentUser();
    setState(() {
      _userModel = user;
      _pushNotification =
          user.receiveNotification ? SingingCharacter.ON : SingingCharacter.OFF;
    });
  }

  Future<void> _onSettingReceiveNotification(bool newReceive) async {
    EasyLoading.show();
    try {
      final params = {"receive_notification": newReceive};
      final response = await ApiService.updateUser(params);
      if (response.code != 200) {
        _showAlertMessage(response.message);
        setState(() {
          _pushNotification =
              !newReceive ? SingingCharacter.ON : SingingCharacter.OFF;
        });
        return;
      }
    } catch (e) {
      print(e.toString());
      _pushNotification =
          !newReceive ? SingingCharacter.ON : SingingCharacter.OFF;
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("設定"),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 32),
                _settingPushTitle(),
                SizedBox(height: 10),
                _settingPush(),
                SizedBox(height: 10),
                _messageAlertSettingPush(),
                SizedBox(height: 24),
                _settingUnsubscribedTitle(),
                SizedBox(height: 10),
                _settingUnsubscribedButton(),
                SizedBox(height: 24),
                _settingEmailTitle(),
                SizedBox(height: 10),
                _entryEmailID(),
                _entryNewEmailID(),
                _errorEmailView(),
                SizedBox(height: 10),
                _messageAlertEmailSetting(),
                SizedBox(height: 10),
                _changeEmailButton(),
                SizedBox(height: 24),
                _settingPasswordTitle(),
                SizedBox(height: 10),
                _entryPasswordID(),
                SizedBox(height: 10),
                _messageAlertPasswordSetting(),
                SizedBox(height: 10),
                _changePasswordButton(),
                SizedBox(height: 32),
                _faqAndQA(),
                SizedBox(height: 24),
              ],
            ),
          ),
        )));
  }
}
