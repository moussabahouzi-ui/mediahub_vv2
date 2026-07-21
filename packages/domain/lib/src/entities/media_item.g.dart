// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => _MediaItem(
  id: MediaId.fromJson(json['id'] as Map<String, dynamic>),
  title: json['title'] as String,
  duration: Duration(microseconds: (json['duration'] as num).toInt()),
  source: json['source'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MediaItemToJson(_MediaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'duration': instance.duration.inMicroseconds,
      'source': instance.source,
      'createdAt': instance.createdAt.toIso8601String(),
    };
