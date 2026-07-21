// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Playlist _$PlaylistFromJson(Map<String, dynamic> json) => _Playlist(
  id: PlaylistId.fromJson(json['id'] as Map<String, dynamic>),
  name: json['name'] as String,
  itemIds:
      (json['itemIds'] as List<dynamic>)
          .map((e) => MediaId.fromJson(e as Map<String, dynamic>))
          .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PlaylistToJson(_Playlist instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'itemIds': instance.itemIds,
  'createdAt': instance.createdAt.toIso8601String(),
};
