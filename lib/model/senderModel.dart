import 'package:chat_lb/util/apiUrl.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'senderModel.g.dart';

@JsonSerializable()
class SenderModel {
  @JsonKey(name: '_id')
  String id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'avatar')
  String avatar;


  SenderModel(this.id, this.name, this.avatar);

  factory SenderModel.fromJson(Map<String, dynamic> json) =>
      _$SenderModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SenderModelToJson(this);

  String avatarUrl() {
    //return ApiURL.API + avatar;
    return avatar;
  }
}