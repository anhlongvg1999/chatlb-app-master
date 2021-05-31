import 'dart:async';
import 'dart:ui';

import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/screen/settingCategory.dart';
import 'package:chat_lb/screen/video.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/string.dart';
import 'package:chat_lb/widget/categoryMessageWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  _getUnRead() async {
    try {
      final response = await ApiService.getUnread();
      if (response.code == 200) {
        final _number = response.data;
        if (await FlutterAppBadger.isAppBadgeSupported() == true) {
          FlutterAppBadger.updateBadgeCount(_number);
        }
      }
    } catch (e) {
      print(e.toString());
    }
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
      EasyLoading.show();
      var response = await ApiService.getChatHistory(
        this.widget.topic.id,
        _currentPage,
      );
      if (!mounted) {
        return;
      }
      EasyLoading.dismiss();
      _getUnRead();
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
        if (!_scrollController.hasClients || _messageList.isEmpty) {
          timer.cancel();
          return;
        }
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
      alignment: Alignment.topLeft,
      child: CategoryMessageWidget(position: position, messageModel: _message),
    );
  }

  _clickMessage(int position) async {
    try {
      final messageId = _messageList[position].id ?? "";
      if (messageId.isEmpty) {
        return;
      }
      var response = await ApiService.clickMessage(messageId);
      if (response.code == 200) {
        print("click message success: " + messageId);
      } else {
        print("click message faid: " + messageId);
      }
    } catch (e) {
      setState(() {
        _showAlertMessage(e.toString());
      });
    }
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
                        onTap: () {
                          _clickMessage(position);
                        },
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
            width: MediaQuery.of(context).size.width,
          )
        : Container(
            height: height * 0.25,
            width: MediaQuery.of(context).size.width,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FadeInImage.assetNetwork(
                      height: height * 0.25,
                      width: MediaQuery.of(context).size.width,
                      image: !widget.topic.isImage()
                          ? widget.topic.getThumbUrl()
                          : widget.topic.getImageUrl(),
                      placeholder: "assets/images/placeholder.jpg",
                      fit: BoxFit.cover),
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
        child: Container(
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
