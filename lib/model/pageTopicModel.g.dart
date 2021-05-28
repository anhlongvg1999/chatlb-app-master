// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pageTopicModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageTopicModel _$PageTopicModelFromJson(Map<String, dynamic> json) {
  return PageTopicModel(
    json['currentPage'] as int,
    json['page'] as int,
    json['total'] as int,
    PageTopicModel._dataListFromJson(json['objects']),
  );
}

Map<String, dynamic> _$PageTopicModelToJson(PageTopicModel instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'page': instance.page,
      'total': instance.total,
      'objects': instance.objects,
    };
