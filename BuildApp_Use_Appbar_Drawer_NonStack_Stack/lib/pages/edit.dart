import 'package:flutter/material.dart';

class editpage extends StatelessWidget {
  const editpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit page'),),
      body: Center(child: Text('this is a edit page'),),
    );
  }
}