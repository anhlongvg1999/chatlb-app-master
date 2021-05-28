// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigateModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigateModel _$NavigateModelFromJson(Map<String, dynamic> json) {
  return NavigateModel(
    json['_id'] as String,
    json['created_at'] as int,
    json['name'] as String,
    json['url'] as String,
    json['image'] as String,
    json['updated_at'] as int,
  );
}

Map<String, dynamic> _$NavigateModelToJson(NavigateModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'created_at': instance.createdAt,
      'name': instance.name,
      'url': instance.url,
      'image': instance.image,
      'updated_at': instance.updatedAt,
    };
