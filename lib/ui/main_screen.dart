import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/events/tag_events.dart';
import 'package:notes_flutter/blocs/note_bloc.dart';
import 'package:notes_flutter/blocs/states/note_states.dart';
import 'package:notes_flutter/blocs/states/tag_states.dart';
import 'package:notes_flutter/blocs/tags_bloc.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/models/tag.dart';
import 'package:notes_flutter/ui/add_note_screen.dart';
import 'package:notes_flutter/ui/widgets/note_widget.dart';
import 'package:notes_flutter/utils/color_constants.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const id = "/";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _searchController = TextEditingController();
  final _tagNameController = TextEditingController();

  bool selecting = false;

  List<Note> selectedNotes = [];

  final tagNameKey = GlobalKey();

  String? tagNameError = null;

  @override
  void dispose() {
    _searchController.dispose();
    _tagNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (BuildContext context, state) {
        final noteBloc = context.read<NoteBloc>();
        if (state is NoteLoaded) {
          return Scaffold(
            drawer: Drawer(
              child: BlocBuilder<TagsBloc, TagState>(
                builder: (BuildContext context, state) {
                  if (state is LoadedTags) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.tags.length + 1,
                            itemBuilder: (context, index) {
                              if (index != state.tags.length) {
                                final tag = state.tags[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 12,
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.only(
                                      left: 16,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(
                                          50,
                                        ),
                                        bottomRight: Radius.circular(
                                          50,
                                        ),
                                      ),
                                    ),
                                    selected: noteBloc.tag == tag,
                                    selectedTileColor: lightBlueColor,
                                    selectedColor: Colors.blue,
                                    title: Text(
                                      tag.tagName,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    leading: const Icon(
                                      Icons.label_outline_rounded,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _searchNotesByTag(tag);
                                    },
                                    onLongPress: () => _deleteTag(tag),
                                  ),
                                );
                              } else {
                                return ListTile(
                                  title: Text(
                                    "Create new tag",
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  leading: Icon(
                                    Icons.add,
                                    color: theme.textTheme.titleSmall?.color,
                                  ),
                                  onTap: () => _openAddTagDialog(),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
            appBar: selecting
                ? AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(
                      "Selected: ${selectedNotes.length}",
                      style: theme.textTheme.headlineMedium,
                    ),
                    actions: selecting
                        ? [
                            IconButton(
                              onPressed: () {
                                _deleteSelectedNotes();
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.blue,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selecting = false;
                                  selectedNotes.removeRange(0, selectedNotes.length);
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                              ),
                            ),
                          ]
                        : null,
                  )
                : AppBar(
                    elevation: 0,
                    title: Text(
                      noteBloc.isTagSelected ? noteBloc.tag.tagName : "Notes",
                      style: theme.textTheme.headlineMedium,
                    ),
                    actions: noteBloc.isTagSelected
                        ? [
                            IconButton(
                              onPressed: () => _deleteSearch(),
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.blue,
                              ),
                            ),
                          ]
                        : null,
                  ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final _note = Note();
                _note.color = Colors.white.value;
                if (noteBloc.isTagSelected) {
                  _note.tags.add(
                    noteBloc.tag,
                  );
                }
                final insertedNote = await Navigator.pushNamed(context, AddNoteScreen.id, arguments: _note) as Note?;

                if (insertedNote != null) {
                  if (insertedNote.isEmpty()) {
                    context.read<NoteBloc>().add(
                          DeleteNote(insertedNote),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Empty note discarded"),
                      ),
                    );
                  }
                }
              },
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 6,
                  right: 6,
                  bottom: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedCrossFade(
                      firstChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (text) => _searchNotes(text),
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            filled: true,
                            hintText: "Search for note",
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.clear,
                              ),
                              onPressed: () => _deleteSearch(),
                            ),
                          ),
                        ),
                      ),
                      secondChild: const SizedBox(),
                      crossFadeState: (selecting || noteBloc.isTagSelected) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: MasonryGridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.notes.length,
                        clipBehavior: Clip.none,
                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: isLandscape ? 3 : 2),
                        itemBuilder: (context, index) {
                          final note = state.notes[index];
                          return NoteWidget(
                            selected: selectedNotes.contains(note),
                            note: state.notes[index],
                            onLongPress: () {
                              setState(() {
                                selecting = true;
                                selectedNotes.add(note);
                              });
                            },
                            onTap: () {
                              if (selecting) {
                                _selectNote(note);
                              } else {
                                _openNote(state, state.notes[index]);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  _selectNote(Note note) {
    if (selectedNotes.contains(note)) {
      setState(() {
        selectedNotes.remove(note);
        if (selectedNotes.isEmpty) {
          _deselectAllNotes();
        }
      });
    } else {
      setState(() {
        selectedNotes.add(note);
      });
    }
  }

  _deselectAllNotes() {
    setState(() {
      selecting = false;
      selectedNotes.removeRange(0, selectedNotes.length);
    });
  }

  _searchNotes(String text) {
    context.read<NoteBloc>().add(
          SearchNotes(
            query: text.trim(),
          ),
        );
  }

  _deleteSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.clear();
    context.read<NoteBloc>().add(const ResetSearches());
  }

  _openNote(NoteLoaded state, Note note) async {
    Navigator.pushNamed(context, AddNoteScreen.id, arguments: note);
  }

  void _deleteSelectedNotes() {
    final _notesToDelete = List.of(selectedNotes);
    context.read<NoteBloc>().add(
          DeleteNotes(notes: _notesToDelete),
        );
    _deselectAllNotes();
  }

  void _openAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter tag name"),
              content: TextField(
                key: tagNameKey,
                controller: _tagNameController,
                decoration: InputDecoration(
                  hintText: "Enter tag name",
                  errorText: tagNameError,
                ),
              ),
              actions: [
                MaterialButton(
                  child: Text(
                    "Add tag",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  onPressed: () {
                    _saveTag(_tagNameController.text, setState);
                  },
                ),
                MaterialButton(
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  onPressed: () {
                    tagNameError = null;
                    _tagNameController.clear();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveTag(String text, StateSetter setState) {
    final state = context.read<TagsBloc>().state;
    if (state is LoadedTags) {
      if (text.isEmpty) {
        setState(() {
          tagNameError = "Name can't be empty";
          return;
        });
      }

      final tags = state.tags;
      bool nameNotAvailable = tags.any((element) => element.tagName.toLowerCase() == text.toLowerCase());

      if (nameNotAvailable) {
        setState(() {
          tagNameError = "Tag already exists";
        });
        return;
      }
    }
    context.read<TagsBloc>().add(
          AddTag(
            tag: Tag(tagName: text),
          ),
        );
    _tagNameController.clear();
    tagNameError = null;
    Navigator.pop(context);
  }

  _searchNotesByTag(Tag tag) {
    context.read<NoteBloc>().add(
          SearchNotesByTag(tag: tag),
        );
  }

  _deleteTag(Tag tag) {
    context.read<TagsBloc>().add(
          DeleteTag(tag: tag),
        );
  }
}
