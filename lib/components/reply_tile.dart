import 'package:flutter/material.dart';
import '../models/reply.dart';

class ReplyTile extends StatelessWidget {
  final Reply reply;
  final VoidCallback? onDelete;  // ← 삭제 콜백 추가

  const ReplyTile({
    Key? key,
    required this.reply,
    this.onDelete,              // ← 여기에 전달받습니다.
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: reply.profileImageUrl != null
                    ? NetworkImage(reply.profileImageUrl!)
                    : null,
                backgroundColor: theme.colorScheme.surfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reply.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '@${reply.screenName}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reply.text,
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ],
                ),
              ),

              // ── 내가 보낸 답글에만 ☰ 메뉴 띄우기 ───────────────────
              if (onDelete != null)
                PopupMenuButton<int>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        '삭제하기',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 1) {
                      onDelete!();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            indent: 18 * 2 + 12,
            thickness: 0.5,
            color: theme.colorScheme.onSurface.withOpacity(0.15),
            height: 0,
          ),
        ],
      ),
    );
  }
}