// import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.cyan,
        accentColor: Colors.red),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List todos = List();
  String input = "";

  createTodos() {
    DocumentReference document =
        Firestore.instance.collection("stodo").document(input);
    Map<String, String> todos = {"title": input};

    document.setData(todos).whenComplete(() {
      print("$input Created");
    });
  }

  deleteTodos(item) {
    DocumentReference document =
        Firestore.instance.collection("stodo").document(item);

    document.delete().whenComplete(() {
      print("$item Deleted");
    });
  }

  int _activeTab = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'All',
      style: optionStyle,
    ),
    Text(
      'Pending',
      style: optionStyle,
    ),
    Text(
      'Done',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _activeTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: Text("Add Task"),
                  content: TextField(
                    onChanged: (String value) {
                      input = value;
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: () {
                          // setState(() {
                          //   todos.add(input);
                          // });
                          createTodos();
                          Navigator.of(context).pop();
                        },
                        child: Text("Add"))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: Container(
        child: buildStream(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            title: Text('Business'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text('School'),
          ),
        ],
        currentIndex: _activeTab,
        selectedItemColor: Colors.limeAccent,
        onTap: _onItemTapped,
      ),
      // body:
    );
  }

  StreamBuilder<QuerySnapshot> buildStream() {
    return StreamBuilder(
          stream: Firestore.instance.collection("stodo").snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshots) {
            if (!snapshots.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return _taskListView(snapshots);
            }
          });
  }

  ListView _taskListView(AsyncSnapshot snapshots) {
    {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshots.data.documents.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot documentSnapshot = snapshots.data.documents[index];
            return Dismissible(
                onDismissed: (directon) {
                  deleteTodos(documentSnapshot["title"]);
                },
                key: Key(documentSnapshot["title"]),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  margin: EdgeInsets.all(5),
                  elevation: 16,
                  child: ListTile(
                    title: Text(documentSnapshot["title"]),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.lightGreen,
                      ),
                      onPressed: () {
                        deleteTodos(documentSnapshot["title"]);
                      },
                    ),
                  ),
                ));
          });
    }
  }
}
