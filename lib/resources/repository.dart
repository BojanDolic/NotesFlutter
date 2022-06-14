import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

class Repository {
  final Store store;

  late Box<Note> noteBox;

  Repository(this.store) {
    noteBox = store.box<Note>();
  }

  List<Note> getAllNotes({String query = ""}) {
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

  void insertNote(Note note) {
    noteBox.put(note);
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
