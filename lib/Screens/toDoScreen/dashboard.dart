import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mytodoapp/Screens/toDoScreen/backend/tasklist.dart';
import 'package:mytodoapp/Screens/toDoScreen/frontend/components/dashboard_custom_textfield.dart';
import 'package:mytodoapp/Screens/toDoScreen/frontend/components/dashboard_dateandtime_.dart';
import 'package:mytodoapp/Screens/toDoScreen/backend/viewHolder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainDashboard extends StatefulWidget {
  final String _email;
  MainDashboard(this._email);
  @override
  _MainActivityState createState() => _MainActivityState(_email);
}

class _MainActivityState extends State<MainDashboard> {
  final String _email;
  TaskList taskList = new TaskList();
  String chosenDate = "", chosenTime = "", title = "", desc = "";
  _MainActivityState(this._email);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white12,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 10),
              child: Text(
                "Your Tasks ",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 30, right: 30),
                child: Divider(color: Colors.grey, thickness: 1)),
            Expanded(
              child: SizedBox(
                height: 400.0,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("Tasks")
                        .doc(_email)
                        .collection("User_Tasks_List")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Loading!...");
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return InkWell(
                            onDoubleTap: () => _popupDialog(
                                context, snapshot.data.documents[index]),
                            child: Dismissible(
                              key: Key(snapshot.data.documents[index]['Title']),
                              onDismissed: (direction) => FirebaseFirestore
                                  .instance
                                  .runTransaction((transaction) async {
                                transaction.delete(
                                    snapshot.data.documents[index].reference);
                                Fluttertoast.showToast(
                                    msg: "Task has been deleted!");
                              }),
                              child: ViewHolder(snapshot.data.documents[index]),
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onPressed: onButtonPressed,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  void onButtonPressed() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        backgroundColor: Colors.grey[850],
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter mystate) {
            return Container(
                height: MediaQuery.of(context).copyWith().size.height * 0.65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: Icon(Icons.calendar_today, color: Colors.teal),
                      title: Text(
                        chosenDate + '           ' + chosenTime ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.timer, color: Colors.teal),
                    ),
                    DashboardCustomTextField(),
                    DashBoardDateTime(updated, mystate),
                    SizedBox(height: 10),
                    MaterialButton(
                      onPressed: () {
                        createRecord(
                            DashboardCustomTextField.getTitle().text,
                            DashboardCustomTextField.getDesc().text,
                            chosenDate,
                            chosenTime);
                      },
                      color: Colors.teal,
                      child: Icon(Icons.save, size: 50, color: Colors.white),
                      padding: EdgeInsets.all(16),
                      shape: CircleBorder(),
                    ),
                  ],
                ));
          });
        });
  }

  void updated(StateSetter updateState, {String date, String time}) {
    updateState(() {
      if (date != null) this.chosenDate = date;
      if (time != null) this.chosenTime = time;
    });
  }

  void setTitleForTask(String title) => this.title = title;

  void setDescriptionForTask(String desc) => this.desc = desc;

  void createRecord(String _title, String _desc, String _chosenDate,
      String _chosenTime) async {
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("Tasks")
        .doc(_email)
        .collection("User_Tasks_List")
        .doc()
        .set({
      'Title': _title,
      'description': _desc,
      'date': _chosenDate,
      'time': _chosenTime
    });
  }

  void _popupDialog(BuildContext context, DocumentSnapshot documentSnapshot) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
    );
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(documentSnapshot['Title']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(documentSnapshot['description']),
                Text(documentSnapshot['date']),
                Text(documentSnapshot['time']),
              ],
            ),
            actions: [
              okButton,
            ],
          );
        });
  }
}
