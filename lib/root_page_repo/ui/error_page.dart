import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Error"),
      ),
      body: Center(
        child: Text("Error 404"),
      ),
    );
  }
}
