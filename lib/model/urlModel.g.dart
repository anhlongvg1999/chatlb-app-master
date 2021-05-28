// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'urlModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UrlModel _$UrlModelFromJson(Map<String, dynamic> json) {
  return UrlModel(
    json['name'] as String,
    json['avatar'] as bool,
  );
}

Map<String, dynamic> _$UrlModelToJson(UrlModel instance) => <String, dynamic>{
      'name': instance.name,
      'avatar': instance.avatar,
    };
