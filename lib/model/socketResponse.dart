import 'package:json_annotation/json_annotation.dart';

import 'pageMessageModel.dart';
import 'userModel.dart';

part 'socketResponse.g.dart';

@JsonSerializable(createToJson: false)
class SocketResponse {
  @JsonKey(name: 'success', nullable: true)
  final bool success;
  @JsonKey(name: 'message', nullable: true)
  final String message;
  @JsonKey(name: 'email', nullable: true)
  final String email;

  SocketResponse(this.success, this.message, this.email);

  factory SocketResponse.fromJson(Map<String, dynamic> json) =>
      _$SocketResponseFromJson(json);
}
