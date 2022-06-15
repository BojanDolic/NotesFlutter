import 'package:flutter/material.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/utils/color_constants.dart';

class NoteWidget extends StatelessWidget {
  const NoteWidget({
    Key? key,
    required this.note,
    required this.onLongPress,
    required this.onTap,
    required this.selected,
  }) : super(key: key);

  final Note note;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: onLongPress,
        onTap: onTap,
        child: Material(
          clipBehavior: Clip.none,
          elevation: selected ? 30 : 0,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    note.title,
                    maxLines: 3,
                    style: theme.textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Visibility(
                    visible: note.description.isNotEmpty,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          note.description,
                          maxLines: 9,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Color(note.color),
              borderRadius: BorderRadius.circular(12),
              border: selected
                  ? Border.all(
                      color: Colors.black,
                      width: selected ? 2.5 : 1,
                    )
                  : Border.all(
                      color: borderColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
