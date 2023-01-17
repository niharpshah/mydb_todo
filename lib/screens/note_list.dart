import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../Note.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LCO ToDo'),
        backgroundColor: Colors.purple,
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
        onPressed: () {
          navigatetoDetail(Note('', '', 2), 'Add Note');
        },
      ),
    );
  }

  void navigatetoDetail(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return NoteDetail(note, title);
      }),
    );
    if (result == true) {
      // TODO: update the view
    }
  }
}
