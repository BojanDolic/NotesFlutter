import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/note_bloc.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/utils/color_constants.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({
    Key? key,
    this.note,
  }) : super(key: key);

  static const id = "/add_note";
  final Note? note;

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  final Map<int, Color> colorMap = {
    0: Colors.white,
    1: lightRedNoteColor,
    2: summerNoteColor,
    3: lightGreenNoteColor,
    4: yellowNoteColor,
    5: pinkNoteColor,
  };

  var _note = Note();
  var selectedColor = Colors.white;

  @override
  void initState() {
    if (widget.note != null) {
      _note = widget.note!;
      titleController.text = _note.title;
      descController.text = _note.description;
      selectedColor = Color(_note.color);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        backgroundColor: selectedColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: selectedColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.black87),
                    decoration: InputDecoration(
                      hintStyle: theme.textTheme.headlineMedium?.copyWith(color: Colors.black),
                      border: InputBorder.none,
                      hintText: "Title",
                    ),
                    controller: titleController,
                    onChanged: (text) => _insertNote(text, descController.text, selectedColor.value),
                  ),
                  TextField(
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintStyle: theme.textTheme.bodyMedium,
                      border: InputBorder.none,
                      hintText: "Note",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: descController,
                    onChanged: (text) => _insertNote(titleController.text, text, selectedColor.value),
                  ),
                  Wrap(
                    children: List<Widget>.generate(colorMap.length, (index) {
                      final color = colorMap[index]!;
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black38),
                              color: color,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: isSelectedColor(color) ? const Icon(Icons.check) : const SizedBox(),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isSelectedColor(Color color) => selectedColor == color;

  Future<bool> _onWillPop() async {
    _note.title = titleController.text;
    _note.description = descController.text;
    _note.color = selectedColor.value;

    BlocProvider.of<NoteBloc>(context).add(
      AddNote(
        _note,
      ),
    );

    /*context.read<NoteBloc>().add(
          AddNote(
            _note,
          ),
        );*/
    Navigator.pop(context, _note);
    return false;
  }

  _insertNote(String title, String description, int color) {
    _note.title = title;
    _note.description = description;
    _note.color = color;
    BlocProvider.of<NoteBloc>(context).add(
      AddNote(
        _note,
      ),
    );
  }
}
