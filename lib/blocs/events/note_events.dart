import 'package:equatable/equatable.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/models/tag.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NoteEvent {
  final List<Note> notes;
  final List<Note> pinnedNotes;

  const LoadNotes({
    this.notes = const <Note>[],
    this.pinnedNotes = const <Note>[],
  });

  @override
  List<Object?> get props => [notes, pinnedNotes];
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

class DeleteNotes extends NoteEvent {
  final List<Note> notes;

  const DeleteNotes({this.notes = const <Note>[]});

  @override
  List<Object?> get props => [notes];
}

class ResetSearches extends NoteEvent {
  const ResetSearches();

  @override
  List<Object?> get props => [];
}

class SearchNotes extends NoteEvent {
  final String query;

  const SearchNotes({this.query = ""});

  @override
  List<Object?> get props => [query];
}

class SearchNotesByTag extends NoteEvent {
  final Tag tag;

  const SearchNotesByTag({required this.tag});

  @override
  List<Object?> get props => [tag];
}

class UpdateNote extends NoteEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNotes extends NoteEvent {
  final List<Note> notes;

  const UpdateNotes({required this.notes});

  @override
  List<Object?> get props => [notes];
}
