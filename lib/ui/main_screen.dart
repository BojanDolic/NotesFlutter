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

  @override
  Widget build(BuildContext context) {
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
              physics: BouncingScrollPhysics(),
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
      appBar: AppBar(
        elevation: 1,
        titleSpacing: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        title: TextField(
          controller: _searchController,
          onChanged: (text) => _searchNotes(text),
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
            filled: true,
            hintText: "Search for note",
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 6,
              ),
              child: MasonryGridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: state.notes.length,
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: isLandscape ? 3 : 2),
                itemBuilder: (context, index) {
                  return NoteWidget(
                    note: state.notes[index],
                    onLongPress: () => _openDeleteDialog(state, index),
                    onTap: () => _openNote(state, state.notes[index]),
                  );
                },
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

  void _openDeleteDialog(NoteLoaded state, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete this note ?"),
        content: const Text("You are about to delete this note, this can't be reversed!"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          MaterialButton(
            child: const Text(
              "Close",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: "Poppins",
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          MaterialButton(
            child: const Text(
              "Delete",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            onPressed: () {
              _deleteNote(state, index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _deleteNote(NoteLoaded state, int index) {
    context.read<NoteBloc>().add(
          DeleteNote(
            state.notes[index],
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Note deleted"),
      ),
    );
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
}
