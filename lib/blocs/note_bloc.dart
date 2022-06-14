import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/states/note_states.dart';
import 'package:notes_flutter/resources/repository.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final Repository _repository;

  var _query = "";

  NoteBloc(this._repository) : super(NoteLoading()) {
    on<LoadNotes>(_loadNotes);
    on<AddNote>(_addNote);
    on<DeleteNote>(_deleteNote);
    on<SearchNotes>(_searchNote);
    on<UpdateNote>(_updateNote);
    on<DeleteNotes>(_deleteNotes);
  }

  void _loadNotes(LoadNotes event, Emitter<NoteState> emitter) {
    emitter(
      NoteLoaded(notes: _repository.getAllNotes()),
    );
  }

  _addNote(AddNote event, Emitter<NoteState> emitter) {
    final state = this.state;
    if (state is NoteLoaded) {
      _repository.insertNote(event.note);
      //final notes = _repository.getAllNotes();
      emit(
        NoteLoaded(
          notes: _repository.getAllNotes(query: _query),
        ),
      );
    }
  }

  void _deleteNote(DeleteNote event, Emitter<NoteState> emitter) {
    final state = this.state;
    if (state is NoteLoaded) {
      _repository.deleteNote(event.note);
      final _notes = state.notes;
      _notes.remove(event.note);
      emit(
        NoteLoaded(
          notes: _repository.getAllNotes(query: _query),
        ),
      );
    }
  }

  FutureOr<void> _deleteNotes(DeleteNotes event, Emitter<NoteState> emitter) {
    final state = this.state;

    if (state is NoteLoaded) {
      final eventNotes = event.notes;

      _repository.deleteNotes(
        eventNotes
            .map(
              (e) => e.id,
            )
            .toList(),
      );

      emitter(
        NoteLoaded(
          notes: _repository.getAllNotes(query: _query),
        ),
      );
    }
  }

  FutureOr<void> _searchNote(SearchNotes event, Emitter<NoteState> emit) {
    final state = this.state;
    _query = event.query;

    if (state is NoteLoaded) {
      emit(
        NoteLoaded(
          notes: _repository.getAllNotes(query: event.query),
        ),
      );
    }
  }

  FutureOr<void> _updateNote(UpdateNote event, Emitter<NoteState> emit) async* {
    final state = this.state;
    if (state is NoteLoaded) {
      _repository.insertNote(event.note);

      yield NoteLoaded(
        notes: _repository.getAllNotes().toList(),
      );
    }
  }
}
