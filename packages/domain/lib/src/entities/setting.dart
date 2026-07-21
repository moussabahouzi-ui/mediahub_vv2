// =============================================================================
// MediaHub v2 — Setting entity (Feature #4: Settings)
// Authority: ADR-002 (pure-Dart domain), ADR-004 (freezed codegen)
// =============================================================================
// A key-value setting. The `value` is stored as a string; typed accessors
// (bool, int, string) are provided. The data layer persists it in a
// key-value Drift table.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting.freezed.dart';
part 'setting.g.dart';

@freezed
abstract class Setting with _$Setting {
  const factory Setting({required String key, required String value}) =
      _Setting;

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  const Setting._();

  /// Parses the value as a boolean. Returns false on failure.
  bool get asBool => value.toLowerCase() == 'true' || value == '1';

  /// Parses the value as an integer. Returns 0 on failure.
  int get asInt => int.tryParse(value) ?? 0;

  /// Creates a boolean setting.
  factory Setting.bool(String key, bool value) =>
      Setting(key: key, value: value.toString());

  /// Creates an integer setting.
  factory Setting.int(String key, int value) =>
      Setting(key: key, value: value.toString());
}
