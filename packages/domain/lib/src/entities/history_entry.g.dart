// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryEntry _$HistoryEntryFromJson(Map<String, dynamic> json) =>
    _HistoryEntry(
      id: (json['id'] as num).toInt(),
      mediaId: MediaId.fromJson(json['mediaId'] as Map<String, dynamic>),
      playedAt: DateTime.parse(json['playedAt'] as String),
      position: Duration(microseconds: (json['position'] as num).toInt()),
    );

Map<String, dynamic> _$HistoryEntryToJson(_HistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaId': instance.mediaId,
      'playedAt': instance.playedAt.toIso8601String(),
      'position': instance.position.inMicroseconds,
    };
