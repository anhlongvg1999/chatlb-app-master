import 'package:flutter/material.dart';
import 'package:chat_lb/model/messageModel.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/widget/receiverMessageWidget.dart';

class SenderMessageWidget extends StatelessWidget {
  final int position;
  final MessageModel model;
  final OnTapDownload onTapDownload;

  const SenderMessageWidget({
    Key key,
    this.position,
    this.model, this.onTapDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Text(
              model.toFullTime(),
              style:
                  TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.6)),
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            model.isFile()
                ? _downloadButtonView()
                : Container(height: 24, width: 66),
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
                    color: Color(AppColors.senderColor),
                    child: Stack(children: <Widget>[
                      model.isFile() && model.getContent().isNotEmpty
                          ? _contentTextAndFileView()
                          : model.isFile()
                              ? _contentFileView()
                              : _contentTextView(),
                    ]),
                  ),
                ),
              ),
            )),
          ],
        )
      ],
    );
  }

  Widget _contentTextView() {
    return Padding(
        padding: const EdgeInsets.only(
            right: 12.0, left: 12.0, top: 12.0, bottom: 12.0),
        child: Text(
          model.getContent(),
          textAlign: TextAlign.end
        ));
  }

  Widget _contentFileView() {
    return Padding(
      padding: const EdgeInsets.only(
          right: 12.0, left: 12.0, top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
            textAlign: TextAlign.end,
          )
        ],
      ),
    );
  }

  Widget _contentTextAndFileView() {
    return Padding(
      padding: const EdgeInsets.only(
          right: 12.0, left: 12.0, top: 12.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
            textAlign: TextAlign.end,
          )
        ],
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
          alignment: Alignment.bottomRight,
          child: Image.asset('assets/images/ic_download_file.png',
              fit: BoxFit.contain),
          height: 24,
          width: 66),
    );
  }
}
