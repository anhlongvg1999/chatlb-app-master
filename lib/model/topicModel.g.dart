// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topicModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicModel _$TopicModelFromJson(Map<String, dynamic> json) {
  return TopicModel(
    json['_id'] as String,
    TopicModel._dataListUserFromJson(json['users']),
    json['count_send'] as int,
    json['unread_message'] as int,
    json['created_at'] as int,
    json['name'] as String,
    json['description'] as String,
    json['avatar'] as String,
    json['image'] as String,
    json['image_url'] as String,
    json['is_subcribe'] as bool,
    json['receive'] as bool,
  );
}

Map<String, dynamic> _$TopicModelToJson(TopicModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'users': instance.users,
      'count_send': instance.countSend,
      'unread_message': instance.unreadMessage,
      'created_at': instance.createdAt,
      'name': instance.name,
      'description': instance.lastMessage,
      'avatar': instance.avatar,
      'image': instance.image,
      'image_url': instance.imageUrl,
      'is_subcribe': instance.isSubcribe,
      'receive': instance.receive,
    };
