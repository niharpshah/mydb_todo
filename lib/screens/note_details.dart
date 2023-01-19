import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Note.dart';
import '../database_helper.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetails(this.note, this.appBarTitle, {Key? key}) : super(key: key);

  @override
  _NoteDetailsState createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  static final _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper.databaseHelper;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool shouldPop = true;

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.bodyText1;

    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description;

    return WillPopScope(
      onWillPop: () => moveToLastScreen(),
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
                  //dropdown menu
                  child: ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(
                            dropDownStringItem,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.lightGreen,
                            ),
                          ),
                        );
                      }).toList(),
                      value: getPriorityAsString(widget.note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          updatePriorityAsInt(valueSelectedByUser.toString());
                        });
                      },
                    ),
                  ),
                ),
                // Second Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Title';
                      }
                    },
                    controller: titleController,
                    // style: textStyle,
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      // labelStyle: textStyle,
                      icon: Icon(Icons.title),
                    ),
                  ),
                ),

                // Third Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: descriptionController,
                    // style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Details',
                      icon: Icon(Icons.details),
                    ),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          textColor: Colors.white,
                          color: Colors.lightGreen,
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Save',
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              letterSpacing: 1.0,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 10.0,
                      ),
                      Expanded(
                        child: MaterialButton(
                          elevation: 2.0,
                          textColor: Colors.white,
                          color: Colors.pink,
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Delete',
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              letterSpacing: 1.0,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateTitle() {
    widget.note.title = titleController.text;
  }

  void updateDescription() {
    widget.note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    widget.note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (widget.note.id != null) {
      result = await helper.updateNote(widget.note);
    } else {
      result = await helper.insertNote(widget.note);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Succesfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (widget.note.id == null) {
      _showAlertDialog('Status', 'First Add a note');
      return;
    }

    int result = await helper.deleteNote(widget.note.id);

    if (result == 0) {
      _showAlertDialog('Status', 'Problem in Deleting Note');
    } else {
      _showAlertDialog('Status', 'Deleted Successfully');
    }
  }

  //conver to int to save into database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        widget.note.priority = 1;
        break;
      case 'Low':
        widget.note.priority = 2;
        break;
    }
  }

  //convert int to String to show user
  String? getPriorityAsString(int value) {
    String? priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  moveToLastScreen() async {
    return Navigator.pop(context, true);
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );

    showDialog(context: context, builder: (_) => alertDialog);
  }
}
