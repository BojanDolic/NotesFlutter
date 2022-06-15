import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/note_bloc.dart';
import 'package:notes_flutter/blocs/states/note_states.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/ui/add_note_screen.dart';
import 'package:notes_flutter/ui/widgets/note_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const id = "/";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController _searchController = TextEditingController();

  bool selecting = false;

  List<Note> selectedNotes = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              margin: EdgeInsets.zero,
              child: Text("Note categories"),
            ),
            ListView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              children: [
                ListTile(
                  title: const Text("Pjesme"),
                  leading: const Icon(Icons.label_important_outline_rounded),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onTap: () {
                    //TODO select labels
                  },
                ),
                ListTile(
                  title: const Text("Filmovi"),
                  leading: const Icon(Icons.label_important_outline_rounded),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onTap: () {
                    //TODO select labels
                  },
                ),
                ListTile(
                  title: const Text("Create new label"),
                  leading: const Icon(Icons.add),
                  selected: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onTap: () {
                    //TODO add new label
                  },
                )
              ],
            ),
          ],
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
                "Notes",
                style: theme.textTheme.headlineMedium,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final insertedNote = await Navigator.pushNamed(context, AddNoteScreen.id) as Note?;

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
        child: BlocBuilder<NoteBloc, NoteState>(builder: (context, state) {
          print("Builder pozvan");
          if (state is NoteLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is NoteLoaded) {
            return Padding(
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
                      key: Key("padding"),
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
                    crossFadeState: selecting ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
            );
          } else {
            return const SnackBar(
              content: Text("Something went wrong!"),
            );
          }
        }),
      ),
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
    context.read<NoteBloc>().add(const LoadNotes());
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
}
