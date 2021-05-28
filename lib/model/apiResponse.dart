import 'package:chat_lb/model/pageTopicModel.dart';
import 'package:json_annotation/json_annotation.dart';

import 'pageMessageModel.dart';
import 'userModel.dart';

part 'apiResponse.g.dart';

Type typeOf<T>() => T;

@JsonSerializable(createToJson: false)
class ApiResponse<T> {
  @JsonKey(name: 'code', nullable: true)
  final int code;
  @JsonKey(name: 'message', nullable: true)
  final String message;

  @JsonKey(fromJson: _dataFromJson, nullable: true)
  final T data;

  ApiResponse(this.code, this.message, this.data);

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);

  /// Decodes [json] by "inspecting" its contents.
  static T _dataFromJson<T>(Object json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      if (T == UserModel) {
        return UserModel.fromJson(json) as T;
      } else if (T.toString().contains("PageMessageModel")) {
        return PageMessageModel.fromJson(json) as T;
      } else if (T.toString().contains("PageTopicModel")) {
        return PageTopicModel.fromJson(json) as T;
      }
    }
    return null;
  }
}
