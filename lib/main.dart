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

  deleteTodos() {}

  @override
  // void initState() {
  //   super.initState();
  //   todos.add("Task 1");
  //   todos.add("Task 2");
  //   todos.add("Task 3");
  //   todos.add("Task 4");
  //   todos.add("Task 5");
  // }

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
      body: StreamBuilder(
          stream: Firestore.instance.collection("stodo").snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshots) {
            if (!snapshots.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshots.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot documentSnapshot =
                        snapshots.data.documents[index];
                    return Dismissible(
                        key: Key(index.toString()),
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
                                setState(() {
                                  todos.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ));
                  });
            }
          }),

      // body:
    );
  }
}
