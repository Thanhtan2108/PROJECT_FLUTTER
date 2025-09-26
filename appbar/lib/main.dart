import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          title: Text('A P P B A R'),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              // do something when user press
            },
            icon: Icon(Icons.menu),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // do something when pressed
              },
              icon: Icon(Icons.share),
            ),
            IconButton(
              onPressed: () {
                // do something when pressed
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
