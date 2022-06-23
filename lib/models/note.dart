// ignore_for_file: slash_for_doc_comments

import 'package:notes_flutter/models/tag.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Note {
  int id = 0;
  String title = "";
  String description = "";
  int color = 255;
  bool pinned = false;
  final tags = ToMany<Tag>();

  Note({
    this.title = "",
    this.description = "",
    this.color = 255,
    this.pinned = false,
  });

  /**
   * Function used to check if note is "empty"
   *
   * Empty, in the context of the note, means that note doesn't have a title and description.
   * The note could be colored and tags could be assigned to the note,
   * but if it lacks a title and description it is considered empty
   */
  bool isEmpty() => title.isEmpty && description.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          color == other.color &&
          pinned == other.pinned;

  @override
  int get hashCode => super.hashCode ^ id.hashCode ^ title.hashCode ^ description.hashCode ^ color.hashCode ^ pinned.hashCode;
}
