import 'package:flutter/material.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/models/tag.dart';

class TagItemWidget extends StatelessWidget {
  const TagItemWidget({
    Key? key,
    required this.note,
    required this.tag,
  }) : super(key: key);

  final Note note;
  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isWhiteColor() ? Colors.grey.shade200 : Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag.tagName,
        style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
      ),
    );
  }

  bool isWhiteColor() {
    return (Color(note.color) == Colors.white || note.color == 255);
  }
}
