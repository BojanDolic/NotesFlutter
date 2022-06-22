import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_flutter/models/tag.dart';

@immutable
abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

class LoadingTags extends TagState {
  const LoadingTags();

  @override
  List<Object?> get props => [];
}

class LoadedTags extends TagState {
  final List<Tag> tags;

  const LoadedTags({this.tags = const <Tag>[]});

  @override
  List<Object?> get props => [tags];
}
