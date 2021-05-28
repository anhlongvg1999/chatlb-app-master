import 'package:chat_lb/model/topicModel.dart';
import 'package:json_annotation/json_annotation.dart';


part 'pageTopicModel.g.dart';
@JsonSerializable()
class PageTopicModel {
  @JsonKey(name: 'currentPage', nullable: true)
  final int currentPage;
  @JsonKey(name: 'page', nullable: true)
  final int page;
  @JsonKey(name: 'total', nullable: true)
  final int total;

  @JsonKey(name: 'objects', fromJson: _dataListFromJson, nullable: true)
  final List<TopicModel> objects;


  PageTopicModel(this.currentPage, this.page, this.total, this.objects);

  factory PageTopicModel.fromJson(Map<String, dynamic> json) =>
      _$PageTopicModelFromJson(json);

  /// Decodes [json] by "inspecting" its contents.
  static List<TopicModel> _dataListFromJson(Object json) {
    if (json == null) return null;
    if (json is List) {
      // NOTE: this logic assumes the ONLY valid value for a `List` in this case
      // is a List<Author>. If that assumption changes, then it will be
      // necessary to "peak" into non-empty lists to determine the type!
      return json
          .map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return List.empty();
  }
}
