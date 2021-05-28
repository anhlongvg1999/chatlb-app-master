import 'package:chat_lb/model/urlModel.dart';
import 'package:chat_lb/model/userTopicModel.dart';
import 'package:chat_lb/util/apiUrl.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'topicModel.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class TopicModel {
  @JsonKey(name: '_id')
  String id;
  @JsonKey(name: 'users', fromJson: _dataListUserFromJson)
  List<UserTopicModel> users;
  @JsonKey(name: 'count_send')
  int countSend;
  @JsonKey(name: 'unread_message')
  int unreadMessage;
  @JsonKey(name: 'created_at')
  int createdAt;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'last_message')
  String lastMessage;
  @JsonKey(name: 'avatar')
  String avatar;
  @JsonKey(name: 'image')
  String image;
  @JsonKey(name: 'image_url')
  String imageUrl;
  @JsonKey(name: 'is_subcribe')
  bool isSubcribe;
  @JsonKey(name: 'receive', nullable: true)
  bool receive = true;

  TopicModel(
      this.id,
      this.users,
      this.countSend,
      this.unreadMessage,
      this.createdAt,
      this.name,
      this.lastMessage,
      this.avatar,
      this.image,
      this.imageUrl,
      this.isSubcribe,
      this.receive);

  factory TopicModel.fromJson(Map<String, dynamic> json) =>
      _$TopicModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$TopicModelToJson(this);

  static List<UserTopicModel> _dataListUserFromJson<T>(Object json) {
    if (json == null) return null;
    if (json is List) {
      return json
          .map((e) => UserTopicModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }

  String toTime() {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(createdAt) ?? DateTime.now();
    var dateFormat = DateFormat('MM/dd');
    return dateFormat.format(date);
  }

  String toFullTime() {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(createdAt) ?? DateTime.now();
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return dateFormat.format(date);
  }

  String avatarUrl() {
    return (avatar ?? "");
  }

  bool isImage() {
    if (image.isEmpty) {
      return false;
    }
    final url = image.toUpperCase();
    return (url.contains(".png".toUpperCase()) ||
        url.contains(".jpg".toUpperCase()) ||
        url.contains(".jpeg".toUpperCase()) ||
        url.contains(".bmp".toUpperCase()) ||
        url.contains(".gif".toUpperCase()) ||
        url.contains(".tiff".toUpperCase()) ||
        url.contains(".webp".toUpperCase()) ||
        url.contains(".webp".toUpperCase()));
  }

  String getImageUrl() {
    return image;
  }

  String getImageLinkUrl() {
    return imageUrl;
  }
}
