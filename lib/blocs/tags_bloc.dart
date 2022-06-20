import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_flutter/blocs/events/tag_events.dart';
import 'package:notes_flutter/blocs/states/tag_states.dart';
import 'package:notes_flutter/resources/repository.dart';

class TagsBloc extends Bloc<TagEvent, TagState> {
  final Repository _repository;
  TagsBloc(this._repository) : super(LoadingTags()) {
    on<LoadTags>(_loadTags);
    on<AddTag>(_addTag);
  }

  FutureOr<void> _loadTags(LoadTags event, Emitter<TagState> emit) {
    emit(
      LoadedTags(
        tags: _repository.getAllTags(),
      ),
    );
  }

  FutureOr<void> _addTag(AddTag event, Emitter<TagState> emit) {
    final tag = event.tag;

    _repository.insertTag(tag);

    emit(
      LoadedTags(
        tags: _repository.getAllTags(),
      ),
    );
  }
}
