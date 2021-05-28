import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/util/color.dart';

class CategoryMessageWidget extends StatelessWidget {
  final int position;
  final MessageModel messageModel;

  const CategoryMessageWidget({
    Key key,
    this.position,
    this.messageModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(
        children: [
          _avatarView(),
          SizedBox(height: 10),
          Text(
            messageModel.sender()?.name ?? "",
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
                  padding: const EdgeInsets.only(
                      right: 8.0, left: 8.0, top: 8.0, bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4)),
                    child: Container(
                      color: Color(AppColors.receiverColor),
                      child: Stack(
                        children: <Widget>[
                          _contentTextView(),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
              Container(
                margin: EdgeInsets.only(right: 8),
                child: Text(
                  messageModel.toTime(),
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

  Widget _avatarView() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
        child: Container(
            child: ClipRRect(
              child: Container(
                  child: SizedBox(
                    child: FadeInImage.assetNetwork(
                      image: messageModel.sender()?.avatarUrl() ?? "",
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
      padding:
          const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0, bottom: 12.0),
      child: Text(
        this.messageModel.getContent(),
      ),
    );
  }
}
