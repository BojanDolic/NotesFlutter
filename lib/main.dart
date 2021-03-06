import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_flutter/blocs/events/note_events.dart';
import 'package:notes_flutter/blocs/events/tag_events.dart';
import 'package:notes_flutter/blocs/note_bloc.dart';
import 'package:notes_flutter/blocs/tags_bloc.dart';
import 'package:notes_flutter/box/object_box.dart';
import 'package:notes_flutter/resources/repository.dart';
import 'package:notes_flutter/router.dart';

late ObjectBox objectBox;
late Repository repository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectBox = await ObjectBox.getInstance();

  repository = Repository(objectBox.store);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TagsBloc(repository)
            ..add(
              LoadTags(
                tags: repository.getAllTags(),
              ),
            ),
        ),
        BlocProvider(
          create: (context) => NoteBloc(
            repository,
            context.read<TagsBloc>(),
          )..add(
              LoadNotes(
                notes: repository.getAllNotes(),
              ),
            ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              letterSpacing: .6,
              fontWeight: FontWeight.w600,
            ),
            headlineMedium: TextStyle(
              fontFamily: "Poppins",
              fontSize: 18,
              letterSpacing: .6,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            titleSmall: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Poppins",
              letterSpacing: .6,
              fontSize: 14,
              color: Colors.black,
            ),
            bodyMedium: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Poppins",
              letterSpacing: .6,
              fontSize: 16,
            ),
            bodySmall: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Poppins",
              letterSpacing: .6,
              fontSize: 14,
              color: Colors.black54,
            ),
            bodyLarge: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Poppins",
              letterSpacing: .5,
              fontSize: 15,
              color: Colors.black,
            ),
            displaySmall: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: "Poppins",
              letterSpacing: .25,
              fontSize: 13,
              color: Colors.black,
            ),
            labelMedium: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
              letterSpacing: 1.25,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          shadowColor: Colors.black,
          canvasColor: Colors.white,
          listTileTheme: const ListTileThemeData(
            selectedTileColor: Colors.white54,
          ),
        ),
        onGenerateRoute: (settings) => AppRouter.generateRoutes(settings, objectBox),
      ),
    );
  }
}
