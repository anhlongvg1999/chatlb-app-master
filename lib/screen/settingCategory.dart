import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SettingCategoryPage extends StatefulWidget {

  final TopicModel topic;

  SettingCategoryPage({Key key, this.topic}) : super(key: key);

  @override
  _SettingCategoryPageState createState() => _SettingCategoryPageState();
}

enum SingingCharacter { ON, OFF }

class _SettingCategoryPageState extends State<SettingCategoryPage> {
  SingingCharacter _character = SingingCharacter.ON;

  Widget _messageTitle() {
    return Container(
        alignment: Alignment.topLeft,
        child: Text("スレッドから退会",
            style: TextStyle(
                fontSize: 18, color: Color(AppColors.primaryTextColor))));
  }

  Widget _messageAlert() {
    return Container(
        alignment: Alignment.topLeft,
        child: Text(
            "※退会したスレッドからは、メッセージを一切受け取れなくなります。\n※退会したスレッドは、「設定」から再入会することが可能です。",
            style: TextStyle(
                fontSize: 10, color: Color(AppColors.primaryTextColor))));
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

  Future<void> _onSettingReceiveNotification(bool newReceive) async {
    try {
      EasyLoading.show();
      final params = {"receive": newReceive, "topic_id": widget.topic.id};
      final response = await ApiService.updateReceiveNotification(params);
      setState(() {
        EasyLoading.dismiss();
      });
      if (response.code != 200) {
        _showAlertMessage(response.message);
        setState(() {
          _character = !newReceive ? SingingCharacter.ON : SingingCharacter.OFF;
        });
        return;
      }
      setState(() {
        widget.topic.receive = newReceive;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        EasyLoading.dismiss();
        _character = !newReceive ? SingingCharacter.ON : SingingCharacter.OFF;
      });
    }
  }

  _leaveTopic() async {
    try {
      EasyLoading.show();
      final params = {
        "subscribe": false,
        "topic_ids": [
          widget.topic.id
        ]
      };
      final response = await ApiService.subscribe(params);
      setState(() {
        EasyLoading.dismiss();
      });
      if (response.code != 200) {
        _showAlertMessage(response.message);
        return;
      }
      setState(() {
        Navigator.pop(context, true);
      });
    } catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
      _showAlertMessage(Strings.systemError);
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _leaveTopic();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("退会する",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      textColor: Colors.white,
      color: Colors.red,
    );
  }

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
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _character = value;
                  _onSettingReceiveNotification(true);
                });
              },
            ),
            Text('ON'),
          ]),
          Row(children: [
            Radio(
              value: SingingCharacter.OFF,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                setState(() {
                  _character = value;
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

  @override
  void initState() {
    super.initState();
    _character = widget.topic.receive ? SingingCharacter.ON : SingingCharacter.OFF;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("スレッド設定"),
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
                SizedBox(height: 32),
                _messageTitle(),
                SizedBox(height: 10),
                _messageAlert(),
                SizedBox(height: 32),
                _submitButton()
              ],
            ),
          ),
        )));
  }
}
