import 'package:flutter/cupertino.dart';
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                  Visibility(
                    visible: note.tags.isNotEmpty,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 9,
                        ),
                        Wrap(
                          spacing: 6,
                          children: List<Widget>.generate(
                            tagsCount(note) > 2 ? 3 : tagsCount(note),
                            (index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  TagItem(
                                    note: note,
                                    index: index,
                                  ),
                                  /*Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color(note.color) == Colors.white ? Colors.grey.shade200 : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      index > 1 ? getRemainingNotesCount(note) : note.tags[index].tagName,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),*/
                                ],
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
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

  tagsCount(Note note) => note.tags.length;
}

class TagItem extends StatelessWidget {
  const TagItem({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  final Note note;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(note.color) == Colors.white ? Colors.grey.shade200 : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        index > 1 ? getRemainingNotesCount(note) : note.tags[index].tagName,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
        ),
      ),
    );
  }

  getRemainingNotesCount(Note note) {
    final remainingNotes = note.tags.length - 2;
    return "+$remainingNotes";
  }
}
