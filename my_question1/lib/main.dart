import 'package:flutter/material.dart';

void main() => runApp(MyListViewApp());

class MyListViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ListView Example')),
        body: ListView(
          children: [
            ListTile(leading: Icon(Icons.phone), title: Text('Phone')),
            ListTile(leading: Icon(Icons.email), title: Text('Email')),
            ListTile(leading: Icon(Icons.map), title: Text('Map')),
          ],
        ),
      ),
    );
  }
}
