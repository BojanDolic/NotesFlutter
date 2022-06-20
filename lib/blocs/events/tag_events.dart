import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:notes_flutter/models/tag.dart';

@immutable
abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

class LoadTags extends TagEvent {
  final List<Tag> tags;

  const LoadTags({required this.tags});

  @override
  List<Object?> get props => [tags];
}

class AddTag extends TagEvent {
  final Tag tag;

  const AddTag({required this.tag});

  @override
  List<Object?> get props => [tag];
}
