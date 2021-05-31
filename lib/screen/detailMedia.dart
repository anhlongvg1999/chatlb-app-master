import 'dart:io';
import 'dart:ui';

import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/string.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';

class DetailMediaPage extends StatefulWidget {
  DetailMediaPage({Key key, this.messageModel, this.platform, this.userId})
      : super(key: key);

  final TargetPlatform platform;
  final MessageModel messageModel;
  final String userId;

  @override
  _DetailMediaPageState createState() => _DetailMediaPageState();
}

class _DetailMediaPageState extends State<DetailMediaPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                decoration: new BoxDecoration(
                  color: Colors.black,
                ),
              ),
              _contentView(),
              _headerView(),
              _footerView()
            ],
          ),
        ),
      ),
    );
  }

  Widget _contentView() {
    return Container(
      child: Hero(
        tag: "DetailPageImage",
        child: FadeInImage.assetNetwork(
          image: widget.messageModel.filesUrl(),
          placeholder: widget.messageModel.getFilePlaceHolder(),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _headerView() {
    return SizedBox(
      height: 65,
      child: Container(
        alignment: Alignment.topCenter,
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: SizedBox(
                      child: Image.asset(
                        "assets/images/ic_close_detail.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    height: 44,
                    width: 44,
                    padding: const EdgeInsets.all(8.0)),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${widget.messageModel.sender?.name}　' +
                          widget.messageModel.toFullTime(),
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                    height: 44,
                  )),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 44,
                  width: 44,
                ))
          ],
        ),
      ),
    );
  }

  Widget _footerView() {
    return SizedBox(
      height: 65,
      child: Container(
        alignment: Alignment.bottomRight,
        child: Row(
          children: <Widget>[
            Spacer(),
            InkWell(
              onTap: () {

              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: SizedBox(
                      child: Image.asset(
                        "assets/images/ic_download_file_white.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    height: 44,
                    width: 44,
                    padding: const EdgeInsets.all(8.0)),
              ),
            )
          ],
        ),
      ),
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
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
