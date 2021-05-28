// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pageMessageModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageMessageModel _$PageMessageModelFromJson(Map<String, dynamic> json) {
  return PageMessageModel(
    json['currentPage'] as int,
    json['page'] as int,
    json['total'] as int,
    PageMessageModel._dataListFromJson(json['objects']),
  );
}

Map<String, dynamic> _$PageMessageModelToJson(PageMessageModel instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'page': instance.page,
      'total': instance.total,
      'objects': instance.objects,
    };
