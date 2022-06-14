import 'package:equatable/equatable.dart';
import 'package:notes_flutter/models/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  final List<Note> notes;

  const LoadNotes({this.notes = const <Note>[]});

  @override
  List<Object?> get props => [notes];
}

class AddNote extends NoteEvent {
  final Note note;

  const AddNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNote extends NoteEvent {
  final Note note;

  const DeleteNote(
    this.note,
  );

  @override
  List<Object?> get props => [note];
}

class SearchNotes extends NoteEvent {
  final String query;

  const SearchNotes({this.query = ""});

  @override
  List<Object?> get props => [query];
}

class UpdateNote extends NoteEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}
