// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messageModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return MessageModel(
    json['_id'] as String,
    json['sent_at'] as int,
    (json['read_users'] as List)?.map((e) => e as String)?.toList(),
    (json['click_users'] as List)?.map((e) => e as String)?.toList(),
    json['title'] as String,
    json['content'] as String,
    json['topic_id'] as String,
    json['created_at'] as int,
    MessageModel._dataListSenderFromJson(json['users']),
    MessageModel._dataSenderFromJson(json['sender']),
    json['updated_at'] as int,
    MessageModel._dataListFileFromJson(json['files']),
  )..fileUrl = json['file'] as String;
}

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'sent_at': instance.sentAt,
      'read_users': instance.readUsers,
      'click_users': instance.clickUsers,
      'title': instance.title,
      'content': instance.content,
      'file': instance.fileUrl,
      'topic_id': instance.topicId,
      'created_at': instance.createdAt,
      'users': instance.users,
      'sender': instance.sender,
      'updated_at': instance.updatedAt,
      'files': instance.files,
    };
