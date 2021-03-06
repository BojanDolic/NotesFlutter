import 'package:equatable/equatable.dart';
import 'package:notes_flutter/models/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

class NoteLoading extends NoteState {}

class NoteLoaded extends NoteState {
  final List<Note> notes;

  const NoteLoaded({this.notes = const <Note>[]});

  @override
  List<Object?> get props => [notes];
}
