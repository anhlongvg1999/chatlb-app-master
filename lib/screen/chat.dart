import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/screen/settingCategory.dart';
import 'package:chat_lb/screen/video.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/string.dart';
import 'package:chat_lb/widget/categoryMessageWidget.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final TargetPlatform platform;

  final TopicModel topic;

  ChatPage({Key key, this.platform, this.topic}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ScrollController _scrollController = new ScrollController();
  var _messageList = <MessageModel>[];
  var _currentPage = 1;
  var _endOfHistory = false;
  var _isLoading = false;
  bool _permissionReady = false;
  String _localPath = "";

  @override
  void initState() {
    super.initState();
    _loadHistories();
    _configDownload();
  }

  void _configDownload() async {
    _isLoading = true;
    _permissionReady = false;

    _prepare();
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

  Future<String> _findLocalPath() async {
    if (widget.platform == TargetPlatform.android) {
      return await ExtStorage.getExternalStorageDirectory();
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
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

    setState(() {
      _isLoading = false;
    });
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

  Future<void> _loadHistories() async {
    try {
      var response = await ApiService.getChatHistory(
        this.widget.topic.id,
        _currentPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        if (response.code == 200) {
          if (_currentPage == 1) {
            _messageList.addAll(response.data.objects.reversed);
            if (_messageList.isNotEmpty) {
              _moveToBottom();
            }
          } else {
            _messageList.insertAll(0, response.data.objects.reversed);
          }
          _endOfHistory = response.data.objects.length < 10;
        } else {
          _showAlertMessage(response.message);
        }
      });
    } catch (e) {
      setState(() {
        _showAlertMessage(e.toString());
      });
    }
  }

  void _moveToBottom() {
    try {
      if (!_scrollController.hasClients || _messageList.isEmpty) {
        return;
      }
      var currentMaxSize = _scrollController.position.maxScrollExtent;
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (currentMaxSize != _scrollController.position.maxScrollExtent) {
          currentMaxSize = _scrollController.position.maxScrollExtent;
          _scrollToBottom();
        } else {
          timer.cancel();
        }
      });
    } catch (ex) {
      print(ex);
    }
  }

  void _scrollToBottom() {
    try {
      if (!_scrollController.hasClients || _messageList.isEmpty) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      );
    } catch (ex) {
      print(ex);
    }
  }

  Widget getRowMessage(int position) {
    final _message = _messageList[position];
    return Align(
      alignment: Alignment(-1, 0),
      child: CategoryMessageWidget(position: position, messageModel: _message),
    );
  }

  Widget _chatView() {
    return Flexible(
      fit: FlexFit.tight,
      child: GestureDetector(
          onTap: () {},
          child: Container(
              width: MediaQuery.of(context).size.width,
              child: RefreshIndicator(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messageList.length,
                    itemBuilder: (BuildContext context, int position) {
                      return GestureDetector(
                        child: getRowMessage(position),
                        onTap: () {},
                      );
                    }),
                onRefresh: () async {
                  if (_endOfHistory) {
                    return;
                  }
                  _currentPage += 1;
                  _loadHistories();
                  return;
                },
              ))),
    );
  }

  Future<void> openFile(String link) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoPlayerPage(
                platform: widget.platform,
                name: widget.topic.name ?? "",
                urlVideo: link,
              )),
    );
  }

  Widget _bottomChat(double height) {
    final hasNoImage = widget.topic.getImageUrl()?.isEmpty ?? true;
    return hasNoImage
        ? Container(
            height: 0,
            width: double.infinity,
          )
        : Container(
            height: height * 0.25,
            width: double.infinity,
            color: Color(int.parse("0xFF7DB9FF")),
            child: InkWell(
              onTap: () async {
                if (!widget.topic.isImage()) {
                  openFile(widget.topic.getImageUrl());
                  return;
                }
                final url = widget.topic.getImageLinkUrl() ?? "";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  _showAlertMessage(
                      "${Strings.canNotOpenLink} ${widget.topic.imageUrl}");
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: FadeInImage.assetNetwork(
                              image: widget.topic.getImageUrl(),
                              placeholder: "assets/images/placeholder.jpg",
                              fit: BoxFit.cover),
                        ),
                        widget.topic.isImage()
                            ? Container()
                            : Container(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     "画像や、動作の軽い動画などを設置",
                  //     style: TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white),
                  //   ),
                  // )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_outlined),
            tooltip: 'More',
            onPressed: () async {
              final resultSettingRequest = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SettingCategoryPage(topic: widget.topic)),
              );
              if (resultSettingRequest) {
                Navigator.pop(context, true);
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Container()
            : Container(
                child: Stack(
                  fit: StackFit.loose,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _chatView(),
                        Divider(height: 1, color: Colors.black26),
                        _bottomChat(height),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
