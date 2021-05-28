import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'userModel.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class UserModel {
  @JsonKey(name: '_id')
  String id;
  @JsonKey(name: 'email')
  String email;
  @JsonKey(name: 'receive_notification')
  bool receiveNotification;
  @JsonKey(name: 'role')
  String role;
  @JsonKey(name: 'token')
  String token;

  UserModel(this.id, this.email, this.receiveNotification, this.role, this.token);

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
