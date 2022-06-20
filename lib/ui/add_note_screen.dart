import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/note_bloc.dart';
import 'package:notes_flutter/blocs/states/tag_states.dart';
import 'package:notes_flutter/blocs/tags_bloc.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/models/tag.dart';
import 'package:notes_flutter/ui/widgets/tag_item_widget.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

  final selectedTags = <Tag>[];

  @override
  void initState() {
    if (widget.note != null) {
      _note = widget.note!;
      titleController.text = _note.title;
      descController.text = _note.description;
      selectedColor = Color(_note.color);
      selectedTags.addAll(_note.tags);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        key: scaffoldKey,
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.black87),
                    decoration: InputDecoration(
                      hintStyle: theme.textTheme.headlineMedium?.copyWith(color: Colors.black),
                      border: InputBorder.none,
                      hintText: "Title",
                    ),
                    controller: titleController,
                    //onChanged: (text) => _insertNote(text, descController.text, selectedColor.value),
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
                    //onChanged: (text) {}, //_insertNote(titleController.text, text, selectedColor.value),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 9,
                    children: List<Widget>.generate(
                      selectedTags.length,
                      (index) => TagItemWidget(
                        note: _note,
                        tag: selectedTags[index],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: List<Widget>.generate(colorMap.length, (index) {
                      final color = colorMap[index]!;

                      bool _selected = isSelectedColor(color);

                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                              _note.color = selectedColor.value;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: _selected
                                  ? Border.all(
                                      color: Colors.blue,
                                      width: 2.0,
                                    )
                                  : Border.all(
                                      color: Colors.black38,
                                    ),
                              color: color,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: _selected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.blue,
                                  )
                                : const SizedBox(),
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
        bottomNavigationBar: BottomAppBar(
          color: selectedColor,
          elevation: 0,
          child: Row(
            children: [
              IconButton(
                onPressed: () => _showBottomSheet(),
                icon: const Icon(
                  Icons.label_important_outline_rounded,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        /*bottomSheet: BottomSheet(
            onClosing: () {},
            builder: (context) {
              return BlocBuilder<TagsBloc, TagState>(builder: (context, state) {
                if (state is LoadedTags) {
                  return ListView.builder(
                    itemCount: state.tags.length,
                    itemBuilder: (context, index) {
                      final tag = state.tags[index];
                      return FilterChip(
                        selectedColor: Colors.blue,
                        label: Text(tag.tagName),
                        onSelected: (selected) {
                          if (selected) {
                            selectedTags.add(tag);
                          } else {
                            selectedTags.remove(tag);
                          }
                        },
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              });
            }),*/
      ),
    );
  }

  bool isSelectedColor(Color color) => selectedColor == color;

  Future<bool> _onWillPop() async {
    /*_note.title = titleController.text;
    _note.description = descController.text;
    _note.color = selectedColor.value;

    BlocProvider.of<NoteBloc>(context).add(
      AddNote(
        _note,
      ),
    );*/
    _insertNote(titleController.text, descController.text, selectedColor.value);
    Navigator.pop(context, _note);
    return false;
  }

  _insertNote(String title, String description, int color) {
    _note.title = title.trim();
    _note.description = description.trim();
    _note.color = color;

    _note.tags.clear();
    _note.tags.addAll(selectedTags);

    BlocProvider.of<NoteBloc>(context).add(
      AddNote(
        _note,
      ),
    );
  }

  _showBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      context: context,
      backgroundColor: selectedColor,
      builder: (context) {
        return BlocBuilder<TagsBloc, TagState>(
          builder: (context, state) {
            if (state is LoadedTags) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Select note tags",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Wrap(
                          spacing: 12,
                          children: _buildTagWidgets(state.tags, setState),
                        )
                        /*GridView.builder(
                          itemCount: state.tags.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          padding: const EdgeInsets.all(9),
                          itemBuilder: (context, index) {
                            final tag = state.tags[index];
                            return
                          },
                        ),*/
                      ],
                    ),
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }

  List<Widget> _buildTagWidgets(List<Tag> tags, StateSetter setStateDialog) {
    final widgets = <Widget>[];

    for (Tag tag in tags) {
      final widget = FilterChip(
        selectedColor: Colors.blue,
        selected: selectedTags.contains(tag),
        label: Text(tag.tagName),
        onSelected: (selected) {
          setStateDialog(
            () {
              if (selected) {
                selectedTags.add(tag);
              } else {
                selectedTags.remove(tag);
              }
            },
          );
          setState(() {});
          //_insertNote(titleController.text, descController.text, selectedColor.value);
        },
      );
      widgets.add(widget);
    }
    return widgets;
  }
}
