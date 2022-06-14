import 'package:flutter/material.dart';
import 'package:notes_flutter/box/object_box.dart';
import 'package:notes_flutter/models/note.dart';
import 'package:notes_flutter/ui/add_note_screen.dart';
import 'package:notes_flutter/ui/main_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoutes(RouteSettings settings, ObjectBox box) {
    final route = settings.name;

    switch (route) {
      case MainScreen.id:
        {
          return MaterialPageRoute(
            builder: (_) => const MainScreen(),
          );
        }
      case AddNoteScreen.id:
        {
          return MaterialPageRoute(
            builder: (context) {
              final args = settings.arguments as Note?;
              return AddNoteScreen(
                note: args,
              );
            },
          );
        }
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("Route not found $route"),
            ),
          ),
        );
    }
  }
}
