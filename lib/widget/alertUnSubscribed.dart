import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AlertUnSubscribedBox extends StatefulWidget {

  final TopicModel topic;

  const AlertUnSubscribedBox({Key key, this.topic}) : super(key: key);

  @override
  _AlertUnSubscribedBoxState createState() => _AlertUnSubscribedBoxState();
}

class _AlertUnSubscribedBoxState extends State<AlertUnSubscribedBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
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
      setState(() {
        if (response.code != 200) {
          _showAlertMessage(response.message);
          return;
        }
        Navigator.pop(context, true);
      });
    } catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
      _showAlertMessage(Strings.systemError);
    }
  }

  contentBox(context) {
    final nameTopic = widget.topic.name ?? "";
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 8),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "$nameTopicから\n本当に退会してよろしいですか？",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.primaryTextColor)),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "※退会したスレッドからは、\nメッセージを一切受け取れなくなります。\n※退会したスレッドは、\n「設定」から再入会することが可能です。",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.center,
                child: FlatButton(
                  onPressed: () {
                    _leaveTopic();
                  },
                  padding: EdgeInsets.only(left: 32, right: 32, top: 4, bottom: 4),
                  child: Text(
                    "退会する",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
