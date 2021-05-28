// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fileModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileModel _$FileModelFromJson(Map<String, dynamic> json) {
  return FileModel(
    json['_id'] as String,
    json['name'] as String,
    json['path'] as String,
    json['uploaded_at'] as int,
    json['mime_type'] as String,
  );
}

Map<String, dynamic> _$FileModelToJson(FileModel instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'path': instance.path,
      'uploaded_at': instance.uploadedAt,
      'mime_type': instance.mimeType,
    };
