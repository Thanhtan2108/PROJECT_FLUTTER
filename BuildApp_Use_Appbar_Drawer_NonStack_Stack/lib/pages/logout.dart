import 'package:flutter/material.dart';

class logoutpage extends StatelessWidget {
  const logoutpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('logout page'),),
      body: Center(child: Text('this is a logout page'),),
    );
  }
}