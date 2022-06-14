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
    0: lightRedNoteColor,
    1: deepBlueNoteColor,
    2: lightGreenNoteColor,
  };

  final Map<int, String> colorNameMap = {
    0: "Light red",
    1: "Deep blue",
    2: "Light green",
  };

  final colors = [
    lightRedNoteColor,
    deepBlueNoteColor,
  ];

  var _note = Note();
  var selectedColor = 255;

  @override
  void initState() {
    if (widget.note != null) {
      _note = widget.note!;
      print("NOTE ID: ${_note.id}");
      titleController.text = _note.title;
      descController.text = _note.description;
      selectedColor = _note.color;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
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
                      hintStyle: theme.textTheme.headlineMedium?.copyWith(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      hintText: "Title",
                    ),
                    controller: titleController,
                    onChanged: (text) => _insertNote(text, descController.text, selectedColor),
                  ),
                  TextField(
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                      border: InputBorder.none,
                      hintText: "Note",
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: descController,
                    onChanged: (text) => _insertNote(titleController.text, text, selectedColor),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Wrap(
                      children: List<Widget>.generate(
                        colorMap.length,
                        (index) {
                          final _color = colorMap[index]!;
                          final colorText = colorNameMap[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            child: ChoiceChip(
                              selected: selectedColor == _color.value,
                              selectedColor: _color,
                              onSelected: (selected) {
                                setState(() {
                                  selectedColor = _color.value;
                                  _insertNote(titleController.text, descController.text, selectedColor);
                                });
                              },
                              label: Text(colorText ?? ""),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    _note.title = titleController.text;
    _note.description = descController.text;
    _note.color = selectedColor;

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
