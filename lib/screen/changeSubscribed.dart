import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:chat_lb/widget/categoryWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ChangeSubscribedPage extends StatefulWidget {
  final TargetPlatform platform;

  ChangeSubscribedPage({Key key, this.platform}) : super(key: key);

  @override
  _ChangeSubscribedPageState createState() => _ChangeSubscribedPageState();
}

class _ChangeSubscribedPageState extends State<ChangeSubscribedPage> {
  List<TopicModel> _topicList = [];
  var _currentPage = 1;
  var _endOfHistory = false;
  var _isLoad = false;

  @override
  void initState() {
    super.initState();
    _loadTopic();
  }

  _loadTopic() async {
    try {
      EasyLoading.show();
      setState(() {
        _isLoad = true;
      });
      var response =
          await ApiService.getListTopic(page: _currentPage, getSubscribe: "no");
      setState(() {
        _isLoad = false;
        EasyLoading.dismiss();
      });
      if (!mounted) {
        return;
      }
      _topicList.addAll(response.data.objects.reversed);
      setState(() {
        if (response.code == 200) {
          _endOfHistory = response.data.objects.length < 10;
        } else {
          _showAlertMessage(response.message);
        }
      });
    } catch (e) {
      setState(() {
        _isLoad = false;
        EasyLoading.dismiss();
        _showAlertMessage(e.toString());
      });
    }
  }

  void _refreshTopics() {
    _endOfHistory = false;
    _currentPage = 1;
    _topicList.clear();
    _loadTopic();
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

  _updateSubscribedTopic() async {
    try {
      EasyLoading.show();
      final List<String> subscribeList = [];
      //final List<String> unsubscribeList = [];
      _topicList.forEach((element) {
        if ((element.isSubscribe ?? true)) {
          subscribeList.add(element.id);
        }
        // else {
        //   unsubscribeList.add(element.id);
        // }
      });
      final params = {"subscribe": true, "topic_ids": subscribeList};
      var response = await ApiService.subscribe(params);
      setState(() {
        EasyLoading.dismiss();
      });
      if (response.code != 200) {
        setState(() {
          _showAlertMessage(response.message);
        });
        return;
      }
      // if (unsubscribeList.isNotEmpty) {
      //   final params = {"subscribe": false, "topic_ids": unsubscribeList};
      //   var responseUnsubscribed = await ApiService.subscribe(params);
      //   setState(() {
      //     EasyLoading.dismiss();
      //   });
      //   if (responseUnsubscribed.code != 200) {
      //     setState(() {
      //       _showAlertMessage(responseUnsubscribed.message);
      //     });
      //     return;
      //   }
      // }
      // setState(() {
      //   EasyLoading.dismiss();
      // });
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        EasyLoading.dismiss();
        _showAlertMessage(e.toString());
      });
    }
  }

  Widget _submitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      child: FlatButton(
        onPressed: () {
          _updateSubscribedTopic();
        },
        padding: EdgeInsets.only(left: 32, right: 32, top: 8, bottom: 8),
        child: Text("再入会する",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        textColor: Colors.white,
        color: Color(int.parse("0xFF6386FF")),
      ),
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
              if (!_isLoad && !_endOfHistory &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _currentPage += 1;
                _loadTopic();
                return true;
              }
              return false;
            },
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: Color(AppColors.primaryColor),
                );
              },
              itemCount: _topicList.length,
              itemBuilder: (context, index) {
                final topicModel = _topicList[index];
                return CategoryRadio(
                  iconWidget: ClipRRect(
                    child: Container(
                      child: SizedBox(
                        child: FadeInImage.assetNetwork(
                          image: topicModel.avatarUrl(),
                          placeholder: "assets/images/placeholder.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      color: Color(AppColors.primaryColor),
                      width: 48,
                      height: 48,
                    ),
                    borderRadius: new BorderRadius.circular(24),
                  ),
                  label: topicModel.name,
                  value: true,
                  groupValue: topicModel.isSubscribe ?? true,
                  onCheck: () {
                    setState(() {
                      _topicList[index].isSubscribe =
                          !(topicModel.isSubscribe ?? true);
                    });
                  },
                );
              },
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("スレッド一覧"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        children: [Expanded(child: _contentCategory()), _submitButton()],
      )),
    );
  }
}
