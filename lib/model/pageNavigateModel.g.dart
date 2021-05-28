// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pageNavigateModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageNavigateModel _$PageNavigateModelFromJson(Map<String, dynamic> json) {
  return PageNavigateModel(
    json['code'] as int,
    json['message'] as String,
    PageNavigateModel._dataListFromJson(json['data']),
  );
}

Map<String, dynamic> _$PageNavigateModelToJson(PageNavigateModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
