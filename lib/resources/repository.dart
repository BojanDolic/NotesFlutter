import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/models/tag.dart';
import 'package:notes_flutter/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

class Repository {
  final Store store;

  late Box<Note> noteBox;
  late Box<Tag> tagBox;

  Repository(this.store) {
    noteBox = store.box<Note>();
    tagBox = store.box<Tag>();
  }

  List<Note> getAllNotes({String query = "", String tag = ""}) {
    final _queryBuilder = noteBox.query(
      Note_.title.contains(
        query,
        caseSensitive: false,
      ),
    )..order(Note_.id, flags: Order.descending);

    if (tag != "") {
      _queryBuilder.linkMany(
        Note_.tags,
        Tag_.tagName.equals(tag, caseSensitive: false),
      );
    }

    final finalQuery = _queryBuilder.build();

    List<Note> notes = finalQuery.find();
    finalQuery.close();
    return notes;
  }

  List<Note> getOtherNotes({String query = "", String tag = ""}) {
    if (query.isNotEmpty || tag.isNotEmpty) {
      return getAllNotes(query: query, tag: tag);
    }

    final _queryBuilder = noteBox.query(
      Note_.pinned.equals(false),
    )..order(Note_.id, flags: Order.descending);

    final _query = _queryBuilder.build();

    List<Note> notes = _query.find();
    _query.close();
    return notes;
  }

  List<Note> getPinnedNotes() {
    final _queryBuilder = noteBox.query(
      Note_.pinned.equals(true),
    )..order(Note_.id, flags: Order.descending);

    final _query = _queryBuilder.build();

    List<Note> notes = _query.find();
    _query.close();
    return notes;
  }

  void updateNotes(List<Note> notes) {
    noteBox.putMany(notes);
  }

  void insertNote(Note note) {
    noteBox.put(note);
  }

  List<Tag> getAllTags() {
    return tagBox.getAll();
  }

  void insertTag(Tag tag) {
    tagBox.put(tag);
  }

  void deleteTag(Tag tag) {
    tagBox.remove(tag.id);
  }

  void deleteNote(Note note) {
    noteBox.remove(note.id);
  }

  void deleteNotes(List<int> ids) {
    noteBox.removeMany(ids);
  }

  List<Note> searchNote(String query) {
    final _query = noteBox
        .query(
          Note_.title.contains(
            query,
            caseSensitive: false,
          ),
        )
        .build();

    List<Note> notes = _query.find();
    _query.close();
    return notes;
  }
}
