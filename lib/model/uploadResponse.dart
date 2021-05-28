import 'package:json_annotation/json_annotation.dart';

import 'fileModel.dart';

part 'uploadResponse.g.dart';

@JsonSerializable()
class UploadResponse {
  @JsonKey(name: 'code', nullable: true)
  final int code;
  @JsonKey(name: 'message', nullable: true)
  final String message;
  @JsonKey(name: 'data', fromJson: _dataListFileFromJson, nullable: true)
  final List<FileModel> data;

  UploadResponse(this.code, this.message, this.data);

  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseFromJson(json);

  static List<FileModel> _dataListFileFromJson(Object json) {
    if (json == null) return null;
    if (json is List) {
      // NOTE: this logic assumes the ONLY valid value for a `List` in this case
      // is a List<Author>. If that assumption changes, then it will be
      // necessary to "peak" into non-empty lists to determine the type!
      return json
          .map((e) => FileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }
}
