import 'package:chat_lb/util/apiUrl.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// This allows the `User` class to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'navigateModel.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class NavigateModel {
  @JsonKey(name: '_id')
  String id;
  @JsonKey(name: 'created_at')
  int createdAt;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'url')
  String url;
  @JsonKey(name: 'image')
  String image;
  @JsonKey(name: 'updated_at')
  int updatedAt;

  NavigateModel(this.id,this.createdAt, this.name,  this.url, this.image, this.updatedAt);

  factory NavigateModel.fromJson(Map<String, dynamic> json) =>
      _$NavigateModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$NavigateModelToJson(this);

  String toTime() {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(createdAt) ?? DateTime.now();
    var dateFormat = DateFormat('HH:mm a');
    return dateFormat.format(date);
  }

  String toFullTime() {
    var date =
        new DateTime.fromMillisecondsSinceEpoch(createdAt) ?? DateTime.now();
    var dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return dateFormat.format(date);
  }

  String imageUrl() {
    //return ApiURL.API + (image ?? "");
    return image ?? "";
  }

  String linkUrl() {
    return url ?? "";
  }
}
