import 'package:json_annotation/json_annotation.dart';

part 'unreadResponse.g.dart';

Type typeOf<T>() => T;

@JsonSerializable(createToJson: false)
class UnReadResponse {
  @JsonKey(name: 'code', nullable: true)
  final int code;
  @JsonKey(name: 'message', nullable: true)
  final String message;

  @JsonKey(name: 'data', nullable: true)
  final int data;

  UnReadResponse(this.code, this.message, this.data);

  factory UnReadResponse.fromJson(Map<String, dynamic> json) =>
      _$UnReadResponseFromJson(json);

}
