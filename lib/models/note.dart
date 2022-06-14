import 'package:objectbox/objectbox.dart';

@Entity()
class Note {
  // extends Equatable
  int id = 0;
  String title = "";
  String description = "";
  int color = 255;

  Note({this.title = "", this.description = "", this.color = 255});

  bool isEmpty() => title.isEmpty && description.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          color == other.color;

  @override
  int get hashCode => super.hashCode ^ id.hashCode ^ title.hashCode ^ description.hashCode ^ color.hashCode;

  /* @override
  List<Object?> get props => [id, title, description, color];*/
}
