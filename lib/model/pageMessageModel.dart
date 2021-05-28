import 'package:json_annotation/json_annotation.dart';

import 'messageModel.dart';

part 'pageMessageModel.g.dart';
@JsonSerializable()
class PageMessageModel {
  @JsonKey(name: 'currentPage', nullable: true)
  final int currentPage;
  @JsonKey(name: 'page', nullable: true)
  final int page;
  @JsonKey(name: 'total', nullable: true)
  final int total;

  @JsonKey(name: 'objects', fromJson: _dataListFromJson, nullable: true)
  final List<MessageModel> objects;


  PageMessageModel(this.currentPage, this.page, this.total, this.objects);

  factory PageMessageModel.fromJson(Map<String, dynamic> json) =>
      _$PageMessageModelFromJson(json);

  /// Decodes [json] by "inspecting" its contents.
  static List<MessageModel> _dataListFromJson(Object json) {
    if (json == null) return null;
    if (json is List) {
      // NOTE: this logic assumes the ONLY valid value for a `List` in this case
      // is a List<Author>. If that assumption changes, then it will be
      // necessary to "peak" into non-empty lists to determine the type!
      return json
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }
}
