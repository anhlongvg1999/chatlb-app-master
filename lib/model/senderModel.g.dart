// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'senderModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SenderModel _$SenderModelFromJson(Map<String, dynamic> json) {
  return SenderModel(
    json['_id'] as String,
    json['name'] as String,
    json['avatar'] as String,
  );
}

Map<String, dynamic> _$SenderModelToJson(SenderModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
    };
