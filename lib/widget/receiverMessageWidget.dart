import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/util/color.dart';

typedef OnTapDownload = void Function(int);

class ReceiverMessageWidget extends StatelessWidget {
  final int position;
  final MessageModel model;
  final OnTapDownload onTapDownload;

  const ReceiverMessageWidget({
    Key key,
    this.position,
    this.onTapDownload,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _avatarView(),
      Expanded(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
              child: Row(children: [
                Text(
                  '${model.sender()?.name}   ',
                  style: TextStyle(
                      fontSize: 12, color: Colors.black.withOpacity(0.6)),
                ),
                Text(
                  model.toFullTime(),
                  style: TextStyle(
                      fontSize: 12, color: Colors.black.withOpacity(0.6)),
                )
              ])),
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
                          model.isFile() && model.getContent().isNotEmpty
                              ? _contentTextAndFileView()
                              : model.isFile()
                                  ? _contentFileView()
                                  : _contentTextView(),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
              model.isFile()
                  ? _downloadButtonView()
                  : Container(height: 24, width: 66)
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
                    child: Image.asset(
                      'assets/images/ic_isk_chat.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  color: Color(AppColors.primaryColor)),
              borderRadius: new BorderRadius.circular(25),
            ),
            height: 50,
            width: 50));
  }

  Widget _contentFileView() {
    return Padding(
      padding:
          const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: model.isImage()
                  ? FadeInImage.assetNetwork(
                image: model.filesUrl(),
                placeholder: model.getFilePlaceHolder(),
                //height: 120,
                width: 160,
                fit: BoxFit.fill,
              )
                  : Image.asset(model.getFilePlaceHolder(),
                  //height: 120,
                  width: 160,
                  fit: BoxFit.fill)),
          SizedBox(
            height: 5,
          ),
          Text(
            model.filesName(),
          )
        ],
      ),
    );
  }

  Widget _contentTextAndFileView() {
    return Padding(
      padding:
          const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              child: model.isImage()
                  ? FadeInImage.assetNetwork(
                      image: model.filesUrl(),
                      placeholder: model.getFilePlaceHolder(),
                      //height: 120,
                      width: 160,
                      fit: BoxFit.fill,
                    )
                  : Image.asset(model.getFilePlaceHolder(),
                      //height: 120,
                      width: 160,
                      fit: BoxFit.fill)),
          SizedBox(
            height: 5,
          ),
          Text(
            model.getContent(),
          )
        ],
      ),
    );
  }

  Widget _contentTextView() {
    return Padding(
      padding:
          const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0, bottom: 12.0),
      child: Text(
        model.getContent(),
      ),
    );
  }

  Widget _downloadButtonView() {
    return InkWell(
      onTap: () {
        onTapDownload.call(position);
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
          alignment: Alignment.bottomLeft,
          child: Image.asset('assets/images/ic_download_file.png',
              fit: BoxFit.contain),
          height: 24,
          width: 66),
    );
  }
}
