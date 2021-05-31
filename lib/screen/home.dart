import 'dart:async';

import 'package:chat_lb/model/deeplinkModel.dart';
import 'package:chat_lb/model/navigateModel.dart';
import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/screen/chat.dart';
import 'package:chat_lb/screen/login.dart';
import 'package:chat_lb/screen/setting.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/service/socketService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:chat_lb/widget/alertUnSubscribed.dart';
import 'package:chat_lb/widget/categoryWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final TargetPlatform platform;

  HomePage({Key key, this.platform}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _textSearchController = TextEditingController();
  List<TopicModel> _topicList = [];
  List<Widget> _bottomBarItem = [];
  var _currentPage = 1;
  var _endOfHistory = false;
  bool _isLoading = true;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateNotificationToken();
    _loadSettingLinkBottom();
    _removeBadge();
    SocketService.shared().connect();
    _loadDeepLinkData();
    _loadNotificationData();
    _getUnRead();
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

  _getDeepLink() async {
    final provider = Provider.of<DeepLinkModel>(context, listen: false);
    provider.addListener(() {
      String _deepLink = provider.deepLink ?? "";
      print('update deepLink: ' + _deepLink);
      if (_deepLink != null && _deepLink.isNotEmpty) {
        final _topic = _deepLink.replaceAll("topic=", "");
        setState(() {
          _subscribeTopic(_topic);
        });
        provider.updateDeepLink("");
      }
    });
    String _deepLink = provider.deepLink ?? "";
    print('get deepLink: ' + _deepLink);
    if (_deepLink != null && _deepLink.isNotEmpty) {
      final _topic = _deepLink.replaceAll("topic=", "");
      _subscribeTopic(_topic);
    } else {
      _refreshTopics();
    }
  }

  _loadDeepLinkData() {
    final provider = Provider.of<DeepLinkModel>(context, listen: false);
    String _deepLink = provider.deepLink ?? "";
    print('load deepLink: ' + _deepLink);
    if (_deepLink != null && _deepLink.isNotEmpty) {
      final _topic = _deepLink.replaceAll("topic=", "");
      _subscribeTopic(_topic);
      provider.updateDeepLink("");
    } else {
      _loadTopic();
    }
  }

  _getNotificationData() async {
    final provider = Provider.of<DeepLinkModel>(context, listen: false);
    String _topicId = provider.topicNotification ?? "";
    print('load topicNotification: ' + _topicId);
    if (_topicId != null && _topicId.isNotEmpty) {
      _loadTopicDetail(_topicId);
      provider.setTopicNotification("");
    }

    String _topicOpenId = provider.messageOpenApp ?? "";
    print('refresh topicNotification: ' + _topicOpenId);
    if (_topicOpenId != null && _topicOpenId.isNotEmpty) {
      _refreshTopics();
      provider.setOpenNotification("");
    }
  }

  _loadNotificationData() {
    final provider = Provider.of<DeepLinkModel>(context, listen: false);
    String _topicId = provider.topicNotification ?? "";
    print('load topicNotification: ' + _topicId);
    if (_topicId != null && _topicId.isNotEmpty) {
      _loadTopicDetail(_topicId);
      provider.setTopicNotification("");
    }

    //refresh data after receive push
    provider.addListener(() {
      String _topicOpenId = provider.messageOpenApp ?? "";
      print('refresh topicNotification: ' + _topicOpenId);
      if (_topicOpenId != null && _topicOpenId.isNotEmpty) {
        _refreshTopics();
        provider.setOpenNotification("");
      }
    });
  }

  _loadTopicDetail(String topicId) async {
    try {
      EasyLoading.show();
      final response = await ApiService.getTopic(topicId);
      setState(() {
        EasyLoading.dismiss();
      });
      if (response.code == 200) {
        final _topic = response.data;
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      platform: widget.platform,
                      topic: _topic,
                    )),
          ).then((value) {
            setState(() {
              if (value != null && value) {
                _refreshTopics();
              }
            });
          });
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        EasyLoading.dismiss();
      });
    }
  }

  _subscribeTopic(String topicId) async {
    try {
      EasyLoading.show();
      final provider = Provider.of<DeepLinkModel>(context, listen: false);
      provider.updateDeepLink("");
      var response = await ApiService.joinQr(topicId);
      if (response.code == 200) {
        print('subscribe $topicId success');
      }
      setState(() {
        EasyLoading.dismiss();
        _refreshTopics();
      });
    } catch (e) {
      setState(() {
        EasyLoading.dismiss();
        _refreshTopics();
      });
    }
  }

  Future<void> _updateNotificationToken() async {
    try {
      final response = await ApiService.updateNotificationToken();
      if (response.code == 200) {
        print('update notification token success');
      } else {
        print('update notification token fail: ${response.message}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _removeBadge() {
    FlutterAppBadger.removeBadge();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState ${state.toString()}');
    setState(() {
      if (AppLifecycleState.resumed == state) {
        SocketService.shared().connect();
        _getDeepLink();
        _getNotificationData();
        _getUnRead();
        //_removeBadge();
      } else if (AppLifecycleState.inactive == state ||
          AppLifecycleState.paused == state) {
        SocketService.shared().disconnect();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SocketService.shared().disconnect();
    super.dispose();
  }

  void _refreshTopics() {
    _endOfHistory = false;
    _currentPage = 1;
    _loadTopic();
  }

  _loadTopic() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final _name = _textSearchController.text;
      EasyLoading.show();
      var response =
          await ApiService.getListTopic(name: _name, page: _currentPage);
      if (!mounted) {
        return;
      }
      EasyLoading.dismiss();
      setState(() {
        if (response.code == 200) {
          if (_currentPage == 1) {
            _topicList.clear();
          }
          _topicList.addAll(response.data.objects.reversed);
          _endOfHistory = response.data.objects.length < 10;
        } else if (response.code == 401) {
          _logoutAction();
        } else {
          _showAlertMessage(response.message);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _showAlertMessage(e.toString());
        _isLoading = false;
      });
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

  Future<void> _logoutAction() async {
    var alertDialog = AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(Strings.logoutMessage),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop(false);
            },
            child: Text(Strings.cancelJP)),
        TextButton(
            child: Text(Strings.logout),
            onPressed: () {
              _logout();
            }),
      ],
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  Future<void> _logout() async {
    EasyLoading.show();
    try {
      final response = await ApiService.logout();
      setState(() {
        EasyLoading.dismiss();
        print('logout: ' + response.message ?? "");
        AppPrefs.share().logout();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false);
      });
    } catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
      AppPrefs.share().logout();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false);
    }
  }

  _loadSettingLinkBottom() async {
    try {
      EasyLoading.show();
      final response = await ApiService.getNavigate();
      if (response.code != 200) {
        setState(() {
          EasyLoading.dismiss();
          _showAlertMessage(response.message);
        });
        return;
      }
      List<Widget> _widgets = [];
      for (var index = 0; index < response.data.length; index++) {
        final navigate = response.data[index];
        _widgets.add(_createIconBottomBar(index, navigate));
      }
      _widgets.add(_createIconSettingBottomBar());
      setState(() {
        EasyLoading.dismiss();
        _bottomBarItem.clear();
        _bottomBarItem.addAll(_widgets);
      });
    } catch (e) {
      print(e.toString());
      EasyLoading.dismiss();
    }
  }

  Future<void> _onItemTapped(TopicModel topicModel) async {
    _updateReceiveNotification(topicModel);
  }

  Future<void> _onItemLeaveTapped(TopicModel topicModel) async {
    _unsubscribeTopic(topicModel);
  }

  _updateReceiveNotification(TopicModel topicModel) async {
    try {
      EasyLoading.show();
      final _newReceive = !topicModel.receive;
      final params = {"receive": _newReceive, "topic_id": topicModel.id};
      final response = await ApiService.updateReceiveNotification(params);
      setState(() {
        EasyLoading.dismiss();
      });
      setState(() {
        if (response.code != 200) {
          _showAlertMessage(response.message);
          return;
        }
        final _newReceive = !topicModel.receive;
        _topicList
            .firstWhere((element) => element.id == topicModel.id)
            ?.receive = _newReceive;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        EasyLoading.dismiss();
      });
    }
  }

  _unsubscribeTopic(TopicModel topicModel) async {
    final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertUnSubscribedBox(topic: topicModel);
        });
    if (result) {
      setState(() {
        _topicList.removeWhere((element) => element.id == topicModel.id);
      });
    }
  }

  _onItemBarTapped(NavigateModel navigateModel) async {
    final url = navigateModel?.linkUrl() ?? "";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showAlertMessage("${Strings.canNotOpenLink} ${navigateModel.name}");
    }
  }

  Widget _createIconBottomBar(int index, NavigateModel navigateModel) {
    return InkWell(
      onTap: () => {_onItemBarTapped(navigateModel)},
      child: Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                child: ClipRRect(
                  child: Container(
                      child: SizedBox(
                        child: FadeInImage.assetNetwork(
                          image: navigateModel.imageUrl(),
                          placeholder: "assets/images/placeholder.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      color: Color(AppColors.primaryColor)),
                  borderRadius: new BorderRadius.circular(14),
                ),
                height: 28,
                width: 28),
            Text(
              navigateModel.name ?? "",
            ),
          ],
        ),
      ),
    );
  }

  Widget _createIconSettingBottomBar() {
    return InkWell(
      onTap: () => {
        Navigator.push(
                context, MaterialPageRoute(builder: (context) => SettingPage()))
            .then((value) {
          final provider = Provider.of<DeepLinkModel>(context, listen: false);
          if (true == provider.refreshTopic) {
            _refreshTopics();
          }
          provider.hasRefreshTopic(false);
        }),
      },
      child: Padding(
        padding: EdgeInsets.only(top: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.settings_sharp,
              size: 28,
              color: Theme.of(context).accentColor,
            ),
            Text("設定"),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      height: 60,
      alignment: Alignment.center,
      color: Colors.black12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _bottomBarItem,
      ),
    );
  }

  Widget _searchView() {
    return Container(
      margin: EdgeInsets.only(left: 16, top: 12, right: 16, bottom: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Color(AppColors.primaryColor)),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      alignment: Alignment.center,
      child: TextField(
          textAlignVertical: TextAlignVertical.center,
          controller: _textSearchController,
          onChanged: (value) {
            if (_timer != null) {
              _timer.cancel();
            }
            _timer = Timer(Duration(seconds: 1), () {
              _refreshTopics();
            });
          },
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  Icons.search_outlined,
                  color: Color(AppColors.primaryColor),
                ),
                onPressed: () {
                  _refreshTopics();
                },
              ),
              border: InputBorder.none,
              fillColor: Colors.white,
              hintText: "")),
    );
  }

  Widget _getSlidableWithLists(int index) {
    final _topic = _topicList[index];
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
          color: Colors.white,
          child: CategoryWidget(
              index: index,
              topicModel: _topic,
              isEndList: index == _topicList.length)),
      secondaryActions: [
        IconCategoryAction(
          caption: '退会する',
          captionColor: Colors.red,
          color: Colors.white,
          iconWidget:
              Image.asset("assets/images/leave_topic.png", fit: BoxFit.contain),
          onTap: () {
            _onItemLeaveTapped(_topic);
          },
        ),
      ],
      actions: <Widget>[
        IconCategoryAction(
          caption: _topic.receive ?? true ? 'ONにする' : 'OFFにする',
          captionColor: Colors.blue,
          color: Colors.white,
          iconWidget: _topic.receive ?? true
              ? Image.asset("assets/images/ic_notification_on.png",
                  fit: BoxFit.contain)
              : Image.asset("assets/images/ic_notification_off.png",
                  fit: BoxFit.contain),
          onTap: () {
            _onItemTapped(_topic);
          },
        ),
      ],
    );
  }

  Widget _contentCategory() {
    return Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshTopics();
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!_isLoading &&
                  !_endOfHistory &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _currentPage += 1;
                _loadTopic();
                return true;
              }
              return false;
            },
            child: _listTopicWidget(),
          ),
        ));
  }

  Widget _listTopicWidget() {
    return ListView.builder(
      itemCount: _topicList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: _getSlidableWithLists(index),
          onTap: () async {
            final _topic = _topicList[index];
            _topicList[index].unreadMessage = 0;
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        platform: widget.platform,
                        topic: _topic,
                      )),
            ).then((value) {
              setState(() {
                if (value != null && value) {
                  _refreshTopics();
                }
              });
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text("スレッド一覧"),
            centerTitle: true,
          ),
          body: Column(
            children: [_searchView(), Expanded(child: _contentCategory())],
          ),
          bottomNavigationBar: _bottomNavigationBar(),
        ));
  }
}
