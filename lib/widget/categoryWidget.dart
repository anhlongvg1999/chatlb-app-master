import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/util/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CategoryWidget extends StatelessWidget {
  final int index;
  final bool isEndList;
  final TopicModel topicModel;

  const CategoryWidget({Key key, this.index, this.topicModel, this.isEndList})
      : super(key: key);

  Widget _avatarView() {
    return Container(
        child: ClipRRect(
          child: Container(
              child: SizedBox(
                child: FadeInImage.assetNetwork(
                  image: topicModel.avatarUrl(),
                  placeholder: "assets/images/placeholder.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              color: Color(AppColors.primaryColor)),
          borderRadius: new BorderRadius.circular(25),
        ),
        height: 50,
        width: 50);
  }

  Widget _notificationView() {
    final number = (topicModel.unreadMessage ?? 0);
    final _hasUnread = number > 0;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: ClipRRect(
              child: _hasUnread
                  ? Container(
                      color: Colors.red,
                      child: Text(number > 99 ? "99+" : number.toString(),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      alignment: Alignment.center,
                      height: 30,
                      width: 30)
                  : Container(height: 30, width: 30),
              borderRadius: new BorderRadius.circular(15),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            topicModel.toTime(),
            style: TextStyle(
                fontSize: 10, color: Color(AppColors.primaryTextColor)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(width: 1, color: Color(AppColors.primaryColor)),
              left: BorderSide(width: 1, color: Color(AppColors.primaryColor)),
              right: BorderSide(width: 1, color: Color(AppColors.primaryColor)),
              bottom: isEndList
                  ? BorderSide(width: 1, color: Color(AppColors.primaryColor))
                  : BorderSide(width: 0))),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          _avatarView(),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicModel.name,
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(AppColors.primaryTextColor),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  topicModel.lastMessage ?? "",
                  style: TextStyle(
                      fontSize: 12, color: Color(AppColors.primaryTextColor)),
                )
              ],
            ),
          )),
          _notificationView()
        ],
      ),
    );
  }
}

/// A basic slide action with an icon, a caption and a background color.
class IconCategoryAction extends ClosableSlideAction {
  /// Creates a slide action with an icon, a [caption] if set and a
  /// background color.
  ///
  /// The [closeOnTap] argument must not be null.
  const IconCategoryAction({
    Key key,
    this.icon,
    this.iconWidget,
    this.caption,
    this.captionColor,
    Color color,
    this.foregroundColor,
    VoidCallback onTap,
    bool closeOnTap = true,
  })  : color = color ?? Colors.white,
        assert(icon != null || iconWidget != null,
            'Either set icon or iconWidget.'),
        super(
          key: key,
          color: color,
          onTap: onTap,
          closeOnTap: closeOnTap,
        );

  /// The icon to show.
  final IconData icon;

  /// A custom widget to represent the icon.
  /// If both [icon] and [iconWidget] are set, they will be shown at the same
  /// time.
  final Widget iconWidget;

  /// The caption above the icon.
  final String caption;

  /// The caption text color.
  final Color captionColor;

  /// The background color.
  ///
  /// Defaults to [Colors.white].
  final Color color;

  /// The color used for [icon].
  final Color foregroundColor;

  @override
  Widget buildAction(BuildContext context) {
    final Color estimatedColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.black
            : Colors.white;

    final List<Widget> widgets = [];

    if (caption != null) {
      widgets.add(
        Flexible(
          child: Text(
            caption,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .primaryTextTheme
                .caption
                .copyWith(color: captionColor ?? estimatedColor),
          ),
        ),
      );

      if (icon != null) {
        widgets.add(
          Flexible(
            child: new Icon(
              icon,
              color: foregroundColor ?? estimatedColor,
            ),
          ),
        );
      }

      if (iconWidget != null) {
        widgets.add(
          Flexible(child: iconWidget),
        );
      }
    }

    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
    );
  }
}

class CategoryRadio extends StatelessWidget {
  CategoryRadio({
    this.iconWidget,
    this.label,
    this.color,
    this.groupValue,
    this.value,
    this.onCheck,
  });

  final Widget iconWidget;
  final String label;
  final Color color;
  final bool groupValue;
  final bool value;
  final Function onCheck;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onCheck();
      },
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Container(
              child: iconWidget,
              height: 40,
              width: 40,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: color ?? Color(AppColors.primaryTextColor)),
                ),
              ),
            ),
            Radio<bool>(
              groupValue: groupValue,
              value: value,
              toggleable: true,
              onChanged: (bool newValue) {
                if (newValue != groupValue) {
                  onCheck();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
