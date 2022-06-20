import 'package:objectbox/objectbox.dart';

@Entity()
class Tag {
  int id = 0;
  String tagName = "";

  Tag({this.id = 0, this.tagName = ""});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Tag && runtimeType == other.runtimeType && id == other.id && tagName == other.tagName;

  @override
  int get hashCode => id.hashCode ^ tagName.hashCode;

  @override
  String toString() {
    return 'Tag{id: $id, tagName: $tagName}';
  }
}
