import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'userTopicModel.g.dart';

@JsonSerializable()
class UserTopicModel {
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'avatar')
  String avatar;


  UserTopicModel(this.name, this.avatar);

  factory UserTopicModel.fromJson(Map<String, dynamic> json) =>
      _$UserTopicModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserTopicModelToJson(this);
}