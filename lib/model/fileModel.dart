import 'package:json_annotation/json_annotation.dart';

part 'fileModel.g.dart';

@JsonSerializable()
class FileModel {
  @JsonKey(name: '_id')
  String id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'path')
  String path;
  @JsonKey(name: 'uploaded_at')
  int uploadedAt;
  @JsonKey(name: 'mime_type')
  String mimeType;


  FileModel(this.id, this.name, this.path, this.uploadedAt, this.mimeType);

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$FileModelToJson(this);
}