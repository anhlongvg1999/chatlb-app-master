import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/util/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryMessageWidget extends StatelessWidget {
  final int position;
  final MessageModel messageModel;

  const CategoryMessageWidget({Key key, this.position, this.messageModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(
        children: [
          _avatarView(),
          SizedBox(height: 10),
          Text(
            messageModel.sender?.name ?? "",
            style:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
          )
        ],
      ),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                  child: Container(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChatBubble(
                              clipper: ChatBubbleClipper8(
                                  type: BubbleType.receiverBubble,
                              radius: 24.0),
                              backGroundColor: Color(0xFF8de055),
                              margin: EdgeInsets.only(top: 4.0),
                              child: _contentTextView(),
                              )))),
              Container(
                margin: EdgeInsets.only(right: 8),
                child: Text(
                  messageModel.toTime() ?? "",
                  style: TextStyle(
                      fontSize: 12, color: Colors.black.withOpacity(0.6)),
                ),
              )
            ],
          )
        ],
      ))
    ]);
  }

  _clickMessage() async {
    try {
      final messageId = messageModel.id ?? "";
      if (messageId.isEmpty) {
        return;
      }
      var response = await ApiService.clickMessage(messageId);
      if (response.code == 200) {
        print("click message success: " + messageId);
      } else {
        print("click message faid: " + messageId);
      }
    } catch (e) {}
  }

  Widget _avatarView() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        child: Container(
            child: ClipRRect(
              child: Container(
                  child: SizedBox(
                    child: FadeInImage.assetNetwork(
                      image: messageModel.sender?.avatarUrl() ?? "",
                      placeholder: "assets/images/placeholder.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  color: Color(AppColors.primaryColor)),
              borderRadius: new BorderRadius.circular(25),
            ),
            height: 50,
            width: 50));
  }

  Widget _contentTextView() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Html(
          data: this.messageModel.getContent(),
          onLinkTap: (String url) async {
            try {
              await launch(url);
              _clickMessage();
            } catch (e) {
              print(e);
            }
          }),
    );
  }
}
