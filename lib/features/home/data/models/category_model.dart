import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
@JsonSerializable()
class BookCategory with _$BookCategory {
  const factory BookCategory({
    required String id,
    required String name,
    required String slug,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'color_hex') String? colorHex,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _BookCategory;

  factory BookCategory.fromJson(Map<String, dynamic> json) =>
      _$BookCategoryFromJson(json);
}
