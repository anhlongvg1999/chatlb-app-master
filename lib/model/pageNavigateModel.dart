import 'package:chat_lb/model/navigateModel.dart';
import 'package:json_annotation/json_annotation.dart';


part 'pageNavigateModel.g.dart';
@JsonSerializable()
class PageNavigateModel {
  @JsonKey(name: 'code', nullable: true)
  final int code;
  @JsonKey(name: 'message', nullable: true)
  final String message;
  @JsonKey(name: 'data', fromJson: _dataListFromJson)
  final List<NavigateModel> data;


  PageNavigateModel(this.code, this.message, this.data);

  factory PageNavigateModel.fromJson(Map<String, dynamic> json) =>
      _$PageNavigateModelFromJson(json);

  /// Decodes [json] by "inspecting" its contents.
  static List<NavigateModel> _dataListFromJson(Object json) {
    if (json == null) return null;
    if (json is List) {
      // NOTE: this logic assumes the ONLY valid value for a `List` in this case
      // is a List<Author>. If that assumption changes, then it will be
      // necessary to "peak" into non-empty lists to determine the type!
      return json
          .map((e) => NavigateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }
}
