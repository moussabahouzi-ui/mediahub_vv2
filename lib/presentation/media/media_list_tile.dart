// =============================================================================
// MediaHub v2 — MediaListTile (Feature #1: Media Library)
// Authority: ADR-002 (presentation layer), ADR-017 (widget test target)
// =============================================================================
// A single list-tile for a MediaItem. Stateless; receives the item and an
// optional onTap callback.

import 'package:flutter/material.dart';
import 'package:mediahub_domain/mediahub_domain.dart';

class MediaListTile extends StatelessWidget {
  const MediaListTile({super.key, required this.item, this.onTap});

  final MediaItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          item.source.startsWith('http')
              ? Icons.cloud_outlined
              : Icons.file_present_outlined,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _formatDuration(item.duration),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        _formatRelativeTime(item.createdAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      onTap: onTap,
    );
  }

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours h $minutes m';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return 'just now';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
