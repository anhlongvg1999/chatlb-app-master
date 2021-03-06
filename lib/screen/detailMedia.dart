import 'dart:io';
import 'dart:ui';

import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/string.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool _permissionReady = false;
  String _localPath = "";

  @override
  void initState() {
    super.initState();
    _configDownload();
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
                      '${widget.messageModel.sender()?.name}???' +
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
                _onTapDownload();
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

  void _configDownload() async {
    _permissionReady = false;
    _prepare();
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

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    _permissionReady = await _checkPermission();

    _localPath = (await _findLocalPath()) +
        Platform.pathSeparator +
        Strings.downloadFolder;

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    if (widget.platform == TargetPlatform.android) {
      return await ExtStorage.getExternalStorageDirectory();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  void _onTapDownload() {
    if (!_permissionReady) {
      _checkPermission();
      return;
    }
    _requestDownload(
        widget.messageModel.downloadLink(), widget.messageModel.filesName());
  }

  void _requestDownload(String link, String fileName) async {
    if (EasyLoading.isShow) {
      return;
    }
    EasyLoading.show();
    final status = await ApiService.downloadFile(
        Uri.encodeFull(link), fileName, _localPath);
    setState(() {
      EasyLoading.dismiss();
      if (status) {
        _showAlertMessage(Strings.downloadSuccess);
      } else {
        _showAlertMessage(Strings.downloadFailed);
      }
    });
  }
}
