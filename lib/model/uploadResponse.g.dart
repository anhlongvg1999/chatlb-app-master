// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uploadResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadResponse _$UploadResponseFromJson(Map<String, dynamic> json) {
  return UploadResponse(
    json['code'] as int,
    json['message'] as String,
    UploadResponse._dataListFileFromJson(json['data']),
  );
}

Map<String, dynamic> _$UploadResponseToJson(UploadResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
