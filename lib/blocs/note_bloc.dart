import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/states/note_states.dart';
import 'package:notes_flutter/blocs/states/tag_states.dart';
import 'package:notes_flutter/blocs/tags_bloc.dart';
import 'package:notes_flutter/models/tag.dart';
import 'package:notes_flutter/resources/repository.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final Repository _repository;
  final TagsBloc _tagsBloc;
  late StreamSubscription streamSubscription;

  var _query = "";
  Tag _tag = Tag();

  Tag get tag => _tag;
  bool get isTagSelected => _tag.id != 0;
  bool get isSearching => _query != "";

  NoteBloc(this._repository, this._tagsBloc) : super(NoteLoading()) {
    on<LoadNotes>(_loadNotes);
    on<AddNote>(_addNote);
    on<DeleteNote>(_deleteNote);
    on<SearchNotes>(_searchNote);
    on<UpdateNote>(_updateNote);
    on<DeleteNotes>(_deleteNotes);
    on<SearchNotesByTag>(_searchNoteByTag);
    on<ResetSearches>(_resetSearches);
    on<UpdateNotes>(_updateNotes);

    streamSubscription = _tagsBloc.stream.listen(
      (event) {
        if (event is LoadedTags) {
          add(
            const LoadNotes(),
          );
        }
      },
    );
  }

  //bool isTagSelected() => _tag != "";

  void _loadNotes(LoadNotes event, Emitter<NoteState> emitter) {
    emitter(
      NoteLoaded(
        notes: _repository.getOtherNotes(
          query: _query,
          tag: _tag.tagName,
        ),
        pinnedNotes: _repository.getPinnedNotes(),
      ),
    );
  }

  _addNote(AddNote event, Emitter<NoteState> emitter) {
    //final state = this.state;
    _repository.insertNote(event.note);
    //final notes = _repository.getAllNotes();
    emitter(
      NoteLoaded(
        notes: _repository.getOtherNotes(
          query: _query,
          tag: _tag.tagName,
        ),
        pinnedNotes: _repository.getPinnedNotes(),
      ),
    );
  }

  void _deleteNote(DeleteNote event, Emitter<NoteState> emitter) {
    final state = this.state;
    if (state is NoteLoaded) {
      _repository.deleteNote(event.note);
      final _notes = state.notes;
      _notes.remove(event.note);
      emit(
        NoteLoaded(
          notes: _repository.getOtherNotes(
            query: _query,
            tag: _tag.tagName,
          ),
          pinnedNotes: _repository.getPinnedNotes(),
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
          notes: _repository.getOtherNotes(
            query: _query,
            tag: _tag.tagName,
          ),
          pinnedNotes: _repository.getPinnedNotes(),
        ),
      );
    }
  }

  /// Function used to search all notes from database using [_query] parameter
  ///
  /// Note: function returns no pinned notes because all notes will be shown
  FutureOr<void> _searchNote(SearchNotes event, Emitter<NoteState> emit) {
    final state = this.state;
    _query = event.query;

    if (state is NoteLoaded) {
      emit(
        NoteLoaded(
          notes: _repository.getOtherNotes(
            query: event.query,
            tag: _tag.tagName,
          ),
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
        pinnedNotes: _repository.getPinnedNotes(),
      );
    }
  }

  void insertTagIntoDatabase(Tag tag) {
    _repository.insertTag(tag);
  }

  FutureOr<void> _searchNoteByTag(SearchNotesByTag event, Emitter<NoteState> emit) {
    final tag = event.tag;

    _tag = tag;

    emit(
      NoteLoaded(
        notes: _repository.getOtherNotes(
          query: _query,
          tag: _tag.tagName,
        ),
      ),
    );
  }

  FutureOr<void> _resetSearches(ResetSearches event, Emitter<NoteState> emit) {
    _query = "";
    _tag = Tag();

    emit(
      NoteLoaded(
        notes: _repository.getOtherNotes(
          query: _query,
          tag: _tag.tagName,
        ),
        pinnedNotes: _repository.getPinnedNotes(),
      ),
    );
  }

  FutureOr<void> _updateNotes(UpdateNotes event, Emitter<NoteState> emit) {
    final notes = event.notes;

    _repository.updateNotes(notes);

    emit(
      NoteLoaded(
        notes: _repository.getOtherNotes(
          query: _query,
          tag: _tag.tagName,
        ),
        pinnedNotes: _repository.getPinnedNotes(),
      ),
    );
  }
}
