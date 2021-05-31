import 'package:chat_lb/model/fileModel.dart';
import 'package:chat_lb/model/senderModel.dart';
import 'package:chat_lb/util/apiUrl.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'messageModel.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class MessageModel {
  @JsonKey(name: '_id')
  String id;
  @JsonKey(name: 'sent_at')
  int sentAt;
  @JsonKey(name: 'read_users')
  List<String> readUsers;
  @JsonKey(name: 'click_users')
  List<String> clickUsers;
  @JsonKey(name: 'title')
  String title;
  @JsonKey(name: 'content')
  String content;
  @JsonKey(name: 'file')
  String fileUrl;
  @JsonKey(name: 'topic_id')
  String topicId;
  @JsonKey(name: 'created_at')
  int createdAt;
  @JsonKey(name: 'users', fromJson: _dataListSenderFromJson)
  List<SenderModel> users;
  @JsonKey(name: 'sender', fromJson: _dataSenderFromJson)
  SenderModel sender;
  @JsonKey(name: 'updated_at')
  int updatedAt;
  @JsonKey(name: 'files', fromJson: _dataListFileFromJson)
  List<FileModel> files;

  MessageModel(
      this.id,
      this.sentAt,
      this.readUsers,
      this.clickUsers,
      this.title,
      this.content,
      this.topicId,
      this.createdAt,
      this.users,
      this.sender,
      this.updatedAt,
      this.files);

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  static List<FileModel> _dataListFileFromJson<T>(Object json) {
    if (json == null) return null;
    if (json is List) {
      return json
          .map((e) => FileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }

  static List<SenderModel> _dataListSenderFromJson<T>(Object json) {
    if (json == null) return null;
    if (json is List) {
      return json
          .map((e) => SenderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }

  static SenderModel _dataSenderFromJson<T>(Object json) {
    if (json == null) return null;
    return SenderModel.fromJson(json as Map<String, dynamic>);
  }



  String getContent() {
    return content != null ? content : "";
  }

  String toTime() {
    if (sentAt == null) {
      return "";
    }
    var date =
        new DateTime.fromMillisecondsSinceEpoch(sentAt) ?? DateTime.now();
    var dateFormat = DateFormat('HH:mm a');
    return dateFormat.format(date);
  }

  String toFullTime() {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(sentAt) ?? DateTime.now();
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return dateFormat.format(date);
  }

  SenderModel user() {
    if (users == null || users.isEmpty) {
      return null;
    }
    return users.first;
  }

  bool isFile() {
    if (files != null && files.isNotEmpty) {
      return files.first.path.isNotEmpty;
    }
    return false;
  }

  bool isImage() {
    if (!isFile()) {
      return false;
    }
    final url = filesUrl().toUpperCase();
    return (url.contains(".png".toUpperCase())
        || url.contains(".jpg".toUpperCase())
        || url.contains(".jpeg".toUpperCase())
        || url.contains(".bmp".toUpperCase())
        || url.contains(".gif".toUpperCase())
        || url.contains(".tiff".toUpperCase())
        || url.contains(".webp".toUpperCase())
        || url.contains(".webp".toUpperCase()));
  }

  String filesName() {
    if (files != null && files.isNotEmpty) {
      return files.first.name;
    }
    return "";
  }

  String downloadLink() {
    if (isFile()) {
      return filesUrl();
    }
    return "";
  }

  String filesUrl() {
    //return ApiURL.API + files.first.path;
    return files.first.path;
  }

  String getFilePlaceHolder() {
    return "assets/images/placeholder.jpg";
  }
}
